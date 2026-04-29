//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/11/2026 10:42:59 AM
//// Design Name: 
//// Module Name: ImmGen
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: immGen
//
// CHANGES vs Lab 11 original:
//   1. Added U-type immediate generation for LUI (Part B).
//      Standard RISC-V: imm = {inst[31:12], 12'b0}. ImmGen puts the full
//      shifted value directly on the output - no branch_adder shifting
//      happens for LUI (it goes through the ALU's B input).
//   2. Added J-type immediate generation for JAL (Part B).
//      Encodes the PC-relative half-offset the same way B-type does (so that
//      branch_adder << 1 re-inserts the implicit LSB=0). This keeps the
//      branch_adder from Task 1 unchanged.
//   3. Kept the original B-type half-offset encoding (missing LSB - the
//      branch_adder already compensates with <<1). DO NOT touch this; it's
//      the viva-approved behaviour.
//
// Port name "imm" retained to match Lab 11 wiring.
//////////////////////////////////////////////////////////////////////////////////
module immGen(
    input  wire [31:0] inst,
    output reg  [31:0] imm
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-type: ADDI, SLLI, SRLI, SLTI, XORI, ORI, ANDI
            7'b0010011,
            // I-type: Loads (LB, LH, LW, LBU, LHU)
            7'b0000011,
            // I-type: JALR (Part B)
            7'b1100111: imm = {{20{inst[31]}}, inst[31:20]};

            // S-type: SB, SH, SW
            7'b0100011: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            // B-type: BEQ, BNE, BLT, BGE -- half-offset; branch_adder shifts <<1
            7'b1100011: imm = {{20{inst[31]}}, inst[31], inst[7],
                               inst[30:25], inst[11:8]};

            // J-type: JAL (Part B) -- half-offset; branch_adder shifts <<1
            7'b1101111: imm = {{12{inst[31]}}, inst[31], inst[19:12],
                               inst[20], inst[30:21]};

            // U-type: LUI (Part B) -- full 32-bit already shifted
            7'b0110111: imm = {inst[31:12], 12'b0};

            default: imm = 32'b0;
        endcase
    end
endmodule