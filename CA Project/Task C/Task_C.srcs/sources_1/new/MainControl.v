////`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////
////// Company: 
////// Engineer: 
////// 
////// Create Date: 04/11/2026 11:57:34 AM
////// Design Name: 
////// Module Name: MainControl
////// Project Name: 
////// Target Devices: 
////// Tool Versions: 
////// Description: 
////// 
////// Dependencies: 
////// 
////// Revision:
////// Revision 0.01 - File Created
////// Additional Comments:
////// 
//////////////////////////////////////////////////////////////////////////////////////

////module MainControl (
////    input  [6:0] opcode,
////    output reg   RegWrite,
////    output reg [1:0] ALUOp,
////    output reg   MemRead,
////    output reg   MemWrite,
////    output reg   ALUSrc,
////    output reg   MemtoReg,
////    output reg   Branch
////);
////    always @(*) begin
////        // defaults
////        RegWrite = 0; ALUOp = 2'b00; MemRead = 0;
////        MemWrite = 0; ALUSrc = 0; MemtoReg = 0; Branch = 0;

////        case (opcode)
////            7'b0110011: begin // R-type
////                RegWrite = 1; ALUOp = 2'b10;
////            end
////            7'b0010011: begin // I-type ALU (ADDI)
////                RegWrite = 1; ALUOp = 2'b10; ALUSrc = 1;
////            end
////            7'b0000011: begin // Load (LW/LH/LB)
////                RegWrite = 1; ALUSrc = 1; MemRead = 1; MemtoReg = 1;
////            end
////            7'b0100011: begin // Store (SW/SH/SB)
////                ALUSrc = 1; MemWrite = 1;
////            end
////            7'b1100011: begin // Branch (BEQ)
////                ALUOp = 2'b01; Branch = 1;
////            end
////        endcase
////    end
////endmodule
//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Module Name: MainControl
////
//// CHANGES vs Lab 11 original:
////   1. Added decode for the three Part-B instructions:
////        JAL  (opcode 1101111) - J-type
////        JALR (opcode 1100111) - I-type, control flow
////        LUI  (opcode 0110111) - U-type
////   2. Widened MemtoReg to 2 bits so the write-back mux can choose among
////      ALU result, memory data, or PC+4 (needed for JAL/JALR's rd = PC+4).
////   3. Added Jump and JumpReg 1-bit outputs so the top level can override
////      PCNext for JAL (unconditional PC-relative) and JALR (absolute from rs1+imm).
////   4. For LUI: RegWrite=1, ALUSrc=1, ALUOp=00; ImmGen puts the shifted
////      immediate on B and ALU does 0 + imm (since the opcode also forces
////      rs1=x0 in the programs we write, but we don't rely on that - we also
////      have a MemtoReg=00 path straight from ALUResult).
////
//// Control signal reference:
////   Branch  - asserted for B-type opcode; top level ANDs with funct3-based taken
////   Jump    - asserted for JAL          (unconditional PC-relative branch)
////   JumpReg - asserted for JALR         (indirect via ALUResult = rs1 + imm)
////   MemtoReg: 00 = ALUResult, 01 = mem_read_data / switches, 10 = PC+4
////////////////////////////////////////////////////////////////////////////////////
//module MainControl (
//    input  wire [6:0] opcode,
//    output reg        RegWrite,
//    output reg  [1:0] ALUOp,
//    output reg        MemRead,
//    output reg        MemWrite,
//    output reg        ALUSrc,
//    output reg  [1:0] MemtoReg,
//    output reg        Branch,
//    output reg        Jump,
//    output reg        JumpReg
//);
//    always @(*) begin
//        // Safe defaults - every signal off
//        RegWrite = 1'b0;
//        ALUOp    = 2'b00;
//        MemRead  = 1'b0;
//        MemWrite = 1'b0;
//        ALUSrc   = 1'b0;
//        MemtoReg = 2'b00;
//        Branch   = 1'b0;
//        Jump     = 1'b0;
//        JumpReg  = 1'b0;

//        case (opcode)
//            7'b0110011: begin // R-type (ADD, SUB, SLL, SRL, XOR, OR, AND, SLT)
//                RegWrite = 1'b1;
//                ALUOp    = 2'b10;
//            end

//            7'b0010011: begin // I-type arithmetic (ADDI, SLLI, SRLI, SLTI, XORI, ORI, ANDI)
//                RegWrite = 1'b1;
//                ALUSrc   = 1'b1;
//                ALUOp    = 2'b10;
//            end

