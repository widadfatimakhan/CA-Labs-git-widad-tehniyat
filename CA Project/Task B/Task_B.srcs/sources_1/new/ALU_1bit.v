//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/11/2026 11:52:02 AM
//// Design Name: 
//// Module Name: ALU_1bit
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
////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ALU_1bit
//
// CHANGES vs Lab 11 original:
//   The op_sel encoding was inconsistent with ALUControl. ALUControl was
//   emitting Patterson-style codes (0010=ADD, 0110=SUB, 0000=AND, ...) but
//   the 1-bit slice was decoding a different scheme (0000=ADD, 0001=SUB, ...).
//   That meant every R-type/I-type instruction executed the wrong operation.
//   Fixed: re-encode so the 1-bit slice matches ALUControl.
//
// Opcode map (matches ALUControl and ALU_module):
//   0000 - AND
//   0001 - OR
//   0010 - ADD           (uses adder, carry_in = 0)
//   0011 - XOR
//   0110 - SUB           (uses adder, B pre-inverted at ALU wrapper, carry_in = 1)
//   0111 - SLT           (uses adder sign bit; handled at wrapper)
// Shift ops (0100 SLL, 0101 SRL) don't use the 1-bit slice - the wrapper
// overrides the output with a barrel shift. Here we just pass the adder sum
// through as a "don't-care" default.
//////////////////////////////////////////////////////////////////////////////////
module ALU_1bit (
    input  wire       bit_a,
    input  wire       bit_b,       // may be pre-inverted by ALU wrapper for SUB/SLT
    input  wire       c_in,
    input  wire [3:0] op_sel,
    output reg        bit_out,
    output wire       c_out
);
    // Full-adder (bit_b is inverted externally for SUB/SLT; c_in=1 for SUB/SLT)
    wire [1:0] sum = bit_a + bit_b + c_in;
    wire       arith_out = sum[0];
    assign     c_out     = sum[1];

    always @(*) begin
        case (op_sel)
            4'b0000: bit_out = bit_a & bit_b;   // AND
            4'b0001: bit_out = bit_a | bit_b;   // OR
            4'b0010: bit_out = arith_out;       // ADD
            4'b0011: bit_out = bit_a ^ bit_b;   // XOR
            4'b0110: bit_out = arith_out;       // SUB (bit_b pre-inverted)
            4'b0111: bit_out = arith_out;       // SLT helper (bit_b pre-inverted)
            default: bit_out = arith_out;       // don't-care for shifts
        endcase
    end
endmodule