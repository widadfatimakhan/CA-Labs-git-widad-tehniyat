//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/11/2026 11:07:48 AM
//// Design Name: 
//// Module Name: tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

//module tb_Task1();
//    reg clk, reset, PCSrc;
//    reg [31:0] inst;
//    wire [31:0] pc_out, pc_next_seq, branch_target, next_pc, imm;
//    ProgramCounter u_pc (.clk(clk),.reset(reset),.pc_in(next_pc),.pc_out(pc_out));
//    pcAdder u_pcA (.pc(pc_out),.pc_next(pc_next_seq));
//    immGen u_immG (.inst(inst),.imm(imm));
//    branchAdder u_brA (.pc(pc_out),.imm(imm),.branch_target(branch_target));
//    mux2 u_mux (.d0(pc_next_seq),.d1(branch_target),.sel(PCSrc),.y(next_pc));
//    initial begin clk=0; forever #5 clk=~clk; end
//    initial begin
//        reset=1; PCSrc=0; inst=0; #10; reset=0;
//        #20; // PC: 0 ? 4 ? 8
//        inst=32'hff110093; #10; // ADDI: imm = -15
//        inst=32'h00112823; #10; // SW: imm = +16
//        inst=32'hfe208ce3; PCSrc=1; #10; // BEQ: branch taken ? PC = 8
//        PCSrc=0; #20; $finish;
//    end
//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: tb_full
//
// Project Part A + Part B combined testbench.
// Instantiates two copies of the processor at the same time:
//   dut_partA - loaded with mem_file.mem        (Lab 10 countdown)
//   dut_partB - loaded with mem_file_taskb.mem  (LUI / JAL / JALR / BLT demo)
//
// No checks, no $display, no dumpvars. Just clock + reset + switch stimulus.
// The waveform window is the output - inspect signals visually.
//////////////////////////////////////////////////////////////////////////////////
module tb_full;

    reg        clk;
    reg        reset;
    reg [5:0]  switches_A;
    reg [5:0]  switches_B;

    wire [5:0] leds_A;
    wire [5:0] leds_B;
    wire       led_we_A;
    wire       led_we_B;

    // ---- Part A: Lab 10 countdown program ----
    TopLevelProcessor #(.MEM_FILE("mem_file.mem")) dut_partA (
        .clk          (clk),
        .reset        (reset),
        .switch_in    (switches_A),
        .led_out      (leds_A),
        .led_write_en (led_we_A)
    );

    // ---- Part B: LUI / JAL / JALR / BLT demo program ----
    TopLevelProcessor #(.MEM_FILE("mem_file_taskb.mem")) dut_partB (
        .clk          (clk),
        .reset        (reset),
        .switch_in    (switches_B),
        .led_out      (leds_B),
        .led_write_en (led_we_B)
    );

    // ---- Clock: 10 ns period (matches the original Task 1 testbench) ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Stimulus ----
    initial begin
        reset      = 1;
        switches_A = 6'd0;
        switches_B = 6'd0;

        // Hold reset for a few clock edges
        #20;
        reset = 0;

        // Give both processors a moment to fetch their setup instructions
        #100;

        // Part A: drive switch value 3 -> countdown 3, 2, 1, 0 on leds_A
        switches_A = 6'd3;

        // Part B: drive switch value 5 -> exercises BLT-taken path
        // (5 < 8, so processor will SRLI a0 by 1 -> displays 2 on leds_B)
        switches_B = 6'd5;
    end

endmodule