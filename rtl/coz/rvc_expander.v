`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.12.2022 01:55:58
// Design Name: 
// Module Name: rvc_expander
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


module rvc_expander(
    input clk_i, rst_i,
    input [31:0] intruction_i
    );
    

    wire [6:0] c_op_code_w = instruction_i[1:0];
    wire [2:0] c_funct3_w  = instruction_i[15:13];
    wire [4:0] c_rd_w      = instruction_i[11:7];
    wire [4:0] c_rs1_w     = instruction_i[19:15];
    wire [4:0] c_rs2_w     = instruction_i[24:20];
    
endmodule
