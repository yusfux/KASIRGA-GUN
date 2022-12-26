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

module instr_decoder(
        //input clk_i, rst_i,
        //--------------------------signals from "rvc expander"--------------------------
        input [31:0] instruction_i,
        //-------------------------------------------------------------------------------

        //--------------------------signals to "execute stage"---------------------------
        output en_alu_o,
        output en_branching_unit_o,
        output en_ai_unit_o,
        output en_crypto_unit_o,
        output en_mem_o,

        output [5:0] op_alu_o,
        output [2:0] op_ai_o,
        output [2:0] op_crypto_o,
        output [2:0] op_branching_o,
        output [2:0] op_mem_o,

        output [31:0] immediate_o,

        output mem_read_o,
        output mem_write_o,
        //-------------------------------------------------------------------------------

        //--------------------------signals to "register file"---------------------------
        output reg_read_rs1_o,
        output reg_read_rs2_o,
        output reg_write_o,

        output [4:0] reg_rs1_o,
        output [4:0] reg_rs2_o,
        output [4:0] reg_rd_o
        //-------------------------------------------------------------------------------
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
    reg en_alu_r;
    reg en_branching_unit_r;
    reg en_ai_unit_r;
    reg en_crypto_unit_r;
    reg en_mem_r;

    //operations
    reg [5:0]  op_alu_r;
    reg [2:0]  op_ai_r;
    reg [2:0]  op_crypto_r;
    reg [2:0]  op_branching_r;
    reg [2:0]  op_mem_r;

    //memory read-write
    reg mem_read_r;
    reg mem_write_r;

    //registers read-write
    reg reg_read_rs1_r;
    reg reg_read_rs2_r;
    reg reg_write_r;

    //immediate
    reg [31:0] immediate_r;

    always @(*) begin
        en_alu_r            = 1'b0;
        en_branching_unit_r = 1'b0;
        en_ai_unit_r        = 1'b0;
        en_crypto_unit_r    = 1'b0;
        en_mem_r            = 1'b0;
        
        op_alu_r            = 1'b0;
        op_ai_r             = 1'b0;
        op_crypto_r         = 1'b0;
        op_branching_r      = 1'b0;
        op_mem_r            = 1'b0;

        mem_read_r          = 1'b0;
        mem_write_r         = 1'b0;

        reg_read_rs1_r      = 1'b0;
        reg_read_rs2_r      = 1'b0;
        reg_write_r         = 1'b0;

        immediate_r         = 32'b0; 

        //TODO: NEED TO IMPLEMNENT AI & CRYPTO INSTRUCTIONS
        //cok daha kompakt hale getirilebilir, ayni olanlar bilestirilerek bakilabilir bu sekliyle cok gereksiz uzun

        //decoder for I and M extension,
        case({funct7_w, funct3_w, op_code_w})

            //only op_code
            {funct7_w, funct3_w, 7'b`LUI}:   begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_LUI;
                reg_write_r = 1'b1;
                immediate_r = imm_u_w;
            end   
            {funct7_w, funct3_w, 7'b`AUIPC}: begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_AUIPC;
                reg_write_r = 1'b1;
                immediate_r = imm_u_w;
            end   
            {funct7_w, funct3_w, 7'b`JAL}:   begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_JAL;
                reg_write_r = 1'b1;
                immediate_r = imm_j_w;
            end   

            //funct3 + op_code
            {funct7_w, 10'b`JALR}:  begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_JALR;
                reg_write_r = 1'b1;
                immediate_r = imm_i_w;
            end
            {funct7_w, 10'b`BEQ}:   begin
                en_alu_r            = 1'b1;
                en_branching_unit_r = 1'b1;
                op_alu_r            = `ALU_BEQ;
                op_branching_r      = `BRA_BEQ;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;

            end
            {funct7_w, 10'b`BNE}:   begin
                en_branching_unit_r = 1'b1;
                en_alu_r            = 1'b1;
                op_alu_r            = `ALU_BNE;
                op_branching_r      = `BRA_BNE;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;
            end
            {funct7_w, 10'b`BLT}:   begin
                en_branching_unit_r = 1'b1;
                en_alu_r            = 1'b1;
                op_alu_r            = `ALU_BLT;
                op_branching_r      = `BRA_BLT;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;

            end
            {funct7_w, 10'b`BGE}:   begin
                en_branching_unit_r = 1'b1;
                en_alu_r            = 1'b1;
                op_alu_r            = `ALU_BGE;
                op_branching_r      = `BRA_BGE;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;

            end
            {funct7_w, 10'b`BLTU}:  begin
                en_branching_unit_r = 1'b1;
                en_alu_r            = 1'b1;
                op_alu_r            = `ALU_BLTU;
                op_branching_r      = `BRA_BLTU;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;

            end
            {funct7_w, 10'b`BGEU}:  begin
                en_branching_unit_r = 1'b1;
                en_alu_r            = 1'b1;
                op_alu_r            = `ALU_BGEU;
                op_branching_r      = `BRA_BGEU;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;

            end
            {funct7_w, 10'b`LB}:    begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_LB;
                mem_read_r     = 1'b1;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;
            end
            {funct7_w, 10'b`LH}:    begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_LH;
                mem_read_r     = 1'b1;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`LW}:    begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_LW;
                mem_read_r     = 1'b1;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`LBU}:   begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_LBU;
                mem_read_r     = 1'b1;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`LHU}:   begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_LHU;
                mem_read_r     = 1'b1;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`SB}:    begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_SB;
                mem_write_r    = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;
                immediate_r    = imm_s_w;

            end
            {funct7_w, 10'b`SH}:    begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_SH;
                mem_write_r    = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;
                immediate_r    = imm_s_w;

            end
            {funct7_w, 10'b`SW}:    begin
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_mem_r       = `MEM_SW;
                mem_write_r    = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;
                immediate_r    = imm_s_w;

            end
            {funct7_w, 10'b`ADDI}:  begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_ADDI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`SLTI}:  begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SLTI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`SLTIU}: begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SLTIU;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`XORI}:  begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_XORI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`ORI}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_ORI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;

            end
            {funct7_w, 10'b`ANDI}:  begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_ANDI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = imm_i_w;
            end

            //funct7 + funct3 + op_code
            {17'b`SLLI}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SLLI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = {{27{instruction_i[24]}}, instruction_i[24:20]};

            end
            {17'b`SRLI}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SRLI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = {{27{instruction_i[24]}}, instruction_i[24:20]};

            end
            {17'b`SRAI}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SRAI;
                reg_read_rs1_r = 1'b1;
                immediate_r    = {{27{instruction_i[24]}}, instruction_i[24:20]};

            end
            {17'b`ADD}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_ADD;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`SUB}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SUB;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`SLL}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SLL;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`SLT}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SLT;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`SLTU}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SLTU;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`XOR}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_XOR;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`SRL}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SRL;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`SRA}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_SRA;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`OR}:     begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_OR;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`AND}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_AND;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`MUL}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_MUL;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`MULH}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_MULH;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`MULHSU}: begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_MULHSU;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`MULHU}:  begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_MULHU;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`DIV}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_DIV;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`DIVU}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_DIVU;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`REM}:    begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_REM;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
            {17'b`REMU}:   begin
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_REMU;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;

            end
        endcase
    end

    assign en_alu_o            = en_alu_r;
    assign en_branching_unit_o = en_branching_unit_r;
    assign en_ai_unit_o        = en_ai_unit_r;
    assign en_crypto_unit_o    = en_crypto_unit_r;
    assign en_mem_o            = en_mem_r;

    assign op_alu_o       = op_alu_r;
    assign op_ai_o        = op_ai_r;
    assign op_crypto_o    = op_crypto_r;
    assign op_branching_o = op_branching_r;
    assign op_mem_o       = op_mem_r;

    assign mem_read_o  = mem_read_r;
    assign mem_write_o = mem_write_r;

    assign reg_read_rs1_o = reg_read_rs1_r;
    assign reg_read_rs2_o = reg_read_rs2_r;
    assign reg_write_o    = reg_write_r;

    assign immediate_o = immediate_r;
    assign reg_rs1_o   = rs1_w;
    assign reg_rs2_o   = rs2_w;
    assign reg_rd_o    = rd_w;

endmodule
