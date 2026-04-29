`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 11:54:26 AM
// Design Name: 
// Module Name: instructionMemory
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


//////////////////////////////////////////////////////////////////////////////////
// Module Name: instructionMemory
//
// CHANGES vs Lab 11 original:
//   1. Changed from byte-wide (reg [7:0] memory [0:255]) to word-wide
//      (reg [31:0] memory [0:255]). The old design was inconsistent with the
//      mem_file.mem we were using: the file had 32-bit hex words but each
//      array cell held only 8 bits, so $readmemh was truncating. This also
//      fixes the "0x prefix is invalid" problem because we no longer need
//      $readmemh to unpack bytes - it just reads one 32-bit word per line.
//   2. Added a MEM_FILE parameter so the same module serves Task A / B / C.
//      Override it at instantiation time:
//        instructionMemory #(.MEM_FILE("mem_file_taskA.mem")) u_iMem (...);
//   3. Word-address: uses instAddress[9:2]. PC increments by 4 so word index
//      = byte address / 4.
//
// mem_file format (one 32-bit word per line, hex, NO 0x prefix):
//      00500E13
//      1FF00113
//      ...
//////////////////////////////////////////////////////////////////////////////////
module instructionMemory #(
    parameter OPERAND_LENGTH = 31,
    parameter MEM_FILE       = "task_c.mem"
)(
    input  wire [OPERAND_LENGTH:0] instAddress,
    output wire [31:0]             instruction
);
    reg [31:0] memory [0:255];

    initial begin
        $readmemh(MEM_FILE, memory);
    end

    // Word-aligned fetch: PC is a byte address; drop the low 2 bits.
    assign instruction = memory[instAddress[9:2]];
endmodule