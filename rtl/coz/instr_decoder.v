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

module instr_decoder (
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

        output enable_rs2_conv_o,
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
    wire [31:0] shamt_w  = {{27{instruction_i[24]}}, instruction_i[24:20]};
    wire [31:0] zimm     = {{27{1'b0}}, instruction_i[19:15]};

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

    //TODO: need to implement illegal_instruction signals for every possible instruction,
    //also need to implement CSR's, and machine mode instructions i believe
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

        case(op_code_w)

            7'b`LUI:   begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_LUI;
                reg_write_r = 1'b1;
                immediate_r = imm_u_w;
            end   
            7'b`AUIPC: begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_AUIPC;
                reg_write_r = 1'b1;
                immediate_r = imm_u_w;
            end   
            7'b`JAL:   begin
                en_alu_r    = 1'b1;
                op_alu_r    = `ALU_JAL;
                reg_write_r = 1'b1;
                immediate_r = imm_j_w;
            end   

            7'b`JALR:  begin
                if(funct3_w == 3'b0) begin
                    en_alu_r       = 1'b1;
                    op_alu_r       = `ALU_JALR;
                    reg_read_rs1_r = 1'b1;
                    reg_write_r    = 1'b1;
                    immediate_r    = imm_i_w;
                end
            end

            7'b`BRANCH: begin //---------------------------------------
                en_branching_unit_r = 1'b1;
                en_alu_r            = 1'b1;
                reg_read_rs1_r      = 1'b1;
                reg_read_rs2_r      = 1'b1;
                immediate_r         = imm_b_w;
                case (funct3_w)
                    3'b`BEQ:   begin
                        op_alu_r        = `ALU_BEQ;
                        op_branching_r  = `BRA_BEQ;
                    end
                    3'b`BNE:   begin
                        op_alu_r        = `ALU_BNE;
                        op_branching_r  = `BRA_BNE;
                    end
                    3'b`BLT:   begin
                        op_alu_r        = `ALU_BLT;
                        op_branching_r  = `BRA_BLT;
                    end
                    3'b`BGE:   begin
                        op_alu_r        = `ALU_BGE;
                        op_branching_r  = `BRA_BGE;

                    end
                    3'b`BLTU:  begin
                        op_alu_r        = `ALU_BLTU;
                        op_branching_r  = `BRA_BLTU;

                    end
                    3'b`BGEU:  begin
                        op_alu_r        = `ALU_BGEU;
                        op_branching_r  = `BRA_BGEU;

                    end
                endcase
            end //-----------------------------------------------------

            7'b`LOAD: begin //-----------------------------------------
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_MEM;
                mem_read_r     = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_write_r    = 1'b1;
                immediate_r    = imm_i_w;
                case (funct3_w)
                    3'b`LB:    begin
                        op_mem_r       = `MEM_LB;
                    end
                    3'b`LH:    begin
                        op_mem_r       = `MEM_LH;
                    end
                    3'b`LW:    begin
                        op_mem_r       = `MEM_LW;
                    end
                    3'b`LBU:   begin
                        op_mem_r       = `MEM_LBU;
                    end
                    3'b`LHU:   begin
                        op_mem_r       = `MEM_LHU;
                    end
                endcase
            end //-----------------------------------------------------

            7'b`STORE: begin //----------------------------------------
                en_mem_r       = 1'b1;
                en_alu_r       = 1'b1;
                op_alu_r       = `ALU_MEM;
                mem_write_r    = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;
                immediate_r    = imm_s_w;
                case(funct3_w)
                    3'b`SB:    begin
                        op_mem_r       = `MEM_SB;
                    end
                    3'b`SH:    begin
                        op_mem_r       = `MEM_SH;
                    end
                    3'b`SW:    begin
                        op_mem_r       = `MEM_SW;
                    end
                endcase
            end //-----------------------------------------------------

            7'b`OP_IMM: begin //---------------------------------------
                en_alu_r       = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_write_r    = 1'b1;
                immediate_r    = imm_i_w;
                case(funct3_w)
                    3'b`ADDI:    begin
                        op_alu_r       = `ALU_ADDI;
                    end
                    3'b`SLTI:    begin
                        op_alu_r       = `ALU_SLTI;
                    end
                    3'b`SLTIU:   begin
                        op_alu_r       = `ALU_SLTIU;
                    end
                    3'b`XORI:    begin
                        op_alu_r       = `ALU_XORI;
                    end
                    3'b`ORI:     begin
                        op_alu_r       = `ALU_ORI;
                    end
                    3'b`ANDI:    begin
                        op_alu_r       = `ALU_ANDI;
                    end
                endcase
                //we can reduce the code size iwth combining SRLI and SRAI by checking their 30th bits
                case({funct7_w, funct3_w})
                    {10'b`SLLI}: begin
                        op_alu_r       = `ALU_SLLI;
                        immediate_r    = shamt_w;
                    end
                    {10'b`SRLI}: begin
                        op_alu_r       = `ALU_SRLI;
                        immediate_r    = shamt_w;
                    end
                    {10'b`SRAI}: begin
                        op_alu_r       = `ALU_SRAI;
                        immediate_r    = shamt_w;
                    end
                endcase

                case({funct7_w, rs2_w, funct3_w})       
                    15'b`RVRS: begin
                        en_alu_r         = 1'b0;
                        en_crypto_unit_r = 1'b1;
                        op_crypto_r  = `CRY_RVRS;
                    end
                    15'b`CNTZ: begin
                        en_alu_r         = 1'b0;
                        en_crypto_unit_r = 1'b1;
                        op_crypto_r  = `CRY_CNTZ;
                    end
                    15'b`CNTP: begin
                        en_alu_r         = 1'b0;
                        en_crypto_unit_r = 1'b1;
                        op_crypto_r  = `CRY_CNTP;
                    end
                endcase
            end //-----------------------------------------------------

            7'b`OP: begin //-------------------------------------------
                en_alu_r       = 1'b1;
                reg_read_rs1_r = 1'b1;
                reg_read_rs2_r = 1'b1;
                reg_write_r    = 1'b1;
                case ({funct7_w, funct3_w})
                    10'b`ADD:    begin
                        op_alu_r       = `ALU_ADD;
                    end
                    10'b`SUB:    begin
                        op_alu_r       = `ALU_SUB;
                    end
                    10'b`SLL:    begin
                        op_alu_r       = `ALU_SLL;
                    end
                    10'b`SLT:    begin
                        op_alu_r       = `ALU_SLT;
                    end
                    10'b`SLTU:   begin
                        op_alu_r       = `ALU_SLTU;
                    end
                    10'b`XOR:    begin
                        op_alu_r       = `ALU_XOR;
                    end
                    10'b`SRL:    begin
                        op_alu_r       = `ALU_SRL;
                    end
                    10'b`SRA:    begin
                        op_alu_r       = `ALU_SRA;
                    end
                    10'b`OR:     begin
                        op_alu_r       = `ALU_OR;
                    end
                    10'b`AND:    begin
                        op_alu_r       = `ALU_AND;
                    end
                    10'b`MUL:    begin
                        op_alu_r       = `ALU_MUL;
                    end
                    10'b`MULH:   begin
                        op_alu_r       = `ALU_MULH;
                    end
                    10'b`MULHSU: begin
                        op_alu_r       = `ALU_MULHSU;
                    end
                    10'b`MULHU:  begin
                        op_alu_r       = `ALU_MULHU;
                    end
                    10'b`DIV:    begin
                        op_alu_r       = `ALU_DIV;
                    end
                    10'b`DIVU:   begin
                        op_alu_r       = `ALU_DIVU;
                    end
                    10'b`REM:    begin
                        op_alu_r       = `ALU_REM;
                    end
                    10'b`REMU:   begin
                        op_alu_r       = `ALU_REMU;
                    end
                    10'b`HMDST:  begin
                        en_alu_r         = 1'b0;
                        en_crypto_unit_r = 1'b1;
                        op_crypto_r    = `CRY_HMDST;
                    end
                    10'b`PKG:    begin
                        en_alu_r         = 1'b0;
                        en_crypto_unit_r = 1'b1;
                        op_crypto_r    = `CRY_PKG;
                    end
                    10'b`SLADD:  begin
                        en_alu_r         = 1'b0;
                        en_crypto_unit_r = 1'b1;
                        op_crypto_r    = `CRY_SLADD;
                    end
                endcase
            end //-----------------------------------------------------

            //TODO: asagidaki korkunc yeri duzenlesem iyi olacak
            7'b`AI: begin //----------------------------------------------
                en_ai_unit_r = 1'b1;
                case({funct7_w, funct3_w})
                    {funct7_w[6], 10'b`CONV_LD_X}: begin
                        op_ai_r = `AI_CONV_LD_X;
                        if(funct7_w[6] == 1'b1)
                            reg_read_rs2_r = 1'b1;
                        reg_read_rs1_r = 1'b1;
                    end
                    {funct7_w[6], 10'b`CONV_LD_W}: begin
                        op_ai_r = `AI_CONV_LD_W;
                        if(funct7_w[6] == 1'b1)
                            reg_read_rs2_r = 1'b1;
                        reg_read_rs1_r = 1'b1;
                    end
                    10'b`CONV_CLR_X: begin
                        if(rs1_w == 5'b0 && rs2_w == 5'b0 && rd_w == 5'b0)
                            op_ai_r = `AI_CONV_CLR_X;
                    end
                    10'b`CONV_CLR_W: begin
                        if(rs1_w == 5'b0 && rs2_w == 5'b0 && rd_w == 5'b0)
                            op_ai_r = `AI_CONV_CLR_X;
                    end
                    10'b`CONV_RUN: begin
                        if(rs1_w == 5'b0 && rs2_w == 5'b0) begin
                            op_ai_r = `AI_CONV_RUN;
                            reg_write_r = 1'b1;
                        end
                    end
                endcase
            end //-----------------------------------------------------

            7'b`SYSTEM: begin
                //need to implement fence, fence.i, ecall & ebreak
                case (funct3_w)
                    3'b`CSRRW:  begin
                    end
                    3'b`CSRRS:  begin
                    end
                    3'b`CSRRC:  begin
                    end
                    3'b`CSRRWI: begin
                        immediate_r = zimm;
                    end
                    3'b`CSRRSI: begin
                        immediate_r = zimm;
                    end
                    3'b`CSRRCI: begin
                        immediate_r = zimm;
                    end

                endcase 
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

    //ahmet hakan'in ozel istegi
    assign enable_rs2_conv = reg_read_rs2_r;
endmodule
