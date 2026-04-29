`timescale 1ns / 1ps

module TopLevelProcessor (
    input  wire        clk,
    input  wire        clk_en,       // driven by ClockDivider in Top
    input  wire        reset,
    input  wire [5:0]  switch_in,
    output wire [5:0]  led_out,
    output wire        led_write_en,
    output reg  [6:0]  seg,
    output reg  [3:0]  an,
    output wire        dp
);

    assign dp = 1'b1; // DP active-low on Basys3, 1 = OFF

    // =========================================================================
    //  FETCH
    // =========================================================================
    wire [31:0] pc_current, pc_plus4, pc_next_val, instruction;
    reg  [31:0] pc_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)       pc_reg <= 32'b0;
        else if (clk_en) pc_reg <= pc_next_val;
    end

    assign pc_current = pc_reg;

    pcAdder u_pcAdder (
        .pc      (pc_current),
        .pc_next (pc_plus4)
    );

    instructionMemory u_iMem (
        .instAddress (pc_current),
        .instruction (instruction)
    );

    // =========================================================================
    //  DECODE
    // =========================================================================
    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rd     = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1    = instruction[19:15];
    wire [4:0] rs2    = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];

    wire       RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;

    MainControl u_MainCtrl (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    wire [31:0] imm_val;
    immGen u_immGen (.inst(instruction), .imm(imm_val));

    // Instruction type flags
    wire jal_en  = (opcode == 7'b1101111); // JAL
    wire jalr_en = (opcode == 7'b1100111); // JALR (ret)

    wire [31:0] ReadData1, ReadData2, WriteBackData;

    RegisterFile u_regFile (
        .clk        (clk),
        .clk_en     (clk_en),
        .rst        (reset),
        .WriteEnable(RegWrite),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WriteBackData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    // =========================================================================
    //  EXECUTE
    // =========================================================================
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

    wire [31:0] branch_target;
    branchAdder u_branchAdder (
        .pc            (pc_current),
        .imm           (imm_val),
        .branch_target (branch_target)
    );

    wire branch_cond = (funct3[0] == 1'b0) ? zero_flag : ~zero_flag;
    wire pc_src      = Branch & branch_cond;

    // JAL  target: PC + imm (PC-relative)
    wire [31:0] jal_target  = pc_current + imm_val;
    // JALR target: (rs1 + imm), LSB forced to 0 per RISC-V spec
    wire [31:0] jalr_target = {alu_result[31:1], 1'b0};

    // PC mux - priority: JALR > JAL > Branch > PC+4
    assign pc_next_val = jalr_en ? jalr_target  :
                         jal_en  ? jal_target   :
                         pc_src  ? branch_target :
                                   pc_plus4;

    // =========================================================================
    //  MEMORY & ADDRESS DECODING
    // =========================================================================
    wire dmem_wr_raw, dmem_rd, led_wr_raw, sw_rd_en;

    AddressDecoder u_addrDec (
        .address          (alu_result),
        .readEnable       (MemRead),
        .writeEnable      (MemWrite),
        .DataMemWrite     (dmem_wr_raw),
        .DataMemRead      (dmem_rd),
        .LEDWrite         (led_wr_raw),
        .SwitchReadEnable (sw_rd_en)
    );

    wire dmem_wr = dmem_wr_raw & clk_en;
    wire led_wr  = led_wr_raw  & clk_en;

    wire [31:0] mem_read_data;
    DataMemory u_dataMem (
        .clk        (clk),
        .clk_en     (clk_en),
        .MemWrite   (dmem_wr),
        .MemRead    (dmem_rd),
        .funct3     (funct3),
        .address    (alu_result),
        .write_data (ReadData2),
        .read_data  (mem_read_data)
    );

    wire [31:0] mem_or_switch = sw_rd_en ? {26'b0, switch_in} : mem_read_data;

    // =========================================================================
    //  WRITEBACK
    //  JAL and JALR both write PC+4 (return address) into rd
    // =========================================================================
    assign WriteBackData = (jal_en | jalr_en) ? pc_plus4      :
                            MemtoReg           ? mem_or_switch :
                                                 alu_result;

    // =========================================================================
    //  LED REGISTER
    // =========================================================================
    reg [5:0] led_reg;
    always @(posedge clk or posedge reset) begin
        if (reset)       led_reg <= 6'b0;
        else if (led_wr) led_reg <= ReadData2[5:0];
    end

    assign led_out      = led_reg;
    assign led_write_en = led_wr;

    // =========================================================================
    //  7-SEGMENT DISPLAY
    //  Shows led_reg as two decimal digits (units on an[0], tens on an[1]).
    //  Refresh: 100 MHz / 2^14 ? 6.1 kHz per digit (flicker-free).
    // =========================================================================
    wire [3:0] tens  = (led_reg >= 60) ? 4'd6 :
                       (led_reg >= 50) ? 4'd5 :
                       (led_reg >= 40) ? 4'd4 :
                       (led_reg >= 30) ? 4'd3 :
                       (led_reg >= 20) ? 4'd2 :
                       (led_reg >= 10) ? 4'd1 : 4'd0;
    wire [3:0] units = led_reg - (tens * 4'd10);

    reg [13:0] mux_ctr;
    always @(posedge clk or posedge reset)
        if (reset) mux_ctr <= 14'b0;
        else       mux_ctr <= mux_ctr + 1'b1;

    wire [1:0] digit_sel = mux_ctr[13:12];

    reg [3:0] nibble;
    reg       blank;

    always @(*) begin
        blank  = 1'b0;
        nibble = 4'd0;
        case (digit_sel)
            2'b00: nibble = units;
            2'b01: nibble = tens;
            2'b10: begin nibble = 4'd0; blank = 1'b1; end
            2'b11: begin nibble = 4'd0; blank = 1'b1; end
            default: blank = 1'b1;
        endcase
    end

    always @(*) begin
        case (digit_sel)
            2'b00: an = 4'b1110;
            2'b01: an = 4'b1101;
            2'b10: an = 4'b1011;
            2'b11: an = 4'b0111;
            default: an = 4'b1111;
        endcase
    end

    always @(*) begin
        if (blank) seg = 7'b1111111;
        else case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule