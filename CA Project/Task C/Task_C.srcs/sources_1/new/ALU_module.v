//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/11/2026 11:02:48 AM
//// Design Name: 
//// Module Name: ALU_module
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

//module ALU (
//    input  wire [31:0] A,
//    input  wire [31:0] B,
//    input  wire [ 3:0] ALUControl,
//    output reg  [31:0] ALUResult,
//    output wire        Zero
//);
//    // --- Sub/SLT use (A + ~B + 1) through the bit-slice chain ----------------
//    wire invertB = (ALUControl == 4'b0110) || (ALUControl == 4'b0111);
//    wire init_c  = invertB;
//    wire [31:0] mod_b = invertB ? ~B : B;

//    // --- 32-bit ripple chain built from ALU_1bit ----------------------------
//    wire [31:0] chain_carry;
//    wire [31:0] chain_out;

//    genvar k;
//    generate
//        for (k = 0; k < 32; k = k + 1) begin : gen_alu
//            if (k == 0)
//                ALU_1bit u0 (
//                    .bit_a  (A[k]),
//                    .bit_b  (mod_b[k]),
//                    .c_in   (init_c),
//                    .op_sel (ALUControl),
//                    .bit_out(chain_out[k]),
//                    .c_out  (chain_carry[k])
//                );
//            else
//                ALU_1bit uN (
//                    .bit_a  (A[k]),
//                    .bit_b  (mod_b[k]),
//                    .c_in   (chain_carry[k-1]),
//                    .op_sel (ALUControl),
//                    .bit_out(chain_out[k]),
//                    .c_out  (chain_carry[k])
//                );
//        end
//    endgenerate

//    // --- SLT (signed): sign of (A-B), corrected for overflow ----------------
//    // For signed a<b : result = sign_bit ^ overflow
//    // overflow for a-b = (A[31] ^ B[31]) & (A[31] ^ chain_out[31])
//    wire overflow = (A[31] ^ B[31]) & (A[31] ^ chain_out[31]);
//    wire slt_bit  = chain_out[31] ^ overflow;

//    // --- Final result select -------------------------------------------------
//    always @(*) begin
//        case (ALUControl)
//            4'b0100: ALUResult = A << B[4:0];                   // SLL
//            4'b0101: ALUResult = A >> B[4:0];                   // SRL
//            4'b0111: ALUResult = {31'b0, slt_bit};              // SLT (signed)
//            default: ALUResult = chain_out;                     // ADD/SUB/AND/OR/XOR
//        endcase
//    end

//    // Zero flag on final result - used by BEQ/BNE branch decision at top level
//    assign Zero = (ALUResult == 32'b0);

//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ALU (32-bit)
//
// CHANGES vs Lab 11 original:
//   1. Opcode scheme re-aligned to match ALUControl (0010=ADD, 0110=SUB, etc.).
//      The original ALU used a different encoding that disagreed with
//      ALUControl.
//   2. Added SLT (0111) - signed less-than, needed for BLT in Part B/C.
//   3. Removed the dead BEQ-as-compare path (0111 used to be "BEQ helper");
//      BEQ/BNE are handled at the top level using the Zero flag from SUB.
//   4. Keeps the 32-slice bit-chain architecture we built in Lab 11 - this is
//      the thing our friend's project does NOT have, and we want to keep it
//      since it's why our design got approved.
//
// Opcode map (same as ALUControl):
//   0000 - AND           (bit-slice)
//   0001 - OR            (bit-slice)
//   0010 - ADD           (bit-slice adder)
//   0011 - XOR           (bit-slice)
//   0100 - SLL           (wrapper barrel shift)
//   0101 - SRL           (wrapper barrel shift)
//   0110 - SUB           (bit-slice adder, B inverted, c_in=1)
//   0111 - SLT (signed)  (SUB result sign + overflow logic at wrapper)
//////////////////////////////////////////////////////////////////////////////////
module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [ 3:0] ALUControl,
    output reg  [31:0] ALUResult,
    output wire        Zero
);
    // --- Sub/SLT use (A + ~B + 1) through the bit-slice chain ----------------
    wire invertB = (ALUControl == 4'b0110) || (ALUControl == 4'b0111);
    wire init_c  = invertB;
    wire [31:0] mod_b = invertB ? ~B : B;

    // --- 32-bit ripple chain built from ALU_1bit ----------------------------
    wire [31:0] chain_carry;
    wire [31:0] chain_out;

    genvar k;
    generate
        for (k = 0; k < 32; k = k + 1) begin : gen_alu
            if (k == 0)
                ALU_1bit u0 (
                    .bit_a  (A[k]),
                    .bit_b  (mod_b[k]),
                    .c_in   (init_c),
                    .op_sel (ALUControl),
                    .bit_out(chain_out[k]),
                    .c_out  (chain_carry[k])
                );
            else
                ALU_1bit uN (
                    .bit_a  (A[k]),
                    .bit_b  (mod_b[k]),
                    .c_in   (chain_carry[k-1]),
                    .op_sel (ALUControl),
                    .bit_out(chain_out[k]),
                    .c_out  (chain_carry[k])
                );
        end
    endgenerate

    // --- SLT (signed): sign of (A-B), corrected for overflow ----------------
    // For signed a<b : result = sign_bit ^ overflow
    // overflow for a-b = (A[31] ^ B[31]) & (A[31] ^ chain_out[31])
    wire overflow = (A[31] ^ B[31]) & (A[31] ^ chain_out[31]);
    wire slt_bit  = chain_out[31] ^ overflow;

    // --- Final result select -------------------------------------------------
    always @(*) begin
        case (ALUControl)
            4'b0100: ALUResult = A << B[4:0];                   // SLL
            4'b0101: ALUResult = A >> B[4:0];                   // SRL
            4'b0111: ALUResult = {31'b0, slt_bit};              // SLT (signed)
            default: ALUResult = chain_out;                     // ADD/SUB/AND/OR/XOR
        endcase
    end

    // Zero flag on final result - used by BEQ/BNE branch decision at top level
    assign Zero = (ALUResult == 32'b0);

endmodule