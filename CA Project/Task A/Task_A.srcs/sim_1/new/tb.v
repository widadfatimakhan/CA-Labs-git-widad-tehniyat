`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 11:07:48 AM
// Design Name: 
// Module Name: tb
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

module tb_Task1();
    reg clk, reset, PCSrc;
    reg [31:0] inst;
    wire [31:0] pc_out, pc_next_seq, branch_target, next_pc, imm;
    ProgramCounter u_pc (.clk(clk),.reset(reset),.pc_in(next_pc),.pc_out(pc_out));
    pcAdder u_pcA (.pc(pc_out),.pc_next(pc_next_seq));
    immGen u_immG (.inst(inst),.imm(imm));
    branchAdder u_brA (.pc(pc_out),.imm(imm),.branch_target(branch_target));
    mux2 u_mux (.d0(pc_next_seq),.d1(branch_target),.sel(PCSrc),.y(next_pc));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        reset=1; PCSrc=0; inst=0; #10; reset=0;
        #20; // PC: 0 ? 4 ? 8
        inst=32'hff110093; #10; // ADDI: imm = -15
        inst=32'h00112823; #10; // SW: imm = +16
        inst=32'hfe208ce3; PCSrc=1; #10; // BEQ: branch taken ? PC = 8
        PCSrc=0; #20; $finish;
    end
endmodule
