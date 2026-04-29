
`timescale 1ns / 1ps

module RegisterFile (
    input  wire        clk,
    input  wire        clk_en,      // The ~9.5Hz processor tick
    input  wire        rst,
    input  wire        WriteEnable, // Raw RegWrite signal from MainControl
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);

    // RISC-V has 32 registers. x0 is hardwired to 0, so we only need to store x1-x31.
    reg [31:0] regs [1:31];
    integer i;

    // Sequential Write Logic
    always @(posedge clk) begin
        if (rst) begin
            // Reset all registers to 0
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end 
        else if (clk_en) begin 
            // Only perform a write if clk_en is high (the processor's active cycle)
            // AND the control unit says to write
            // AND we aren't trying to write to the zero register (x0)
            if (WriteEnable && (rd != 5'b0)) begin
                regs[rd] <= WriteData;
            end
        end
    end

    // Combinational Read Logic (Asynchronous)
    // This allows the ALU to see register values immediately within the same cycle.
    assign ReadData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign ReadData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

endmodule