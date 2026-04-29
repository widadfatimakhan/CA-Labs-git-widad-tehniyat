`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 11:58:20 AM
// Design Name: 
// Module Name: ALUControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALUControl (
    input  [6:0] opcode,
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUControl
);
    always @(*) begin
        ALUControl = 4'b0010; // default: ADD

        case (ALUOp)
            2'b00: ALUControl = 4'b0010; // ADD (load/store)
            2'b01: ALUControl = 4'b0110; // SUB (BEQ)
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = (opcode == 7'b0110011 && funct7 == 7'b0100000)
                                         ? 4'b0110 : 4'b0010; // SUB or ADD
                    3'b101: ALUControl = 4'b0100; // SRL
                    3'b100: ALUControl = 4'b0011; // XOR
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b111: ALUControl = 4'b0000; // AND
                    default: ALUControl = 4'b0010;
                endcase
            end
            default: ALUControl = 4'b0010;
        endcase
    end
endmodule
