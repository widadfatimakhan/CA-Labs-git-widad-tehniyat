////`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////
////// File:   top_level.v
////// Contents:
//////   (1) TopLevelProcessor - the single-cycle RISC-V core (our Lab 11
//////       design, extended with JAL/JALR/LUI/BLT support for Parts B and C).
//////   (2) TopLevelFPGA      - a thin board wrapper that adds the 100->10 MHz
//////       clock divider and connects the core to the Basys3 switches and LEDs.
//////
////// CHANGES vs Lab 11 top_level.v:
//////   - 2-bit MemtoReg writeback mux (ALU / mem-or-switch / PC+4) so we can
//////     write PC+4 into rd for JAL and JALR.
//////   - Jump and JumpReg control signals override PC selection.
//////   - JALR target computed from ALUResult with LSB cleared (RISC-V spec).
//////   - Branch condition decoder extended:
//////         funct3=000 BEQ,  funct3=001 BNE,
//////         funct3=100 BLT,  funct3=101 BGE
//////     BEQ/BNE use the Zero flag; BLT/BGE use ALUResult[0] (from SLT).
//////   - MEM_FILE is a parameter so the same core can be wired to Task A, B or
//////     C's instruction memory without touching this file.
//////////////////////////////////////////////////////////////////////////////////////

////// =============================================================================
//////  (1) TopLevelProcessor - single-cycle RV32I core
////// =============================================================================
////module TopLevelProcessor #(
////    parameter MEM_FILE = "mem_file_taskb.mem"
////)(
////    input  wire        clk,
////    input  wire        reset,
////    input  wire [5:0]  switch_in,
////    output wire [5:0]  led_out,
////    output wire        led_write_en
////);

////    // ---------- FETCH ----------
////    wire [31:0] pc_current, pc_plus4, pc_next_val, instruction;

////    ProgramCounter u_PC (
////        .clk    (clk),
////        .reset  (reset),
////        .pc_in  (pc_next_val),
////        .pc_out (pc_current)
////    );
////    pcAdder u_pcAdder (
////        .pc      (pc_current),
////        .pc_next (pc_plus4)
////    );
////    instructionMemory #(.MEM_FILE(MEM_FILE)) u_iMem (
////        .instAddress (pc_current),
////        .instruction (instruction)
////    );

////    // ---------- DECODE ----------
////    wire [6:0] opcode = instruction[6:0];
////    wire [4:0] rd     = instruction[11:7];
////    wire [2:0] funct3 = instruction[14:12];
////    wire [4:0] rs1    = instruction[19:15];
////    wire [4:0] rs2    = instruction[24:20];
////    wire [6:0] funct7 = instruction[31:25];

////    wire        RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, JumpReg;
////    wire [1:0]  ALUOp, MemtoReg;

////    MainControl u_MainCtrl (
////        .opcode   (opcode),
////        .RegWrite (RegWrite),
////        .ALUOp    (ALUOp),
////        .MemRead  (MemRead),
////        .MemWrite (MemWrite),
////        .ALUSrc   (ALUSrc),
////        .MemtoReg (MemtoReg),
////        .Branch   (Branch),
////        .Jump     (Jump),
////        .JumpReg  (JumpReg)
////    );

////    wire [31:0] imm_val;
////    immGen u_immGen (
////        .inst (instruction),
////        .imm  (imm_val)
////    );

////    wire [31:0] ReadData1, ReadData2, WriteBackData;
////    RegisterFile u_regFile (
////        .clk         (clk),
////        .rst         (reset),
////        .WriteEnable (RegWrite),
////        .rs1         (rs1),
////        .rs2         (rs2),
////        .rd          (rd),
////        .WriteData   (WriteBackData),
////        .ReadData1   (ReadData1),
////        .ReadData2   (ReadData2)
////    );

////    // ---------- EXECUTE ----------
////    wire [31:0] alu_src_b;
////    mux2 u_aluSrcMux (
////        .d0  (ReadData2),
////        .d1  (imm_val),
////        .sel (ALUSrc),
////        .y   (alu_src_b)
////    );

