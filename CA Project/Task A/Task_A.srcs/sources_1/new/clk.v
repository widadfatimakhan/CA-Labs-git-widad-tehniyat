`timescale 1ns / 1ps
module ClockDivider (
    input  wire clk,      // 100MHz or 40MHz source
    input  wire reset,
    output wire clk_en    // The 1-cycle pulse that triggers the CPU
);

    // 2^22 gives roughly 9.5Hz (Visible countdown speed)
    reg [22:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 23'b0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    // This creates a pulse that is HIGH for exactly one 100MHz cycle
    // when the counter wraps around.
    assign clk_en = (counter == 23'h7FFFFF);

endmodule
