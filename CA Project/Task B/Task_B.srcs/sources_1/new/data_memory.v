`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 10:37:45 AM
// Design Name: 
// Module Name: data_memory
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

//module DataMemory(
//    input clk,
//    input MemWrite,
//    input MemRead,
//    input [31:0] address,      // Changed from [7:0]
//    input [31:0] write_data,   // Changed from [5:0]
//    output reg [31:0] read_data // Changed from [5:0]
//);
//    // Use word alignment (address[9:2]) for a 256-word memory
//    reg [31:0] memory [0:255]; 
    
//    always @(posedge clk) begin
//        if (MemWrite)
//            memory[address[9:2]] <= write_data;
//    end

//    always @(*) begin
//        if (MemRead)
//            read_data = memory[address[9:2]];
//        else
//            read_data = 32'b0;
//    end
//endmodule

module DataMemory(
    input clk,
    input MemWrite,
    input MemRead,
    input [2:0] funct3,         // op size/sign: matches RISC-V funct3
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255];

    wire [31:0] word = memory[address[9:2]];
    wire [1:0]  boff = address[1:0];   // byte offset within the word

    // -------- WRITE --------
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: begin // SB
                    case (boff)
                        2'b00: memory[address[9:2]][7:0]   <= write_data[7:0];
                        2'b01: memory[address[9:2]][15:8]  <= write_data[7:0];
                        2'b10: memory[address[9:2]][23:16] <= write_data[7:0];
                        2'b11: memory[address[9:2]][31:24] <= write_data[7:0];
                    endcase
                end
                3'b001: begin // SH
                    if (boff[1] == 1'b0)
                        memory[address[9:2]][15:0]  <= write_data[15:0];
                    else
                        memory[address[9:2]][31:16] <= write_data[15:0];
                end
                3'b010: memory[address[9:2]] <= write_data;   // SW
                default: memory[address[9:2]] <= write_data;
            endcase
        end
    end

    // -------- READ --------
    reg [7:0]  b;
    reg [15:0] h;

    always @(*) begin
        // pick the addressed byte
        case (boff)
            2'b00: b = word[7:0];
            2'b01: b = word[15:8];
            2'b10: b = word[23:16];
            2'b11: b = word[31:24];
        endcase

        // pick the addressed halfword (upper or lower)
        h = boff[1] ? word[31:16] : word[15:0];

        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{b[7]}},  b};   // LB  (signed)
                3'b001: read_data = {{16{h[15]}}, h};   // LH  (signed)
                3'b010: read_data = word;               // LW
                3'b100: read_data = {24'b0, b};         // LBU (zero-extended)
                3'b101: read_data = {16'b0, h};         // LHU (zero-extended)
                default: read_data = word;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
endmodule