////    wire [3:0] alu_ctrl;
////    ALUControl u_ALUCtrl (
////        .opcode     (opcode),
////        .ALUOp      (ALUOp),
////        .funct3     (funct3),
////        .funct7     (funct7),
////        .ALUControl (alu_ctrl)
////    );

////    wire [31:0] alu_result;
////    wire        zero_flag;
////    ALU u_ALU (
////        .ALUControl (alu_ctrl),
////        .A          (ReadData1),
////        .B          (alu_src_b),
////        .ALUResult  (alu_result),
////        .Zero       (zero_flag)
////    );

////    // ---------- BRANCH & JUMP DECISION ----------
////    wire [31:0] branch_target;
////    branchAdder u_branchAdder (
////        .pc            (pc_current),
////        .imm           (imm_val),
////        .branch_target (branch_target)
////    );

////    // Branch taken decoding. For B-type:
////    //   funct3=000 BEQ  -> taken if Zero=1
////    //   funct3=001 BNE  -> taken if Zero=0
////    //   funct3=100 BLT  -> taken if ALUResult[0]=1 (SLT produced 1)
////    //   funct3=101 BGE  -> taken if ALUResult[0]=0
////    // Using funct3[2] to pick between Zero path (0) and SLT path (1), and
////    // funct3[0] to invert.
////    wire cmp_signal   = (funct3[2] == 1'b0) ? zero_flag : alu_result[0];
////    wire branch_taken = Branch & (cmp_signal ^ funct3[0]);

////    // JALR target: rs1 + imm (ALU result) with LSB cleared
////    wire [31:0] jalr_target = {alu_result[31:1], 1'b0};

////    // PC select priority:  JALR > (JAL | Branch-taken) > PC+4
////    assign pc_next_val = JumpReg                ? jalr_target   :
////                         (Jump | branch_taken)  ? branch_target :
////                         pc_plus4;

////    // ---------- MEMORY (with address decoder for MMIO) ----------
////    wire dmem_wr, dmem_rd, led_wr, sw_rd_en;
////    AddressDecoder u_addrDec (
////        .address          (alu_result),
////        .readEnable       (MemRead),
////        .writeEnable      (MemWrite),
////        .DataMemWrite     (dmem_wr),
////        .DataMemRead      (dmem_rd),
////        .LEDWrite         (led_wr),
////        .SwitchReadEnable (sw_rd_en)
////    );

////    wire [31:0] mem_read_data;
////    DataMemory u_dataMem (
////        .clk        (clk),
////        .MemWrite   (dmem_wr),
////        .MemRead    (dmem_rd),
////        .funct3     (funct3),
////        .address    (alu_result),
////        .write_data (ReadData2),
////        .read_data  (mem_read_data)
////    );

////    // If the load address hits the switch region, return the 6-bit switch value
////    // zero-extended. Otherwise return data-memory output.
////    wire [31:0] mem_or_switch = sw_rd_en ? {26'b0, switch_in} : mem_read_data;

////    // ---------- WRITEBACK (3-way mux) ----------
////    //   00 = ALUResult (R-type, I-type ALU, LUI)
////    //   01 = memory / switch data (loads)
////    //   10 = PC+4 (JAL, JALR)
////    assign WriteBackData = (MemtoReg == 2'b01) ? mem_or_switch :
////                           (MemtoReg == 2'b10) ? pc_plus4      :
////                                                  alu_result;

////    // ---------- BOARD OUTPUT: LED latch at 0x200 ----------
////    reg [5:0] led_reg;
////    always @(posedge clk) begin
////        if (reset)
////            led_reg <= 6'b0;
////        else if (led_wr)
////            led_reg <= ReadData2[5:0];
////    end
////    assign led_out      = led_reg;
////    assign led_write_en = led_wr;

////endmodule


////// =============================================================================
//////  (2) TopLevelFPGA - board wrapper (clock divider + input synchronizers)
//////
//////  The physical W5 pin is 100 MHz. The clock divider drops it to 10 MHz so
//////  our single-cycle datapath has ~100 ns to settle per instruction. BTNC is
//////  the reset button; SW[5:0] and LD[5:0] go to the core.
////// =============================================================================
////module TopLevelFPGA #(
////    parameter MEM_FILE = "mem_file_taskb.mem"
////)(
////    input  wire        clk,              // 100 MHz on-board oscillator (W5)
////    input  wire        reset,            // BTNC (U18) - asynchronous
////    input  wire [5:0]  switch_in,        // SW[5:0]
////    output wire [5:0]  led_out,          // LD[5:0]
////    output wire        led_write_en      // LD15: pulses when core writes LEDs
////);
////    // 100 MHz -> 10 MHz processor clock
////    wire proc_clk;
////    clk_divider u_clkdiv (
////        .clk_in  (clk),
////        .rst     (reset),
////        .clk_out (proc_clk)
////    );

////    // 2-stage synchronizers for switches crossing into proc_clk domain
////    reg [5:0] sw_s1, sw_s2;
////    always @(posedge proc_clk or posedge reset) begin
////        if (reset) begin
////            sw_s1 <= 6'd0;
////            sw_s2 <= 6'd0;
////        end else begin
////            sw_s1 <= switch_in;
////            sw_s2 <= sw_s1;
////        end
////    end

////    TopLevelProcessor #(.MEM_FILE(MEM_FILE)) u_proc (
////        .clk          (proc_clk),
////        .reset        (reset),
////        .switch_in    (sw_s2),
////        .led_out      (led_out),
////        .led_write_en (led_write_en)
////    );
////endmodule

//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// File:   top_level.v
////
//// Contents:
////   (1) TopLevelProcessor - the single-cycle RISC-V core (extended for Part B)
////   (2) TopLevelFPGA      - the FPGA wrapper:
////                             - clk_divider (slow clock for visible behaviour)
////                             - 2-stage switch synchronizer
////                             - 16-LED output formatting
////                             - 4-digit 7-segment display formatting
////                             - dedicated LD15 indicator wired to branch_taken
////
//// PART B HARDWARE PRESENTATION:
////   The processor's LED-write address (0x200) writes a 32-bit value into
////   the led_data_reg. The FPGA wrapper splits it as follows:
////     - led_out[15:0]  -> lower 16 bits of led_data_reg     (basic display)
////     - 7-segment (4 hex digits) -> upper 16 bits of led_data_reg
////     - LD15 (special)         -> driven by `branch_taken` signal directly,
////                                 NOT by led_data_reg, so it pulses live
////                                 every time a branch is decided.
////
//// This lets each Part B instruction prove itself visibly:
////     LUI:  writes 32-bit constant  ->  upper 16 bits on 7-seg, lower on LEDs
////     JAL:  writes return address    ->  small number on LEDs (LD0-LD7 only)
////     BLT:  drives branch_taken      ->  LD15 toggles based on comparison
////////////////////////////////////////////////////////////////////////////////////


//// =============================================================================
////  (1) TopLevelProcessor - single-cycle RV32I core
////
////  Same as before, EXCEPT:
////    - led_out widened from 6 bits to 32 bits (so we can split for LEDs+7seg)
////    - new output  branch_taken  exposed to FPGA wrapper for LD15
//// =============================================================================
//module TopLevelProcessor #(
//    parameter MEM_FILE = "mem_file_taskb.mem"
//)(
//    input  wire        clk,
//    input  wire        reset,
//    input  wire [15:0] switch_in,           // widened to 16 (Basys3 has 16 switches)
//    output wire [31:0] led_out,             // widened to 32 (split into 16 LEDs + 7seg)
//    output wire        led_write_en,        // pulses when processor writes to LED region
//    output wire        branch_taken_out     // exposed for LD15 indicator
//);

//    // ---------- FETCH ----------
//    wire [31:0] pc_current, pc_plus4, pc_next_val, instruction;

//    ProgramCounter u_PC (
//        .clk    (clk),
//        .reset  (reset),
//        .pc_in  (pc_next_val),
//        .pc_out (pc_current)
//    );
//    pcAdder u_pcAdder (
//        .pc      (pc_current),
//        .pc_next (pc_plus4)
//    );
//    instructionMemory #(.MEM_FILE(MEM_FILE)) u_iMem (
//        .instAddress (pc_current),
//        .instruction (instruction)
//    );

//    // ---------- DECODE ----------
//    wire [6:0] opcode = instruction[6:0];
//    wire [4:0] rd     = instruction[11:7];
//    wire [2:0] funct3 = instruction[14:12];
//    wire [4:0] rs1    = instruction[19:15];
//    wire [4:0] rs2    = instruction[24:20];
//    wire [6:0] funct7 = instruction[31:25];

//    wire        RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, JumpReg;
//    wire [1:0]  ALUOp, MemtoReg;

//    MainControl u_MainCtrl (
//        .opcode   (opcode),
//        .RegWrite (RegWrite),
//        .ALUOp    (ALUOp),
//        .MemRead  (MemRead),
//        .MemWrite (MemWrite),
//        .ALUSrc   (ALUSrc),
//        .MemtoReg (MemtoReg),
//        .Branch   (Branch),
//        .Jump     (Jump),
//        .JumpReg  (JumpReg)
//    );

//    wire [31:0] imm_val;
//    immGen u_immGen (
//        .inst (instruction),
//        .imm  (imm_val)
//    );

//    wire [31:0] ReadData1, ReadData2, WriteBackData;
//    RegisterFile u_regFile (
//        .clk         (clk),
//        .rst         (reset),
//        .WriteEnable (RegWrite),
//        .rs1         (rs1),
//        .rs2         (rs2),
//        .rd          (rd),
//        .WriteData   (WriteBackData),
//        .ReadData1   (ReadData1),
//        .ReadData2   (ReadData2)
//    );

//    // ---------- EXECUTE ----------
//    wire [31:0] alu_src_b;
//    mux2 u_aluSrcMux (
//        .d0  (ReadData2),
//        .d1  (imm_val),
//        .sel (ALUSrc),
//        .y   (alu_src_b)
//    );

//    wire [3:0] alu_ctrl;
//    ALUControl u_ALUCtrl (
//        .opcode     (opcode),
//        .ALUOp      (ALUOp),
//        .funct3     (funct3),
//        .funct7     (funct7),
//        .ALUControl (alu_ctrl)
//    );

//    wire [31:0] alu_result;
//    wire        zero_flag;
//    ALU u_ALU (
//        .ALUControl (alu_ctrl),
//        .A          (ReadData1),
//        .B          (alu_src_b),
//        .ALUResult  (alu_result),
//        .Zero       (zero_flag)
//    );

//    // ---------- BRANCH DECISION ----------
//    wire [31:0] branch_target;
//    branchAdder u_branchAdder (
//        .pc            (pc_current),
//        .imm           (imm_val),
//        .branch_target (branch_target)
//    );

//    // funct3=000 BEQ taken if zero=1; 001 BNE taken if zero=0;
//    // funct3=100 BLT taken if SLT result=1; 101 BGE taken if SLT result=0
//    wire cmp_signal   = (funct3[2] == 1'b0) ? zero_flag : alu_result[0];
//    wire branch_taken = Branch & (cmp_signal ^ funct3[0]);

//    // expose for LD15 indicator
//    assign branch_taken_out = branch_taken;

//    wire [31:0] jalr_target = {alu_result[31:1], 1'b0};

//    assign pc_next_val = JumpReg                ? jalr_target   :
//                         (Jump | branch_taken)  ? branch_target :
//                                                   pc_plus4;

//    // ---------- MEMORY & I/O ----------
//    wire dmem_wr, dmem_rd, led_wr, sw_rd_en;
//    AddressDecoder u_addrDec (
//        .address          (alu_result),
//        .readEnable       (MemRead),
//        .writeEnable      (MemWrite),
//        .DataMemWrite     (dmem_wr),
//        .DataMemRead      (dmem_rd),
//        .LEDWrite         (led_wr),
//        .SwitchReadEnable (sw_rd_en)
//    );

//    wire [31:0] mem_read_data;
//    DataMemory u_dataMem (
//        .clk        (clk),
//        .MemWrite   (dmem_wr),
//        .MemRead    (dmem_rd),
//        .funct3     (funct3),
//        .address    (alu_result),
//        .write_data (ReadData2),
//        .read_data  (mem_read_data)
//    );

//    // Switch read returns the full 16-bit value (NOT just 6 bits any more)
//    wire [31:0] mem_or_switch = sw_rd_en ? {16'b0, switch_in} : mem_read_data;

//    // ---------- WRITEBACK ----------
//    assign WriteBackData = (MemtoReg == 2'b01) ? mem_or_switch :
//                           (MemtoReg == 2'b10) ? pc_plus4      :
//                                                  alu_result;

//    // ---------- LED REGISTER (32-bit, written by processor) ----------
//    reg [31:0] led_data_reg;
//    always @(posedge clk) begin
//        if (reset)
//            led_data_reg <= 32'b0;
//        else if (led_wr)
//            led_data_reg <= ReadData2;     // store all 32 bits
//    end

//    assign led_out      = led_data_reg;
//    assign led_write_en = led_wr;

//endmodule


//// =============================================================================
////  (2) TopLevelFPGA - board wrapper (clock divider + I/O + display formatting)
////
////  This is the synthesis top.  Drives the physical Basys3 pins:
////     16 switches  SW[15:0]
////     16 LEDs      LD[15:0]   (LD15 special: shows branch_taken, not led data)
////     7-segment   seg[6:0], an[3:0], dp
//// =============================================================================
//module TopLevelFPGA #(
//    parameter MEM_FILE = "mem_file_taskb.mem"
//)(
//    input  wire         clk,             // 100 MHz on-board oscillator (W5)
//    input  wire         reset,           // BTNC (U18)

//    input  wire [15:0]  switch_in,       // SW[15:0]

//    output wire [15:0]  leds,            // LD[15:0]  (LD15 = branch_taken)

//    // 7-segment display (active LOW, common-anode)
//    output wire [6:0]   seg,             // segments a-g
//    output wire [3:0]   an,              // anodes (which digit is lit)
//    output wire         dp               // decimal point (always OFF)
//);

//    // -------------------- Slow clock (~10 Hz visible) -------------------------
//    wire proc_clk;
//    clk_divider u_clkdiv (
//        .clk_in  (clk),
//        .rst     (reset),
//        .clk_out (proc_clk)
//    );

//    // -------------------- 2-stage switch synchronizer -------------------------
//    reg [15:0] sw_s1, sw_s2;
//    always @(posedge proc_clk or posedge reset) begin
//        if (reset) begin
//            sw_s1 <= 16'd0;
//            sw_s2 <= 16'd0;
//        end else begin
//            sw_s1 <= switch_in;
//            sw_s2 <= sw_s1;
//        end
//    end

//    // -------------------- Processor core --------------------------------------
//    wire [31:0] proc_led_out;
//    wire        proc_led_we;
//    wire        proc_branch_taken;

//    TopLevelProcessor #(.MEM_FILE(MEM_FILE)) u_proc (
//        .clk              (proc_clk),
//        .reset            (reset),
//        .switch_in        (sw_s2),
//        .led_out          (proc_led_out),
//        .led_write_en     (proc_led_we),
//        .branch_taken_out (proc_branch_taken)
//    );

//    // -------------------- LED OUTPUT FORMATTING -------------------------------
//    //   leds[14:0] = lower 15 bits of led_data_reg  (general value display)
//    //   leds[15]   = branch_taken_out               (BLT decision indicator)
//    //
//    //   The branch_taken signal is wide-pulsed by latching it across the
//    //   slow clock cycle so it stays visible to the eye when it fires.
//    reg branch_latch;
//    always @(posedge proc_clk or posedge reset) begin
//        if (reset)             branch_latch <= 1'b0;
//        else                   branch_latch <= proc_branch_taken;
//    end

//    assign leds[14:0] = proc_led_out[14:0];
//    assign leds[15]   = branch_latch;

