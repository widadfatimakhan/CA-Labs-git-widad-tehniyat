`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 02:45:05 PM
// Design Name: 
// Module Name: tb_taskA
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
// Module:  tb_taskA
//
// Project Task A testbench - runs the Lab 10 countdown program on the
// integrated Lab 11 processor and exposes all useful internal signals at
// tb-scope so they appear directly in Vivado's waveform Objects panel.
//
// Approach:
//   - Instantiates the `Top` module (the FPGA root: ClockDivider + Processor)
//   - Forces clk_en high every cycle so the simulation runs at full speed
//     (otherwise we'd wait ~840,000 clock cycles between processor steps,
//     which is impractical in simulation)
//   - Drives reset, then drives switch_in = 3 to start a countdown
//   - Probes ALL relevant internal signals via `wire ... = dut.u_proc.<sig>;`
//     so they show up automatically in Vivado's wave Objects window
//
// What you should observe in the waveform:
//   1. PC walks 0x00 -> 0x04 -> 0x08 -> ...   (proves PC adder)
//   2. After switch = 3, LED writes show 3 -> 2 -> 1 -> 0  (countdown)
//   3. `pc_current` jumps non-sequentially during JAL and JALR
//      (e.g. PC 0x24 -> 0x2C is the JAL into the COUNTDOWN subroutine)
//   4. `led_we` pulses high each time the LEDs get updated
//   5. `branch_taken_obs` goes high during BEQ/BNE-taken cycles
//
// No tasks, no checks, no $display required. Everything is observed
// visually in the waveform.
//////////////////////////////////////////////////////////////////////////////////
module tb_taskA;

    // ---- Stimulus registers ----
    reg        clk;
    reg        reset;
    reg [5:0]  switch_in;

    // ---- Top-level FPGA outputs ----
    wire [5:0] led_out;
    wire       led_write_en;
    wire [6:0] seg;
    wire [3:0] an;
    wire       dp;

    // ---- Instantiate the FPGA top ----
    Top dut (
        .clk          (clk),
        .reset        (reset),
        .switch_in    (switch_in),
        .led_out      (led_out),
        .led_write_en (led_write_en),
        .seg          (seg),
        .an           (an),
        .dp           (dp)
    );

    // =========================================================================
    //  PROBES - internal signals lifted to tb scope for waveform visibility
    // =========================================================================

    // Clock + control
    wire        clk_en        = dut.clk_en;

    // Fetch
    wire [31:0] pc_current    = dut.u_proc.pc_current;
    wire [31:0] pc_next_val   = dut.u_proc.pc_next_val;
    wire [31:0] pc_plus4      = dut.u_proc.pc_plus4;
    wire [31:0] instruction   = dut.u_proc.instruction;

    // Decode
    wire [6:0]  opcode        = dut.u_proc.opcode;
    wire [4:0]  rd            = dut.u_proc.rd;
    wire [4:0]  rs1           = dut.u_proc.rs1;
    wire [4:0]  rs2           = dut.u_proc.rs2;
    wire [2:0]  funct3        = dut.u_proc.funct3;

    // Control signals
    wire        RegWrite      = dut.u_proc.RegWrite;
    wire        MemRead       = dut.u_proc.MemRead;
    wire        MemWrite      = dut.u_proc.MemWrite;
    wire        ALUSrc        = dut.u_proc.ALUSrc;
    wire        MemtoReg      = dut.u_proc.MemtoReg;
    wire        Branch        = dut.u_proc.Branch;
    wire [1:0]  ALUOp         = dut.u_proc.ALUOp;
    wire        jal_en        = dut.u_proc.jal_en;
    wire        jalr_en       = dut.u_proc.jalr_en;

    // Datapath
    wire [31:0] imm_val       = dut.u_proc.imm_val;
    wire [31:0] ReadData1     = dut.u_proc.ReadData1;
    wire [31:0] ReadData2     = dut.u_proc.ReadData2;
    wire [31:0] alu_result    = dut.u_proc.alu_result;
    wire        zero_flag     = dut.u_proc.zero_flag;
    wire [31:0] WriteBackData = dut.u_proc.WriteBackData;
    wire [31:0] branch_target = dut.u_proc.branch_target;
    wire        pc_src        = dut.u_proc.pc_src;
    wire        branch_taken  = dut.u_proc.pc_src;  // alias for clarity

    // Memory & I/O
    wire        led_wr        = dut.u_proc.led_wr;
    wire        sw_rd_en      = dut.u_proc.sw_rd_en;
    wire        dmem_wr       = dut.u_proc.dmem_wr;
    wire [5:0]  led_value     = dut.u_proc.led_reg;

    // Useful registers from the Lab 10 program
    wire [31:0] x1_ra         = dut.u_proc.u_regFile.regs[1];
    wire [31:0] x2_sp         = dut.u_proc.u_regFile.regs[2];
    wire [31:0] x5_t0         = dut.u_proc.u_regFile.regs[5];
    wire [31:0] x6_t1         = dut.u_proc.u_regFile.regs[6];
    wire [31:0] x10_a0        = dut.u_proc.u_regFile.regs[10];
    wire [31:0] x11_a1        = dut.u_proc.u_regFile.regs[11];
    wire [31:0] x12_a2        = dut.u_proc.u_regFile.regs[12];   // countdown counter
    wire [31:0] x13_a3        = dut.u_proc.u_regFile.regs[13];
    wire [31:0] x28_t3        = dut.u_proc.u_regFile.regs[28];

    // =========================================================================
    //  Clock generation - 10 ns period (100 MHz, matching Basys3)
    // =========================================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================================================================
    //  IMPORTANT - Force clk_en high every cycle for fast simulation.
    //
    //  On real hardware the ClockDivider produces clk_en for only 1 in every
    //  ~840,000 clock cycles (gives ~9.5 Hz processor speed for visible LEDs).
    //  In simulation we'd be waiting forever, so we force clk_en = 1 always.
    //  The processor then advances on every clock edge.
    // =========================================================================
    initial begin
        #1;                                  // wait for hierarchy elaboration
        force dut.u_clkDiv.clk_en = 1'b1;
    end

    // =========================================================================
    //  Stimulus
    // =========================================================================
    initial begin
        // Initial state
        reset     = 1'b1;
        switch_in = 6'd0;

        // Hold reset for several clock edges so all registers initialise
        #50;
        reset = 1'b0;

        // Let the boot-up phase run (loads sp, t0, t1, t3, clears LEDs,
        // enters polling loop). Takes about 10-12 instructions.
        #150;

        // Now drive switch_in = 3 to trigger the countdown.
        // The processor reads the switches via lw a1, 0(t0), then calls
        // the COUNTDOWN subroutine via JAL ra, +8 which decrements a2 from
        // 3 down to 0, displaying each value on the LEDs.
        switch_in = 6'd3;

        // Run for long enough to see at least one full countdown +
        // a second iteration of the main loop (~50 instructions).
        #5000;

        // Try a different value mid-simulation
        switch_in = 6'd5;
        #5000;

        // Drop switches back to 0 and observe processor return to polling
        switch_in = 6'd0;
        #2000;

        $finish;
    end

endmodule
