`timescale 1ns / 1ps
`timescale 1ns / 1ps

module tb_instructionMemory();
    reg [31:0] instAddress;
    wire [31:0] instruction;
    integer i;

    // Instantiate your module
    instructionMemory uut (
        .instAddress(instAddress),
        .instruction(instruction)
    );

    initial begin
        instAddress = 0;
       
        // Wait for memory to initialize
        #10;
       
        // Loop through the first 28 bytes (7 instructions)
        for (i = 0; i < 28; i = i + 4) begin
            instAddress = i;
            #10; // Wait 10ns for the logic to update
            $display("Address: %d | Instruction: %h", instAddress, instruction);
        end
       
        $finish; // Stop simulation
    end
endmodule