//    // -------------------- 7-SEGMENT DISPLAY -----------------------------------
//    //   Shows upper 16 bits of led_data_reg as 4 hex digits.
//    //   For LUI demo:  lui x1, 0xABCDE then sw x1, 0(LED) ->
//    //     led_data_reg = 0xABCDE000
//    //     7-seg shows  ABCDE  (top 4 hex digits = "ABCD")
//    //     LEDs show    0xE000 (bottom 16 bits)
//    //
//    //   Refresh rate: ~6 kHz per digit (no flicker).
//    wire [15:0] seg_data = proc_led_out[31:16];

//    // 18-bit refresh counter - upper 2 bits select the digit
//    reg [17:0] refresh_counter;
//    always @(posedge clk or posedge reset) begin
//        if (reset) refresh_counter <= 18'd0;
//        else       refresh_counter <= refresh_counter + 1;
//    end
//    wire [1:0] digit_sel = refresh_counter[17:16];

//    // Pick the nibble for the currently-active digit
//    reg [3:0] cur_nibble;
//    always @(*) begin
//        case (digit_sel)
//            2'b00: cur_nibble = seg_data[3:0];      // ones place
//            2'b01: cur_nibble = seg_data[7:4];      // tens place
//            2'b10: cur_nibble = seg_data[11:8];     // hundreds place
//            2'b11: cur_nibble = seg_data[15:12];    // thousands place
//        endcase
//    end

//    // Anode select (active LOW)
//    reg [3:0] an_reg;
//    always @(*) begin
//        case (digit_sel)
//            2'b00: an_reg = 4'b1110;
//            2'b01: an_reg = 4'b1101;
//            2'b10: an_reg = 4'b1011;
//            2'b11: an_reg = 4'b0111;
//        endcase
//    end
//    assign an = an_reg;

//    // Hex -> 7-segment lookup (active LOW: 0=segment ON)
//    reg [6:0] seg_reg;
//    always @(*) begin
//        case (cur_nibble)
//            4'h0: seg_reg = 7'b1000000;
//            4'h1: seg_reg = 7'b1111001;
//            4'h2: seg_reg = 7'b0100100;
//            4'h3: seg_reg = 7'b0110000;
//            4'h4: seg_reg = 7'b0011001;
//            4'h5: seg_reg = 7'b0010010;
//            4'h6: seg_reg = 7'b0000010;
//            4'h7: seg_reg = 7'b1111000;
//            4'h8: seg_reg = 7'b0000000;
//            4'h9: seg_reg = 7'b0010000;
//            4'hA: seg_reg = 7'b0001000;
//            4'hB: seg_reg = 7'b0000011;
//            4'hC: seg_reg = 7'b1000110;
//            4'hD: seg_reg = 7'b0100001;
//            4'hE: seg_reg = 7'b0000110;
//            4'hF: seg_reg = 7'b0001110;
//        endcase
//    end
//    assign seg = seg_reg;

//    // Decimal point always OFF (active LOW)
//    assign dp = 1'b1;

//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// File:   top_level.v
//
// FIX vs previous version:
//   The previous LD15 wiring used `branch_taken` directly, which reflects EVERY
//   conditional branch's outcome. In the new switch-controlled program, the
//   MAIN_LOOP dispatch uses `bge` and `beq` instructions, whose outcomes
//   constantly overwrote LD15. The user could no longer see the BLT result.
//
//   Solution: make LD15 a "sticky latch" that:
//     - Sets to HIGH when a BLT instruction (funct3=100, B-type) is taken
//     - Clears to LOW when a BLT instruction is NOT taken
//     - Ignores all other branches (BEQ, BNE, BGE, JAL, JALR)
//
//   This way only the BLT instruction's result is shown on LD15.
//////////////////////////////////////////////////////////////////////////////////


