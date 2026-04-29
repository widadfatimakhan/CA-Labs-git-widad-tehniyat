`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 03:40:10 PM
// Design Name: 
// Module Name: tb_taskB
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
// Module:  tb_taskB
//
// Project Task B testbench - minimal, focused on the three demonstrated
// instructions: LUI, JAL, BLT.
//
// Signals exposed for waveform observation:
//   PHASE 1 - LUI:
//     led_data_reg       (32-bit value the program wrote to LED address)
//                        Should become 0xABCD0000 after the LUI store.
//   PHASE 2 - JAL:
//     ra (= x1)          Should hold PC+4 (= 0x18) after `jal ra, DELAY`.
//   PHASE 3 - BLT:
//     branch_taken       Pulses HIGH when BLT condition is true (sw < 8).
//     switch_in          Driven by stimulus to test both BLT outcomes.
//
// Stimulus: reset, then drive switches to two test values to cover both
//           BLT-taken and BLT-not-taken cases.
//
// No tasks/checks/$display.  Inspect the wave window.
//////////////////////////////////////////////////////////////////////////////////
module tb_taskB;

    reg         clk;
    reg         reset;
    reg [15:0]  switch_in;

    wire [15:0] leds;
    wire [6:0]  seg;
    wire [3:0]  an;
    wire        dp;

    // ---- DUT: the FPGA top ----
    TopLevelFPGA dut (
        .clk       (clk),
        .reset     (reset),
        .switch_in (switch_in),
        .leds      (leds),
        .seg       (seg),
        .an        (an),
        .dp        (dp)
    );

    // ====================================================================
    // PROBES - minimal, only what the user asked to verify
    // ====================================================================

    // PHASE 1 - LUI: the 32-bit value the processor wrote to LED address
    wire [31:0] led_data_reg = dut.u_proc.led_data_reg;

    // PHASE 2 - JAL: register x1 (ra) - holds the saved return address
    wire [31:0] ra = dut.u_proc.u_regFile.regs[1];

    // PHASE 3 - BLT: the branch_taken signal that drives LD15
//    wire        branch_taken = dut.proc_branch_taken;
    wire        branch_taken = dut.blt_taken;
    // Useful bonus: the PC and current instruction so the user can see
    // which phase the program is in
    wire [31:0] pc           = dut.u_proc.pc_current;
    wire [31:0] instruction  = dut.u_proc.instruction;

    // ====================================================================
    // Clock generation
    // ====================================================================
    initial clk = 0;
    always #5 clk = ~clk;       // 100 MHz simulated clock

    // ====================================================================
    // Skip the slow ~10 Hz divider so simulation runs at full speed
    // ====================================================================
    initial begin
        #1;
        force dut.proc_clk = clk;
        force dut.sw_s2    = switch_in;     // bypass synchronizer too
    end

    // ====================================================================
    // Stimulus
    // ====================================================================
//    initial begin
//        reset     = 1'b1;
//        switch_in = 16'd0;
//        #50;
//        reset = 1'b0;
    
//        // Mode 0: LUI - expect led_data_reg = ABCD0000
//        switch_in = 16'h0000;
//        #500;
    
//        // Mode 1: JAL - expect led_data_reg = 0000003C (or similar small value)
//        switch_in = 16'h4000;       // SW14 = 1
//        #500;
    
//        // Mode 2: BLT with sw=5 - expect branch_taken pulses HIGH
//        switch_in = 16'h8005;       // SW15 = 1, lower bits = 5
//        #500;
    
//        // Mode 2: BLT with sw=12 - expect branch_taken stays LOW
//        switch_in = 16'h800C;       // SW15 = 1, lower bits = 12 (>= 8)
//        #500;
    
//        $finish;
//    end
    initial begin
        reset     = 1'b1;#50;
        switch_in = 16'd5;          // Lower 4 bits = 5, so when BLT runs: 5 < 8 ? taken
        #50;
        reset = 1'b0;
        #50;
    
        // Wait long enough for boot phases to complete
        // (with hardware-realistic DELAY of 50×50, this is ~50 µs)
//        #100000;                    // 100 µs - well past boot
    
//        // BLT phase is now active. Test the other case:
//        switch_in = 16'd12;         // 12 ? 8 ? BLT not taken
//        #5000;
    
//        // Back to taken
//        switch_in = 16'd5;
        #50000;
    
        $finish;
    end

endmodule
