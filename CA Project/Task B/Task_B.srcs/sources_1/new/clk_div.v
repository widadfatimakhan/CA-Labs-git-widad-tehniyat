//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Module Name: clk_divider
////
//// NEW for Part A/B/C. Reason:
////   Our original lab 11 XDC claimed the clock was 40 MHz (25 ns period) while
////   actually driving the processor straight off the 100 MHz board oscillator
////   (pin W5). Vivado's timing analysis used 25 ns but the hardware clocked at
////   10 ns, so on a real board the design is guaranteed to miss timing.
////   The fix is to divide 100 MHz -> 10 MHz in hardware, and update the XDC to
////   declare the real 100 MHz period. That way the processor actually sees a
////   safe 100 ns period.
////
////   Divide by 10: toggle output every 5 input cycles -> 10 MHz.
////////////////////////////////////////////////////////////////////////////////////
//module clk_divider(
//    input  wire clk_in,    // 100 MHz
//    input  wire rst,
//    output reg  clk_out    // 10 MHz
//);
//    reg [2:0] counter;
//    always @(posedge clk_in or posedge rst) begin
//        if (rst) begin
//            counter <= 3'd0;
//            clk_out <= 1'b0;
//        end else begin
//            if (counter == 3'd4) begin
//                counter <= 3'd0;
//                clk_out <= ~clk_out;
//            end else begin
//                counter <= counter + 3'd1;
//            end
//        end
//    end
//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// clk_divider  -  100 MHz  ->  ~10 Hz  (visible LED timing)
//
// Toggles clk_out every 5,000,000 input cycles.
// Period of clk_out = 10,000,000 cycles of clk_in = 100 ms = 10 Hz.
// Each processor instruction takes 100 ms, so DELAY (50*50=2500 instructions)
// lasts about 4 minutes... too long. We use a milder divisor: ~1 kHz instead,
// so each instruction is 1 ms and DELAY lasts ~5 seconds.
//
// 100 MHz / (2 * 50000) = 1 kHz processor clock
// At 1 kHz, the LUI display will hold for ~5 seconds before JAL phase begins.
//////////////////////////////////////////////////////////////////////////////////
module clk_divider(
    input  wire clk_in,    // 100 MHz
    input  wire rst,
    output reg  clk_out    // ~1 kHz
);
    reg [16:0] counter;
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 17'd0;
            clk_out <= 1'b0;
        end else begin
            if (counter == 17'd49_999) begin
                counter <= 17'd0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 17'd1;
            end
        end
    end
endmodule