// =============================================================================
//  TopLevelProcessor - single-cycle RV32I core
// =============================================================================
module TopLevelProcessor #(
    parameter MEM_FILE = "mem_file_taskb.mem"
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] switch_in,
    output wire [31:0] led_out,
    output wire        led_write_en,
    output wire        blt_taken_out,        // HIGH on cycle when BLT taken
    output wire        blt_executed_out      // HIGH on cycle when BLT runs (taken or not)
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
    immGen u_immGen (.inst (instruction), .imm  (imm_val));

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

    // ----- BLT-specific signals (for LD15) -----
    // BLT is opcode=1100011 (B-type) AND funct3=100
    assign blt_executed_out = Branch & (funct3 == 3'b100);
    assign blt_taken_out    = blt_executed_out & branch_taken;

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
//  TopLevelFPGA - board wrapper
// =============================================================================
module TopLevelFPGA #(
    parameter MEM_FILE = "mem_file_taskb.mem"
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [15:0]  switch_in,
    output wire [15:0]  leds,
    output wire [6:0]   seg,
    output wire [3:0]   an,
    output wire         dp
);

    wire proc_clk;
    clk_divider u_clkdiv (
        .clk_in  (clk),
        .rst     (reset),
        .clk_out (proc_clk)
    );

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

    wire [31:0] proc_led_out;
    wire        proc_led_we;
    wire        blt_taken;
    wire        blt_executed;

    TopLevelProcessor #(.MEM_FILE(MEM_FILE)) u_proc (
        .clk              (proc_clk),
        .reset            (reset),
        .switch_in        (sw_s2),
        .led_out          (proc_led_out),
        .led_write_en     (proc_led_we),
        .blt_taken_out    (blt_taken),
        .blt_executed_out (blt_executed)
    );

    // ---- LED OUTPUTS ----
    //   LD0..LD14 = lower 15 bits of led_data_reg
    //   LD15      = sticky LATCH driven only by BLT outcomes:
    //                 set HIGH when BLT executes AND is taken
    //                 set LOW  when BLT executes AND is not taken
    //                 unchanged on all other branches/jumps
    reg blt_led;
    always @(posedge proc_clk or posedge reset) begin
        if (reset)
            blt_led <= 1'b0;
        else if (blt_executed)
            blt_led <= blt_taken;
        // else hold previous value
    end

    assign leds[14:0] = proc_led_out[14:0];
    assign leds[15]   = blt_led;

    // ---- 7-SEGMENT DISPLAY ----
    wire [15:0] seg_data = proc_led_out[31:16];

    reg [17:0] refresh_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) refresh_counter <= 18'd0;
        else       refresh_counter <= refresh_counter + 1;
    end
    wire [1:0] digit_sel = refresh_counter[17:16];

    reg [3:0] cur_nibble;
    always @(*) begin
        case (digit_sel)
            2'b00: cur_nibble = seg_data[3:0];
            2'b01: cur_nibble = seg_data[7:4];
            2'b10: cur_nibble = seg_data[11:8];
            2'b11: cur_nibble = seg_data[15:12];
        endcase
    end

    reg [3:0] an_reg;
    always @(*) begin
        case (digit_sel)
            2'b00: an_reg = 4'b1110;
            2'b01: an_reg = 4'b1101;
            2'b10: an_reg = 4'b1011;
            2'b11: an_reg = 4'b0111;
        endcase
    end
    assign an = an_reg;

    reg [6:0] seg_reg;
    always @(*) begin
        case (cur_nibble)
            4'h0: seg_reg = 7'b1000000;
            4'h1: seg_reg = 7'b1111001;
            4'h2: seg_reg = 7'b0100100;
            4'h3: seg_reg = 7'b0110000;
            4'h4: seg_reg = 7'b0011001;
            4'h5: seg_reg = 7'b0010010;
            4'h6: seg_reg = 7'b0000010;
            4'h7: seg_reg = 7'b1111000;
            4'h8: seg_reg = 7'b0000000;
            4'h9: seg_reg = 7'b0010000;
            4'hA: seg_reg = 7'b0001000;
            4'hB: seg_reg = 7'b0000011;
            4'hC: seg_reg = 7'b1000110;
            4'hD: seg_reg = 7'b0100001;
            4'hE: seg_reg = 7'b0000110;
            4'hF: seg_reg = 7'b0001110;
        endcase
    end
    assign seg = seg_reg;
    assign dp = 1'b1;

endmodule