//            7'b0000011: begin // Loads (LB, LH, LW, LBU, LHU)
//                RegWrite = 1'b1;
//                ALUSrc   = 1'b1;
//                MemRead  = 1'b1;
//                MemtoReg = 2'b01;
//            end

//            7'b0100011: begin // Stores (SB, SH, SW)
//                ALUSrc   = 1'b1;
//                MemWrite = 1'b1;
//            end

//            7'b1100011: begin // B-type branches (BEQ, BNE, BLT, BGE)
//                Branch = 1'b1;
//                ALUOp  = 2'b01;
//            end

//            // ===== PART B: three new instructions =====
//            7'b1101111: begin // JAL (J-type)  -- new type category
//                RegWrite = 1'b1;
//                Jump     = 1'b1;
//                MemtoReg = 2'b10;  // write PC+4 to rd
//            end

//            7'b1100111: begin // JALR (I-type, distinct control-flow opcode)
//                RegWrite = 1'b1;
//                ALUSrc   = 1'b1;   // ALU computes target = rs1 + imm
//                JumpReg  = 1'b1;
//                MemtoReg = 2'b10;  // write PC+4 to rd
//            end

//            7'b0110111: begin // LUI (U-type) -- new type category
//                RegWrite = 1'b1;
//                ALUSrc   = 1'b1;   // ALU uses immediate on B
//                // ALUOp=00 -> ADD. With rs1=x0 convention, ALUResult = imm.
//                // Programmers must use x0 as rs1 when encoding LUI (standard).
//            end

//            default: begin
//                // keep safe-off defaults
//            end
//        endcase
//    end
//endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: MainControl
//
// CHANGES vs Lab 11 original:
//   1. Added decode for the three Part-B instructions:
//        JAL  (opcode 1101111) - J-type
//        JALR (opcode 1100111) - I-type, control flow
//        LUI  (opcode 0110111) - U-type
//   2. Widened MemtoReg to 2 bits so the write-back mux can choose among
//      ALU result, memory data, or PC+4 (needed for JAL/JALR's rd = PC+4).
//   3. Added Jump and JumpReg 1-bit outputs so the top level can override
//      PCNext for JAL (unconditional PC-relative) and JALR (absolute from rs1+imm).
//   4. For LUI: RegWrite=1, ALUSrc=1, ALUOp=00; ImmGen puts the shifted
//      immediate on B and ALU does 0 + imm (since the opcode also forces
//      rs1=x0 in the programs we write, but we don't rely on that - we also
//      have a MemtoReg=00 path straight from ALUResult).
//
// Control signal reference:
//   Branch  - asserted for B-type opcode; top level ANDs with funct3-based taken
//   Jump    - asserted for JAL          (unconditional PC-relative branch)
//   JumpReg - asserted for JALR         (indirect via ALUResult = rs1 + imm)
//   MemtoReg: 00 = ALUResult, 01 = mem_read_data / switches, 10 = PC+4
//////////////////////////////////////////////////////////////////////////////////
module MainControl (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg  [1:0] ALUOp,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg  [1:0] MemtoReg,
    output reg        Branch,
    output reg        Jump,
    output reg        JumpReg
);
    always @(*) begin
        // Safe defaults - every signal off
        RegWrite = 1'b0;
        ALUOp    = 2'b00;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 2'b00;
        Branch   = 1'b0;
        Jump     = 1'b0;
        JumpReg  = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, SLL, SRL, XOR, OR, AND, SLT)
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end

            7'b0010011: begin // I-type arithmetic (ADDI, SLLI, SRLI, SLTI, XORI, ORI, ANDI)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b10;
            end

            7'b0000011: begin // Loads (LB, LH, LW, LBU, LHU)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 2'b01;
            end

            7'b0100011: begin // Stores (SB, SH, SW)
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
            end

            7'b1100011: begin // B-type branches (BEQ, BNE, BLT, BGE)
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            // ===== PART B: three new instructions =====
            7'b1101111: begin // JAL (J-type)  -- new type category
                RegWrite = 1'b1;
                Jump     = 1'b1;
                MemtoReg = 2'b10;  // write PC+4 to rd
            end

            7'b1100111: begin // JALR (I-type, distinct control-flow opcode)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;   // ALU computes target = rs1 + imm
                JumpReg  = 1'b1;
                MemtoReg = 2'b10;  // write PC+4 to rd
            end

            7'b0110111: begin // LUI (U-type) -- new type category
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;   // ALU uses immediate on B
                // ALUOp=00 -> ADD. With rs1=x0 convention, ALUResult = imm.
                // Programmers must use x0 as rs1 when encoding LUI (standard).
            end

            default: begin
                // keep safe-off defaults
            end
        endcase
    end
endmodule