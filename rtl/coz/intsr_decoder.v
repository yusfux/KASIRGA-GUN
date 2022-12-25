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
`include "operations.vh"

module intsr_decoder(
        input clk_i, rst_i,
        input [31:0]instruction_i
    );

    wire [6:0] op_code_w = instruction_i[6:0];
    wire [2:0] funct3_w  = instruction_i[14:12];
    wire [6:0] funct7_w  = instruction_i[31:25];
    wire [4:0] rd_w      = instruction_i[11:7];
    wire [4:0] rs1_w     = instruction_i[19:15];
    wire [4:0] rs2_w     = instruction_i[24:20];

    wire [31:0] imm_i_w  = {{21{instruction_i[31]}}, instruction_i[30:25], instruction_i[24:21], instruction_i[20]};
    wire [31:0] imm_s_w  = {{21{instruction_i[31]}}, instruction_i[30:25], instruction_i[11:8],  instruction_i[7]};
    wire [31:0] imm_b_w  = {{20{instruction_i[31]}}, instruction_i[7],     instruction_i[30:25], instruction_i[11:8], 1'b0};
    wire [31:0] imm_u_w  = {    instruction_i[31],   instruction_i[30:20], instruction_i[19:12], 12'b0};
    wire [31:0] imm_j_w  = {{12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20],    instruction_i[30:25], instruction_i[24:21], 1'b0};

    //enable
    reg en_alu;
    reg en_branching_unit;
    reg en_ai_unit;
    reg en_crypto_unit;
    reg en_mem;

    //operations
    reg [5:0]  op_alu;
    reg [2:0]  op_ai;
    reg [2:0]  op_crypto;
    reg [2:0]  op_branching;
    reg [2:0]  op_mem;

    //memory read-write
    reg mem_read;
    reg mem_write;

    //registers read-write
    reg reg_read_rs1;
    reg reg_read_rs2;
    reg reg_write;

    always @(*) begin

        //decoder for I and M extension,
        case({funct7_w, funct3_w, op_code_w})

                //only op_code
                {funct7_w, funct3_w, 7'b`LUI}:   begin
                    op_alu    = `ALU_LUI;
                    reg_write = 1'b1;
                end   
                {funct7_w, funct3_w, 7'b`AUIPC}: begin
                    op_alu    = `ALU_AUIPC;
                    reg_write = 1'b1;
                end   
                {funct7_w, funct3_w, 7'b`JAL}:   begin
                    op_alu    = `ALU_JAL;
                    reg_write = 1'b1;

                end   

                //funct3 + op_code
                {funct7_w, 10'b`JALR}:  begin
                    en_alu    = 1'b1;
                    op_alu    = `ALU_JALR;
                    reg_write = 1'b1;
                end
                {funct7_w, 10'b`BEQ}:   begin
                    en_alu            = 1'b1;
                    en_branching_unit = 1'b1;
                    op_alu            = `ALU_BEQ;
                    op_branching      = `BRA_BEQ;
                    reg_read_rs1      = 1'b1;
                    reg_read_rs2      = 1'b1;

                end
                {funct7_w, 10'b`BNE}:   begin
                    en_branching_unit = 1'b1;
                    en_alu            = 1'b1;
                    op_alu            = `ALU_BNE;
                    op_branching      = `BRA_BNE;
                    reg_read_rs1      = 1'b1;
                    reg_read_rs2      = 1'b1;
                end
                {funct7_w, 10'b`BLT}:   begin
                    en_branching_unit = 1'b1;
                    en_alu            = 1'b1;
                    op_alu            = `ALU_BLT;
                    op_branching      = `BRA_BLT;
                    reg_read_rs1      = 1'b1;
                    reg_read_rs2      = 1'b1;

                end
                {funct7_w, 10'b`BGE}:   begin
                    en_branching_unit = 1'b1;
                    en_alu            = 1'b1;
                    op_alu            = `ALU_BGE;
                    op_branching      = `BRA_BGE;
                    reg_read_rs1      = 1'b1;
                    reg_read_rs2      = 1'b1;

                end
                {funct7_w, 10'b`BLTU}:  begin
                    en_branching_unit = 1'b1;
                    en_alu            = 1'b1;
                    op_alu            = `ALU_BLTU;
                    op_branching      = `BRA_BLTU;
                    reg_read_rs1      = 1'b1;
                    reg_read_rs2      = 1'b1;

                end
                {funct7_w, 10'b`BGEU}:  begin
                    en_branching_unit = 1'b1;
                    en_alu            = 1'b1;
                    op_alu            = `ALU_BGEU;
                    op_branching      = `BRA_BGEU;
                    reg_read_rs1      = 1'b1;
                    reg_read_rs2      = 1'b1;

                end
                {funct7_w, 10'b`LB}:    begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_LB;
                    mem_read     = 1'b1;
                    reg_read_rs1 = 1'b1;
                end
                {funct7_w, 10'b`LH}:    begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_LH;
                    mem_read     = 1'b1;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`LW}:    begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_LW;
                    mem_read     = 1'b1;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`LBU}:   begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_LBU;
                    mem_read     = 1'b1;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`LHU}:   begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_LHU;
                    mem_read     = 1'b1;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`SB}:    begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_SB;
                    mem_write    = 1'b1;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {funct7_w, 10'b`SH}:    begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_SH;
                    mem_write    = 1'b1;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {funct7_w, 10'b`SW}:    begin
                    en_mem       = 1'b1;
                    op_mem       = `MEM_SW;
                    mem_write    = 1'b1;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {funct7_w, 10'b`ADDI}:  begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_ADDI;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`SLTI}:  begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SLTI;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`SLTIU}: begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SLTIU;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`XORI}:  begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_XORI;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`ORI}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_ORI;
                    reg_read_rs1 = 1'b1;

                end
                {funct7_w, 10'b`ANDI}:  begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_ANDI;
                    reg_read_rs1 = 1'b1;
                end

                //funct7 + funct3 + op_code
                {17'b`SLLI}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SLLI;
                    reg_read_rs1 = 1'b1;

                end
                {17'b`SRLI}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SRLI;
                    reg_read_rs1 = 1'b1;

                end
                {17'b`SRAI}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SRAI;
                    reg_read_rs1 = 1'b1;

                end
                {17'b`ADD}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_ADD;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`SUB}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SUB;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`SLL}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SLL;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`SLT}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SLT;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`SLTU}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SLTU;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`XOR}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_XOR;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`SRL}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SRL;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`SRA}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_SRA;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`OR}:     begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_OR;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`AND}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_AND;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`MUL}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_MUL;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`MULH}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_MULH;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`MULHSU}: begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_MULHSU;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`MULHU}:  begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_MULHU;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`DIV}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_DIV;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`DIVU}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_DIVU;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`REM}:    begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_REM;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
                {17'b`REMU}:   begin
                    en_alu       = 1'b1;
                    op_alu       = `ALU_REMU;
                    reg_read_rs1 = 1'b1;
                    reg_read_rs2 = 1'b1;

                end
        endcase

    end
endmodule
