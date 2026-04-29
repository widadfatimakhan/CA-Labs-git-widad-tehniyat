`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project Task C - Single-cycle RV32I core + Basys3 FPGA wrapper
//
// Two modules in this file:
//   (1) TopLevelProcessor  - the processor core (synthesized as a sub-module)
//   (2) TopLevelFPGA       - the FPGA top, wires the core to board pins,
//                            includes clock divider and switch synchronizer
//////////////////////////////////////////////////////////////////////////////////


// =============================================================================
//  (1) TopLevelProcessor
// =============================================================================
module TopLevelProcessor #(
    parameter MEM_FILE = "task_c.mem"
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] switch_in,
    output wire [31:0] led_out,
    output wire        led_write_en
);

    // ---------- FETCH ----------
    wire [31:0] pc_current, pc_plus4, pc_next_val, instruction;

    ProgramCounter u_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_in  (pc_next_val),
        .pc_out (pc_current)
    );
    pcAdder u_pcAdder (
        .pc      (pc_current),
        .pc_next (pc_plus4)
    );
    instructionMemory #(.MEM_FILE(MEM_FILE)) u_iMem (
        .instAddress (pc_current),
        .instruction (instruction)
    );

    // ---------- DECODE ----------
    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rd     = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1    = instruction[19:15];
    wire [4:0] rs2    = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];

    wire        RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, JumpReg;
    wire [1:0]  ALUOp, MemtoReg;

    MainControl u_MainCtrl (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .Jump     (Jump),
        .JumpReg  (JumpReg)
    );

    wire [31:0] imm_val;
    immGen u_immGen (.inst(instruction), .imm(imm_val));

    wire [31:0] ReadData1, ReadData2, WriteBackData;
    RegisterFile u_regFile (
        .clk         (clk),
        .rst         (reset),
        .WriteEnable (RegWrite),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .WriteData   (WriteBackData),
        .ReadData1   (ReadData1),
        .ReadData2   (ReadData2)
    );

    // ---------- EXECUTE ----------
    wire [31:0] alu_src_b;
    mux2 u_aluSrcMux (.d0(ReadData2), .d1(imm_val), .sel(ALUSrc), .y(alu_src_b));

    wire [3:0] alu_ctrl;
    ALUControl u_ALUCtrl (
        .opcode     (opcode),
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (alu_ctrl)
    );

    wire [31:0] alu_result;
    wire        zero_flag;
    ALU u_ALU (
        .ALUControl (alu_ctrl),
        .A          (ReadData1),
        .B          (alu_src_b),
        .ALUResult  (alu_result),
        .Zero       (zero_flag)
    );

    // ---------- BRANCH DECISION ----------
    wire [31:0] branch_target;
    branchAdder u_branchAdder (
        .pc            (pc_current),
        .imm           (imm_val),
        .branch_target (branch_target)
    );

    wire cmp_signal   = (funct3[2] == 1'b0) ? zero_flag : alu_result[0];
    wire branch_taken = Branch & (cmp_signal ^ funct3[0]);

    wire [31:0] jalr_target = {alu_result[31:1], 1'b0};

    assign pc_next_val = JumpReg                ? jalr_target   :
                         (Jump | branch_taken)  ? branch_target :
                                                   pc_plus4;

    // ---------- MEMORY & I/O ----------
    wire dmem_wr, dmem_rd, led_wr, sw_rd_en;
    AddressDecoder u_addrDec (
        .address          (alu_result),
        .readEnable       (MemRead),
        .writeEnable      (MemWrite),
        .DataMemWrite     (dmem_wr),
        .DataMemRead      (dmem_rd),
        .LEDWrite         (led_wr),
        .SwitchReadEnable (sw_rd_en)
    );

    wire [31:0] mem_read_data;
    DataMemory u_dataMem (
        .clk        (clk),
        .MemWrite   (dmem_wr),
        .MemRead    (dmem_rd),
        .funct3     (funct3),
        .address    (alu_result),
        .write_data (ReadData2),
        .read_data  (mem_read_data)
    );

    wire [31:0] mem_or_switch = sw_rd_en ? {16'b0, switch_in} : mem_read_data;

    // ---------- WRITEBACK ----------
    assign WriteBackData = (MemtoReg == 2'b01) ? mem_or_switch :
                           (MemtoReg == 2'b10) ? pc_plus4      :
                                                  alu_result;

    // ---------- LED REGISTER (32-bit) ----------
    reg [31:0] led_data_reg;
    always @(posedge clk) begin
        if (reset)
            led_data_reg <= 32'b0;
        else if (led_wr)
            led_data_reg <= ReadData2;
    end

    assign led_out      = led_data_reg;
    assign led_write_en = led_wr;

endmodule


// =============================================================================
//  (2) TopLevelFPGA - board wrapper. THIS IS THE SYNTHESIS TOP.
// =============================================================================
module TopLevelFPGA #(
    parameter MEM_FILE = "task_c.mem"
)(
    input  wire        clk,             // 100 MHz on-board oscillator (W5)
    input  wire        reset,           // BTNC (U18)
    input  wire [15:0] switch_in,       // SW[15:0]
    output wire [15:0] leds             // LD[15:0] - lower 16 bits of LED reg
);

    // Slow processor clock for visible behavior (~1 kHz)
    wire proc_clk;
    clk_divider u_clkdiv (
        .clk_in  (clk),
        .rst     (reset),
        .clk_out (proc_clk)
    );

    // 2-stage switch synchronizer
    reg [15:0] sw_s1, sw_s2;
    always @(posedge proc_clk or posedge reset) begin
        if (reset) begin
            sw_s1 <= 16'd0;
            sw_s2 <= 16'd0;
        end else begin
            sw_s1 <= switch_in;
            sw_s2 <= sw_s1;
        end
    end

    // Instantiate the processor with our chosen MEM_FILE
    wire [31:0] proc_led_out;
    wire        proc_led_we;

    TopLevelProcessor #(.MEM_FILE(MEM_FILE)) u_proc (
        .clk          (proc_clk),
        .reset        (reset),
        .switch_in    (sw_s2),
        .led_out      (proc_led_out),
        .led_write_en (proc_led_we)
    );

    // Map lower 16 bits of LED register to the 16 board LEDs
    assign leds = proc_led_out[15:0];

endmodule