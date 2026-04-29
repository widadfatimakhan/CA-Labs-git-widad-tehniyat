`timescale 1ns / 1ps

module MainControl (
    input  [6:0] opcode,
    output reg   RegWrite,
    output reg [1:0] ALUOp,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   ALUSrc,
    output reg   MemtoReg,
    output reg   Branch
);
    always @(*) begin
        // Defaults
        RegWrite = 0; ALUOp = 2'b00; MemRead  = 0;
        MemWrite = 0; ALUSrc = 0;    MemtoReg = 0; Branch = 0;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, SRL, SLL)
                RegWrite = 1;
                ALUOp    = 2'b10;
            end

            7'b0010011: begin // I-type ALU (ADDI, ANDI, ORI, XORI, SRLI, SLLI)
                RegWrite = 1;
                ALUOp    = 2'b10;
                ALUSrc   = 1;
            end

            7'b0000011: begin // Load (LW, LB, LH, LBU, LHU)
                RegWrite = 1;
                ALUSrc   = 1;
                MemRead  = 1;
                MemtoReg = 1;
                ALUOp    = 2'b00;
            end

            7'b0100011: begin // Store (SW, SB, SH)
                ALUSrc   = 1;
                MemWrite = 1;
                ALUOp    = 2'b00;
            end

            7'b1100011: begin // Branch (BEQ, BNE)
                ALUOp  = 2'b01;
                Branch = 1;
            end

            7'b1101111: begin // JAL
                RegWrite = 1;
                ALUSrc   = 0;
                ALUOp    = 2'b00;
                Branch   = 0;
            end

            // ---------------------------------------------------------------
            //  JALR  (opcode 1100111) - used by "ret" (jalr x0, x1, 0)
            //  ALUSrc=1 so the ALU computes rs1 + imm (the return address).
            //  RegWrite=1 allows writing to rd (x0 for ret, harmless).
            //  MemtoReg=0 so the ALU result (jump target) flows to the PC.
            //  Branch=0 and the TopLevel handles the PC override separately.
            // ---------------------------------------------------------------
            7'b1100111: begin // JALR
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00;  // ADD: rs1 + imm = return address
                Branch   = 0;
            end

            default: begin
                RegWrite = 0; ALUOp = 2'b00; MemRead  = 0;
                MemWrite = 0; ALUSrc = 0;    MemtoReg = 0; Branch = 0;
            end
        endcase
    end
endmodule