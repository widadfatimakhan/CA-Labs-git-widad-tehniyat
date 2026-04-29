`timescale 1ns / 1ps

// =============================================================================
//  Top  -  Basys3 root module
//  Connects the ClockDivider to the TopLevelProcessor.
//  This is the module that Vivado sees as the top of the hierarchy.
// =============================================================================
module Top (
    input  wire        clk,          // 100 MHz board oscillator (W5)
    input  wire        reset,        // BTNC - active HIGH async reset
    input  wire [5:0]  switch_in,    // SW[5:0]
    output wire [5:0]  led_out,      // LD[5:0]
    output wire        led_write_en, // LD15 - pulses on LED register write
    output wire [6:0]  seg,          // 7-segment cathodes
    output wire [3:0]  an,           // 7-segment anodes
    output wire        dp            // Decimal point (always OFF)
);

    // -------------------------------------------------------------------------
    //  Clock divider  ?  ~9.5 Hz enable pulse for the processor
    // -------------------------------------------------------------------------
    wire clk_en;

    ClockDivider u_clkDiv (
        .clk    (clk),
        .reset  (reset),
        .clk_en (clk_en)
    );

    // -------------------------------------------------------------------------
    //  Processor
    // -------------------------------------------------------------------------
    TopLevelProcessor u_proc (
        .clk          (clk),
        .clk_en       (clk_en),   // fed in from ClockDivider
        .reset        (reset),
        .switch_in    (switch_in),
        .led_out      (led_out),
        .led_write_en (led_write_en),
        .seg          (seg),
        .an           (an),
        .dp           (dp)
    );

endmodule