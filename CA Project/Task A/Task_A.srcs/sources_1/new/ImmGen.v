`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 10:42:59 AM
// Design Name: 
// Module Name: ImmGen
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


module immGen(
    input wire [31:0] inst,
    output reg [31:0] imm
);
    always @(*) begin
        case (inst[6:0])
            7'b0010011, 7'b0000011, 7'b1100111: 
                imm = {{20{inst[31]}}, inst[31:20]}; // I-type
            7'b0100011: 
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // S-type
            7'b1100011: // B-type (Branch)
                imm = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
            7'b1101111: 
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // J-type
            default: imm = 32'b0;
        endcase
    end
endmodule