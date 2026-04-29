`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 12:00:22 PM
// Design Name: 
// Module Name: AddressDecoder
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

module AddressDecoder (
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    output wire        DataMemWrite,
    output wire        DataMemRead,
    output wire        LEDWrite,
    output wire        SwitchReadEnable
);
    // Let's use more bits to be safe
    // Region 0: 0-255 (Data Memory)
    // Region 2: 512 (Switches)
    // Region 3: 768 (LEDs)
    
    assign DataMemWrite     = (address[9:8] == 2'b00) ? writeEnable : 1'b0;
    assign DataMemRead      = (address[9:8] == 2'b00) ? readEnable  : 1'b0;
    
    // Mapping LEDs to 512 (0x200) to match your 'addi x6, x0, 512'
    assign LEDWrite         = (address[9:8] == 2'b10) ? writeEnable : 1'b0;
    
    // Mapping Switches to 768 (0x300) to match your 'addi x5, x0, 768'
    assign SwitchReadEnable = (address[9:8] == 2'b11) ? readEnable  : 1'b0;
endmodule