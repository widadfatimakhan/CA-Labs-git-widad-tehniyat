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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module:  AddressDecoder
// Lab 11 - Fixed version
//
// Memory map (decoded from address[9:8]):
//   2'b00  ?  Data Memory   (byte addresses 0x000 - 0x0FF)
//   2'b01  ?  LED register  (byte address  0x100)
//   2'b10  ?  Switches      (byte address  0x200)
//
// BUGS FIXED:
//  1. Case mismatch: assign targets were dataMemWrite / dataMemRead /
//     switchReadEnable (all lowercase) while the declared output ports
//     are DataMemWrite / DataMemRead / SwitchReadEnable (mixed case).
//     Verilog is case-sensitive - the old assigns created new implicit
//     wires and left the output ports permanently undriven (constant 0).
//
//  2. Address comparison used 2-bit literals (2'b00 etc.) against a
//     32-bit address, which accidentally compared the full address word
//     to 0, 1, 2 rather than using the region bits [9:8].
//     Fixed to use address[9:8] as the region selector.
//////////////////////////////////////////////////////////////////////////////////

//module AddressDecoder (
//    input  wire [31:0] address,
//    input  wire        readEnable,
//    input  wire        writeEnable,
//    output wire        DataMemWrite,
//    output wire        DataMemRead,
//    output wire        LEDWrite,
//    output wire        SwitchReadEnable
//);
//    // Extract the two region-select bits
//    wire [1:0] region = address[9:8];

//    assign DataMemWrite    = (region == 2'b00) ? writeEnable : 1'b0;
//    assign DataMemRead     = (region == 2'b00) ? readEnable  : 1'b0;
//    assign LEDWrite        = (region == 2'b01) ? writeEnable : 1'b0;
//    assign SwitchReadEnable = (region == 2'b10) ? readEnable : 1'b0;

//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AddressDecoder
//
// CHANGES vs Lab 11 original:
//   The original decoder used (region==2'b01) for LEDs (0x1xx) and
//   (region==2'b10) for switches (0x2xx). But OUR Lab 10 assembly code
//   (and the Part C Fibonacci program) uses:
//       0x200 -> display/LED output
//       0x300 -> switch input
//   So the decoder disagreed with our own machine code. Fixed the mapping.
//
// Memory map (matches what our .mem programs use):
//   address[9]       == 0      -> Data Memory (0x000-0x1FF)
//   address[9:8]     == 2'b10  -> LED/display output register (0x200-0x2FF)
//   address[9:8]     == 2'b11  -> Switch input  (0x300-0x3FF)
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
    wire is_dmem   = (address[9] == 1'b0);
    wire is_led    = (address[9:8] == 2'b10);
    wire is_switch = (address[9:8] == 2'b11);

    assign DataMemWrite     = is_dmem   & writeEnable;
    assign DataMemRead      = is_dmem   & readEnable;
    assign LEDWrite         = is_led    & writeEnable;
    assign SwitchReadEnable = is_switch & readEnable;
endmodule