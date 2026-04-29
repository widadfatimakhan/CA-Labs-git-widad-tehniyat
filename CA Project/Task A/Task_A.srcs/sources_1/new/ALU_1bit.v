`timescale 1ns / 1ps
module ALU_1bit (
    input      bit_a,
    input      bit_b,
    input      c_in,
    input [3:0] op_sel,
    output reg bit_out,
    output     c_out
);
    wire arith_out;

    // Full adder logic for ADD and SUB
    assign {c_out, arith_out} = bit_a + bit_b + c_in;

    always @(*) begin
        case (op_sel)
            4'b0010: bit_out = arith_out;       // ADD (addi)
            4'b0110: bit_out = arith_out;       // SUB (beq/bne)
            4'b0000: bit_out = bit_a & bit_b;   // AND
            4'b0001: bit_out = bit_a | bit_b;   // OR
            4'b0011: bit_out = bit_a ^ bit_b;   // XOR
            default: bit_out = arith_out;      // Default to arithmetic
        endcase
    end
    
endmodule
