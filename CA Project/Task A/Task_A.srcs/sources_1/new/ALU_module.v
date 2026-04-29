`timescale 1ns / 1ps
module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [ 3:0] ALUControl,
    output reg [31:0] ALUResult, // Correctly declared as reg
    output            Zero
);
    wire [31:0] node_carry;
    wire [31:0] chain_output;
    wire [31:0] mod_b;

    // 1. Setup the math signals
    assign mod_b  = (ALUControl == 4'b0110) ? ~B : B;
    wire   init_c = (ALUControl == 4'b0110) ? 1'b1 : 1'b0;

    // 2. Generate the 1-bit chain (This stays as is)
    genvar k;
    generate
        for (k = 0; k < 32; k = k + 1) begin : gen_alu
            if (k == 0)
                ALU_1bit unit0 (
                    .bit_a   (A[k]),
                    .bit_b   (mod_b[k]),
                    .c_in    (init_c),
                    .op_sel  (ALUControl),
                    .bit_out (chain_output[k]),
                    .c_out   (node_carry[k])
                );
            else
                ALU_1bit unitN (
                    .bit_a   (A[k]),
                    .bit_b   (mod_b[k]),
                    .c_in    (node_carry[k-1]),
                    .op_sel  (ALUControl),
                    .bit_out (chain_output[k]),
                    .c_out   (node_carry[k])
                );
        end
    endgenerate

    // 3. The combined Result Logic (Fixes your "not declared" error)
    always @(*) begin
        case (ALUControl)
            4'b0101: ALUResult = A << B[4:0];  // SLL
            4'b0100: ALUResult = A >> B[4:0];  // SRL  
            // Add other cases here if you want to bypass the chain for speed:
            // 4'b0010: ALUResult = A + B; 
            default: ALUResult = chain_output; // Use the chain for ADD/SUB/AND/OR
        endcase
    end

    // 4. Robust Branching
    assign Zero = (A == B);

endmodule