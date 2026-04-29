`timescale 1ns / 1ps
// ============================================================================
//  tb_TopLevel.v  -  Lab 11 Part A  -  TopLevelProcessor Testbench
//
//  Single reset at start. Program runs continuously.
//  No unused variables (no X signals in waveform).
//
//  Clock  : 25 ns / 40 MHz  (matches XDC constraint)
//
//  Reset  : ProgramCounter has ASYNC reset.
//    reset=1  ? PC=0 immediately (no clock edge needed)
//    1st posedge after reset=0  ? PC=4
//    2nd posedge                ? PC=8  … etc.
//
//  Key program addresses (after mem_file_fixed.mem loaded):
//    PC=0x00  00500e13   addi t3,  x0, 5
//    PC=0x04  1ff00113   addi sp,  x0, 511
//    PC=0x08  30000293   addi t0,  x0, 0x300
//    PC=0x0C  20000313   addi t1,  x0, 0x200
//    PC=0x10  01c2a023   sw   t3,  0(t0)
//    PC=0x14  00032023   sw   x0,  0(t1)
//    PC=0x18  0002a583   lw   a1,  0(t0)   ? loops here forever (a1=0)
//    PC=0x1C  fe058ee3   beq  a1,  x0 ? back to 0x18
// ============================================================================

module tb_TopLevel;

    // -----------------------------------------------------------------------
    //  DUT ports
    // -----------------------------------------------------------------------
    reg        clk;
    reg        reset;
    reg  [5:0] switch_in;
    wire [5:0] led_out;
    wire       led_write_en;

    // -----------------------------------------------------------------------
    //  DUT instantiation
    // -----------------------------------------------------------------------
    TopLevelProcessor dut (
        .clk          (clk),
        .reset        (reset),
        .switch_in    (switch_in),
        .led_out      (led_out),
        .led_write_en (led_write_en)
    );

    // -----------------------------------------------------------------------
    //  Clock - 25 ns period / 40 MHz
    // -----------------------------------------------------------------------
    initial clk = 0;
    always  #12.5 clk = ~clk;

    // -----------------------------------------------------------------------
    //  Observation wires (hierarchical taps into DUT)
    // -----------------------------------------------------------------------
    wire [31:0] pc_obs         = dut.pc_current;
    wire [31:0] instr_obs      = dut.instruction;
    wire [31:0] alu_result_obs = dut.alu_result;
    wire        led_wr_obs     = dut.led_wr;
    wire [31:0] rd1_obs        = dut.ReadData1;
    wire [31:0] rd2_obs        = dut.ReadData2;
    wire [31:0] pc_next_obs    = dut.pc_next_val;

    // -----------------------------------------------------------------------
    //  Scoreboard
    // -----------------------------------------------------------------------
    integer pass_count = 0;
    integer fail_count = 0;

    task CHECK32;
        input [255:0] label;
        input [31:0]  got;
        input [31:0]  exp;
        begin
            if (got === exp) begin
                $display("  [PASS] %0s  (0x%08h)", label, got);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %0s  got=0x%08h  exp=0x%08h", label, got, exp);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task CHECK1;
        input [255:0] label;
        input         got;
        input         exp;
        begin
            if (got === exp) begin
                $display("  [PASS] %0s  (%b)", label, got);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %0s  got=%b  exp=%b", label, got, exp);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task CHECK_NO_X;
        input [255:0] label;
        input [31:0]  sig;
        begin
            if (^sig === 1'bx) begin
                $display("  [FAIL] %0s  contains X or Z", label);
                fail_count = fail_count + 1;
            end else begin
                $display("  [PASS] %0s  no X/Z  (0x%08h)", label, sig);
                pass_count = pass_count + 1;
            end
        end
    endtask

    // -----------------------------------------------------------------------
    //  LED event logger
    // -----------------------------------------------------------------------
    integer led_event_cnt;
    initial led_event_cnt = 0;
    always @(posedge clk)
        if (led_write_en) begin
            led_event_cnt = led_event_cnt + 1;
            $display("  [LED_EVENT] t=%0t  led_out=0x%02h  (#%0d)",
                     $time, led_out, led_event_cnt);
        end

    // -----------------------------------------------------------------------
    //  VCD waveform dump
    // -----------------------------------------------------------------------
    initial begin
        $dumpfile("tb_TopLevel.vcd");
        $dumpvars(0, tb_TopLevel);
    end

    // -----------------------------------------------------------------------
    //  Main stimulus  -  ONE reset, then program runs straight through
    // -----------------------------------------------------------------------
    initial begin
        $display("");
        $display("=========================================");
        $display(" Lab 11 Part A - TopLevelProcessor TB   ");
        $display("=========================================");

        // --- Initialise ---
        reset     = 1;
        switch_in = 6'd0;

        // ==================================================================
        //  PHASE 0: Async reset - combinational checks, no clock edge needed
        // ==================================================================
        $display("\n--- Phase 0: Async reset ---");
        #2;
        CHECK32("PC=0x00 during reset",         pc_obs,           32'h00000000);
        CHECK1 ("led_write_en=0 during reset",  led_write_en,     1'b0);
        CHECK32("led_out=0 during reset",       {26'b0, led_out}, 32'h00000000);
        CHECK32("instr=0x00500E13 at PC=0",     instr_obs,        32'h00500E13);

        // Hold reset for exactly 2 posedges
        @(posedge clk); @(posedge clk); #2;
        CHECK32("PC still 0x00 after 2 clks with reset=1", pc_obs, 32'h00000000);

        // ==================================================================
        //  PHASE 1: Release reset then verify PC and instruction sequence
        //
        //  Release on negedge so the very next posedge is the clean "tick 1".
        //  After the posedge, #2 gives settled combinational values.
        //  At each PC value:
        //    pc_obs   = registered (just loaded)
        //    instr_obs = combinational on pc_obs  (instruction AT that PC)
        // ==================================================================
        $display("\n--- Phase 1: PC and instruction sequence ---");
        @(negedge clk);
        reset = 0;
        #2;
        // No posedge yet - PC still 0, instr still shows instr[0]
        CHECK32("PC=0x00 right after reset=0 (no edge yet)", pc_obs,    32'h00000000);
        CHECK32("instr=0x00500E13 before first tick",         instr_obs, 32'h00500E13);

        @(posedge clk); #2;   // tick 1: PC was 0 ? latches pc_in=4
        CHECK32("tick1: PC=0x04",               pc_obs,    32'h00000004);
        CHECK32("tick1: instr=0x1FF00113",      instr_obs, 32'h1FF00113);

        @(posedge clk); #2;   // tick 2: PC=8
        CHECK32("tick2: PC=0x08",               pc_obs,    32'h00000008);
        CHECK32("tick2: instr=0x30000293",      instr_obs, 32'h30000293);

        @(posedge clk); #2;   // tick 3: PC=0xC
        CHECK32("tick3: PC=0x0C",               pc_obs,    32'h0000000C);
        CHECK32("tick3: instr=0x20000313",      instr_obs, 32'h20000313);

        @(posedge clk); #2;   // tick 4: PC=0x10
        CHECK32("tick4: PC=0x10",               pc_obs,    32'h00000010);
        CHECK32("tick4: instr=0x01C2A023",      instr_obs, 32'h01C2A023);

        @(posedge clk); #2;   // tick 5: PC=0x14
        CHECK32("tick5: PC=0x14",               pc_obs,    32'h00000014);
        CHECK32("tick5: instr=0x00032023",      instr_obs, 32'h00032023);

        @(posedge clk); #2;   // tick 6: PC=0x18
        CHECK32("tick6: PC=0x18",               pc_obs,    32'h00000018);
        CHECK32("tick6: instr=0x0002A583",      instr_obs, 32'h0002A583);

        @(posedge clk); #2;   // tick 7: PC=0x1C  (BEQ)
        CHECK32("tick7: PC=0x1C",               pc_obs,    32'h0000001C);
        CHECK32("tick7: instr=0xFE058EE3",      instr_obs, 32'hFE058EE3);

        // ==================================================================
        //  PHASE 2: ALU results
        //
        //  The ALU is purely combinational.  At any moment:
        //    ALU input A = ReadData1 = regs[rs1] from the CURRENT instruction
        //    ALU input B = imm  (for I-type/S-type, ALUSrc=1)
        //    ALUResult   = A op B
        //
        //  After tick 4 (PC=0x10, sw t3,0(t0)):
        //    rs1 = t0 (x5) which was written at tick 3 with value 0x300
        //    imm = 0  (SW offset 0)
        //    ALUResult = 0x300 + 0 = 0x300  (the store address)
        //
        //  After tick 5 (PC=0x14, sw x0,0(t1)):
        //    rs1 = t1 (x6) = 0x200 (written at tick 4)
        //    ALUResult = 0x200
        // ==================================================================
        $display("\n--- Phase 2: ALU results ---");

        // We are currently at tick 7 (PC=0x1C). Go back to tick 4 state
        // by continuing from current state - the loop will keep repeating
        // so we can observe ALU at PC=0x18 and 0x1C directly.
        // For the ADDI ALU results we check them NOW from the stable loop:

        // At PC=0x1C (BEQ): ALU computes sub for branch compare
        //   A = ReadData1 = regs[a1=x11] = 0 (a1 never got written non-zero)
        //   B = ReadData2 = regs[x0]    = 0
        //   ALUOp=01 (branch) ? ALUControl=SUB ? 0-0=0
        CHECK32("ALU=0 at PC=0x1C (BEQ: 0-0=0)",   alu_result_obs, 32'h00000000);

        // To check ADDI ALU results we observe at PC=0x18 on next loop
        @(posedge clk); #2;   // BEQ taken ? PC=0x18
        // At PC=0x18 (lw a1,0(t0)): ALUSrc=1, A=regs[t0]=0x300, B=imm=0
        CHECK32("ALU=0x300 at PC=0x18 (lw: base addr t0=0x300)", alu_result_obs, 32'h00000300);

        // ==================================================================
        //  PHASE 3: Register file - verify written values
        //  At PC=0x18 (lw a1,0(t0)): rs1=t0(x5)=0x300
        // ==================================================================
        $display("\n--- Phase 3: Register file values ---");
        CHECK32("rd1=0x300 at PC=0x18 (rs1=t0)", rd1_obs, 32'h00000300);

        // Go to PC=0x1C then BEQ takes us to 0x18 again
        @(posedge clk); #2;   // PC=0x1C
        @(posedge clk); #2;   // PC=0x18 (loop)

        // At PC=0x18 again: same register state, no changes
        CHECK32("rd1=0x300 still (t0 unchanged)", rd1_obs, 32'h00000300);

        // ==================================================================
        //  PHASE 4: BEQ loop - confirm PC stays between 0x18 and 0x1C
        // ==================================================================
        $display("\n--- Phase 4: BEQ loop verification ---");

        @(posedge clk); #2;   // PC=0x1C
        CHECK32("PC=0x1C (BEQ)",          pc_obs, 32'h0000001C);
        @(posedge clk); #2;   // Branch taken ? PC=0x18
        CHECK32("PC=0x18 (loop iter 1)",  pc_obs, 32'h00000018);
        @(posedge clk); #2;   // PC=0x1C
        @(posedge clk); #2;   // PC=0x18
        CHECK32("PC=0x18 (loop iter 2)",  pc_obs, 32'h00000018);
        @(posedge clk); #2;
        @(posedge clk); #2;
        CHECK32("PC=0x18 (loop iter 3)",  pc_obs, 32'h00000018);

        // ==================================================================
        //  PHASE 5: LED signals stay low
        //  (programme writes to 0x300 - region=11, not LED region=01/0x100)
        // ==================================================================
        $display("\n--- Phase 5: LED output ---");
        CHECK1 ("led_write_en=0 (addr 0x300 not LED region)", led_write_en, 1'b0);
        CHECK32("led_out=0x00",                               {26'b0, led_out}, 32'h0);

        // ==================================================================
        //  PHASE 6: No X/Z on core signals
        // ==================================================================
        $display("\n--- Phase 6: No X/Z on core signals ---");
        CHECK_NO_X("pc_obs",         pc_obs);
        CHECK_NO_X("instr_obs",      instr_obs);
        CHECK_NO_X("alu_result_obs", alu_result_obs);
        CHECK_NO_X("rd1_obs",        rd1_obs);
        CHECK_NO_X("rd2_obs",        rd2_obs);

        // ==================================================================
        //  PHASE 7: Async reset late in simulation
        // ==================================================================
        $display("\n--- Phase 7: Late async reset ---");
        @(negedge clk);
        reset = 1;
        #2;
        CHECK32("PC=0x00 immediately on late reset",  pc_obs,    32'h00000000);
        CHECK32("instr=0x00500E13 after late reset",  instr_obs, 32'h00500E13);
        CHECK1 ("led_write_en=0 after late reset",    led_write_en, 1'b0);

        @(posedge clk); #2;
        CHECK32("PC stays 0 on posedge while reset=1", pc_obs, 32'h00000000);

        @(negedge clk); reset = 0;
        @(posedge clk); #2;
        CHECK32("PC=0x04 after late reset release",   pc_obs, 32'h00000004);
        @(posedge clk); #2;
        CHECK32("PC=0x08 second tick after release",  pc_obs, 32'h00000008);

        // ==================================================================
        //  Summary
        // ==================================================================
        #10;
        $display("");
        $display("=========================================");
        $display("  SIMULATION SUMMARY");
        $display("  PASS  : %0d", pass_count);
        $display("  FAIL  : %0d", fail_count);
        if (fail_count == 0)
            $display("  STATUS : ALL TESTS PASSED");
        else
            $display("  STATUS : %0d TEST(S) FAILED", fail_count);
        $display("=========================================");
        $display("  HARDWARE NOTE:");
        $display("  led_write_en never fires: t0=0x300 (addr region=11).");
        $display("  AddressDecoder LEDWrite requires region=01 (addr 0x100).");
        $display("  Fix: addi t0,x0,0x100  to light up Basys3 LEDs.");
        $display("=========================================");
        $finish;
    end

    // Watchdog
    initial begin
        #10000;
        $display("[WATCHDOG] t=%0t  PASS=%0d  FAIL=%0d", $time, pass_count, fail_count);
        $finish;
    end

endmodule