`timescale 1ns / 1ps
module instructionMemory (
    input  [31:0] instAddress,
    output [31:0] instruction
);
    // 64 depth is enough for your 27 instructions
    reg [31:0] memory [0:63]; 
 
    initial begin
        // Make sure this filename matches your file in Vivado exactly
        $readmemh("mem_file.mem", memory);
    end
 
    // RISC-V PC is 0, 4, 8... 
    // We shift right by 2 to get index 0, 1, 2...
    assign instruction = memory[instAddress[31:2]];

endmodule