`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.12.2022 18:18:16
// Design Name: 
// Module Name: intsr_decoder
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


`include "instructions.vh"

module intsr_decoder(
        input clk_i, rst_i,
        input [31:0]instruction_i
    );

    wire [6:0] op_code = instruction_i[6:0];
    wire [2:0] funct3  = instruction_i[14:12];
    wire [6:0] funct7  = instruction_i[31:25];
    wire [4:0] rd      = instruction_i[11:7];
    wire [4:0] rs1     = instruction_i[19:15];
    wire [4:0] rs2     = instruction_i[24:20];

    wire [31:0] imm_i  = {{21{instruction_i[31]}}, instruction_i[30:25], instruction_i[24:21], instruction_i[20]};
    wire [31:0] imm_s  = {{21{instruction_i[31]}}, instruction_i[30:25], instruction_i[11:8],  instruction_i[7]};
    wire [31:0] imm_b  = {{20{instruction_i[31]}}, instruction_i[7],     instruction_i[30:25], instruction_i[11:8], 1'b0};
    wire [31:0] imm_u  = {    instruction_i[31],   instruction_i[30:20], instruction_i[19:12], 12'b0};
    wire [31:0] imm_j  = {{12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20],    instruction_i[30:25], instruction_i[24:21], 1'b0};


    always @(*) begin
        case({funct7, funct3, op_code})
                //only op_code
                {funct7, funct3, 7'b`LUI}:   begin

                end   
                {funct7, funct3, 7'b`AUIPC}: begin

                end   
                {funct7, funct3, 7'b`JAL}:   begin

                end   

                //funct3 + op_code
                {funct7, 10'b`JALR}:  begin

                end
                {funct7, 10'b`BEQ}:   begin

                end
                {funct7, 10'b`BNE}:   begin

                end
                {funct7, 10'b`BLT}:   begin

                end
                {funct7, 10'b`BGE}:   begin

                end
                {funct7, 10'b`BLTU}:  begin

                end
                {funct7, 10'b`BGEU}:  begin

                end
                {funct7, 10'b`LB}:    begin

                end
                {funct7, 10'b`LH}:    begin

                end
                {funct7, 10'b`LW}:    begin

                end
                {funct7, 10'b`LBU}:   begin

                end
                {funct7, 10'b`LHU}:   begin

                end
                {funct7, 10'b`SB}:    begin

                end
                {funct7, 10'b`SH}:    begin

                end
                {funct7, 10'b`SW}:    begin

                end
                {funct7, 10'b`ADDI}:  begin

                end
                {funct7, 10'b`SLTI}:  begin

                end
                {funct7, 10'b`SLTIU}: begin

                end
                {funct7, 10'b`XORI}:  begin

                end
                {funct7, 10'b`ORI}:   begin

                end
                {funct7, 10'b`ANDI}:  begin

                end

                //funct7 + funct3 + op_code
                {17'b`SLLI}:   begin

                end
                {17'b`SRLI}:   begin

                end
                {17'b`SRAI}:   begin

                end
                {17'b`ADD}:    begin

                end
                {17'b`SUB}:    begin

                end
                {17'b`SLL}:    begin

                end
                {17'b`SLT}:    begin

                end
                {17'b`SLTU}:   begin

                end
                {17'b`XOR}:    begin

                end
                {17'b`SRL}:    begin

                end
                {17'b`SRA}:    begin

                end
                {17'b`OR}:     begin

                end
                {17'b`AND}:    begin

                end
                {17'b`MUL}:    begin

                end
                {17'b`MULH}:   begin

                end
                {17'b`MULHSU}: begin

                end
                {17'b`MULHU}:  begin

                end
                {17'b`DIV}:    begin

                end
                {17'b`DIVU}:   begin

                end
                {17'b`REM}:    begin

                end
                {17'b`REMU}:   begin

                end
        endcase
    end
endmodule
