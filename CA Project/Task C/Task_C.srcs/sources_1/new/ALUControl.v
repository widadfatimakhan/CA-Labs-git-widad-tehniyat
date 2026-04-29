`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/11/2026 11:58:20 AM
//// Design Name: 
//// Module Name: ALUControl
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
///////////////////////////////////////////////////////////////////////
// Module Name: ALUControl
//
// CHANGES vs Lab 11 original:
//   1. Fixed the SUB vs ADD decoding for R-type. The old code only checked
//      funct7=0100000 when opcode was explicitly 0110011, but it's cleaner
//      (and matches standard Patterson) to just gate on funct7[5] for R-type.
//   2. Added SLT decoding for BLT (Part B) - when ALUOp=01 (branch) and
//      funct3=100 (BLT), emit SLT so the top-level can use ALUResult[0] as the
//      branch decision.
//   3. Added SLTI support for Part B (I-type, funct3=010).
//   4. Kept ALUOp=2'b10 meaning "R-type OR I-type arithmetic" as in the
//      original Lab 11 - that's why SLLI/SRLI already work without changes.
//
// ALUOp encoding (from MainControl):
//   00 -> ADD            (loads, stores, JALR address, LUI)
//   01 -> SUB or SLT     (branches - funct3 picks which)
//   10 -> funct3-decoded (R-type and I-type arithmetic)
//
// Output (4-bit ALU opcode) matches ALU_module.v:
//   0000=AND  0001=OR   0010=ADD  0011=XOR
//   0100=SLL  0101=SRL  0110=SUB  0111=SLT
//////////////////////////////////////////////////////////////////////////////////
module ALUControl (
    input  wire [6:0] opcode,
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);
    wire is_rtype = (opcode == 7'b0110011);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010;                     // ADD (loads/stores/JALR/LUI)

            2'b01: begin                                     // Branches
                case (funct3)
                    3'b000,
                    3'b001:  ALUControl = 4'b0110;           // BEQ/BNE -> SUB (check Zero)
                    3'b100,
                    3'b101:  ALUControl = 4'b0111;           // BLT/BGE -> SLT (check result[0])
                    default: ALUControl = 4'b0110;
                endcase
            end

            2'b10: begin                                     // R-type or I-type arithmetic
                case (funct3)
                    3'b000:  ALUControl = (is_rtype && funct7[5]) ? 4'b0110 : 4'b0010; // SUB/ADD/ADDI
                    3'b001:  ALUControl = 4'b0100;           // SLL / SLLI
                    3'b010:  ALUControl = 4'b0111;           // SLT / SLTI (signed)
                    3'b100:  ALUControl = 4'b0011;           // XOR / XORI
                    3'b101:  ALUControl = 4'b0101;           // SRL / SRLI
                    3'b110:  ALUControl = 4'b0001;           // OR / ORI
                    3'b111:  ALUControl = 4'b0000;           // AND / ANDI
                    default: ALUControl = 4'b0010;
                endcase
            end

            default: ALUControl = 4'b0010;
        endcase
    end
endmodule