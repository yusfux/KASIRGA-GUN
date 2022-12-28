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

`include "instructions.vh"

module rvc_expander(
        //input  clk_i, rst_i,

        //--------------------------signals from "fetch stage"---------------------------
        input  [31:0] instruction_i,
        //-------------------------------------------------------------------------------


        //-----------------------signals to "instruction decoder"------------------------
        output [31:0] instruction_o
        //-------------------------------------------------------------------------------
    );
    

    wire [1:0] c_op_code_w  = instruction_i[1:0];
    wire [2:0] c_funct3_w   = instruction_i[15:13];
    wire [3:0] c_funct4_w   = instruction_i[15:12];

    //they are here just for paying respect to the time that I've spent while I was trying to understand their encodings
    wire [5:0]  c_imm_ci    = {instruction_i[3:2], instruction_i[12], instruction_i[6:4]};
    wire [7:0]  c_imm_css   = {instruction_i[8:7], instruction_i[12:9], 2'b00};
    wire [9:0]  c_imm_ciw   = {instruction_i[10:7], instruction_i[12:11], instruction_i[5], instruction_i[6], 2'b00};
    wire [6:0]  c_imm_cl    = {instruction_i[5], instruction_i[12:10], instruction_i[6], 2'b00};
    wire [6:0]  c_imm_cs    = {instruction_i[5], instruction_i[12:10], instruction_i[6], 2'b00};
    wire [10:0] c_imm_cj    = {instruction_i[12], instruction_i[8], instruction_i[10:9], instruction_i[6], instruction_i[7], instruction_i[2], instruction_i[11], instruction_i[5:3]};
    wire [8:0]  c_imm_cb    = {instruction_i[12], instruction_i[6:5], instruction_i[2], instruction_i[11:10], instruction_i[4:3]};

    wire [4:0] c_rd_w       = instruction_i[11:7];
    wire [4:0] c_rs1_w      = instruction_i[11:7];
    wire [4:0] c_rs2_w      = instruction_i[6:2];

    //populer registers, which corresponds to x8 to x15 for CIW, CL, CS and CB types.
    wire [4:0] c_3rd_w      = {2'b01, instruction_i[4:2]};
    wire [4:0] c_3rs1_w     = {2'b01, instruction_i[9:7]};
    wire [4:0] c_3rs2_w     = {2'b01, instruction_i[4:2]};

    reg [31:0] expanded_instruction_r;

    always @(*) begin
        //this may be illegal instruction, so it would be better not to use it for default value
        //We consider it a feature that any length of instruction containing all zero bits is not legal, as
        //this quickly traps erroneous jumps into zeroed memory regions. Similarly, we also reserve the
        //instruction encoding containing all ones to be an illegal instruction,
        expanded_instruction_r = 32'h0000_0000;

        case ({c_funct3_w, c_op_code_w})

            5'b`C_ADDI4SPN: begin   //-> addi rd', x2, imm
                expanded_instruction_r = {2'b00, instruction_i[10:7], instruction_i[12:11], instruction_i[5], instruction_i[6], 2'b00, 5'b00010, 3'b000, c_3rd_w, 7'b`OP_IMM};
            end 
            5'b`C_LW:       begin   //-> lw rd', imm(rs1')
                expanded_instruction_r = {5'b00000, instruction_i[5], instruction_i[12:10], instruction_i[6], 2'b00, c_3rs1_w, 3'b010, c_3rd_w, 7'b`LOAD};
            end

            5'b`C_SW:       begin   //-> sw rs2', imm(rs1')
                expanded_instruction_r = {5'b00000, instruction_i[5], instruction_i[12], c_3rs2_w, c_3rs1_w, 3'b010, instruction_i[11:10], instruction_i[6], 2'b00, 7'b`STORE};
            end

            5'b`C_JAL:      begin   //-> jal x1, imm
                expanded_instruction_r = {instruction_i[12], instruction_i[8], instruction_i[10:9], instruction_i[6], instruction_i[7], instruction_i[2], instruction_i[11], instruction_i[5:3], {9{instruction_i[12]}}, 5'b00001, 7'b`JAL};
            end
            
            5'b`C_J:        begin   //-> jal x0, imm
                expanded_instruction_r = {instruction_i[12], instruction_i[8], instruction_i[10:9], instruction_i[6], instruction_i[7], instruction_i[2], instruction_i[11], instruction_i[5:3], {9{instruction_i[12]}}, 5'b00000, 7'b`JAL};
            end

            5'b`C_BEQZ:     begin   //-> beq rs1', x0, imm
                expanded_instruction_r = {{4{instruction_i[12]}}, instruction_i[6:5], instruction_i[2], 5'b00000, c_3rs1_w, 3'b000, instruction_i[11:10], instruction_i[4:3], instruction_i[12], 7'b`BRANCH};
            end

            5'b`C_BNEZ:     begin   //-> bne rs1', x0, imm
                expanded_instruction_r = {{4{instruction_i[12]}}, instruction_i[6:5], instruction_i[2], 5'b00000, c_3rs1_w, 3'b001, instruction_i[11:10], instruction_i[4:3], instruction_i[12], 7'b`BRANCH};
            end

            5'b`C_SWSP:      begin  //-> sw rs2, imm(x2)
                expanded_instruction_r = {4'b0000, instruction_i[8:7], instruction_i[12], c_rs2_w, 5'b000010, 3'b010, instruction_i[11:9], 2'b00, 7'b`STORE};
            end

            5'b000_01:      begin   //C_ADDI & C_NOP
                if     (c_rd_w != 5'b0) begin    //-> addi rd, rd, nzimm
                    expanded_instruction_r = {{6{instruction_i[12]}}, instruction_i[12], instruction_i[6:2], c_rs1_w, 3'b000, c_rd_w, 7'b`OP_IMM};
                end
                else if(c_rd_w == 5'b0) begin   //-< addi x0, x0, 0
                    expanded_instruction_r = {{6{instruction_i[12]}}, instruction_i[12], instruction_i[6:2], c_rs1_w, 3'b000, c_rd_w, 7'b`OP_IMM};
                end
            end

            5'b010_01:      begin   //C_LI
                if(c_rd_w != 5'b0) begin    //-> addi rd, x0, nzimm
                    expanded_instruction_r = {{6{instruction_i[12]}}, instruction_i[12], instruction_i[6:2], 5'b00000, 3'b000, c_rd_w, 7'b`OP_IMM};
                end
            end

            5'b011_01:      begin   //C_ADDI16SP & C_LUI
                if     (c_rd_w == 5'b00010) begin   //-> addi x2, x2, nzimm
                    expanded_instruction_r = {{3{instruction_i[12]}}, instruction_i[4:3], instruction_i[5], instruction_i[2], instruction_i[6], 4'b0000, 5'b000010, 3'b000, 5'b000010, 7'b`OP_IMM};
                end
                else if(c_rd_w != 5'b00000 && c_rd_w != 5'b00010) begin //-> lui rd, imm
                    expanded_instruction_r = {{15{instruction_i[12]}}, instruction_i[6:2], c_rd_w, 7'b`LUI};

                end
            end

            5'b000_10:      begin   //C_SLLI
                if(c_rd_w != 5'b00000) begin    //-> slli rd, rd, shamt
                    expanded_instruction_r =  {7'b0000000, instruction_i[6:2], c_rd_w, 3'b001, c_rd_w, 7'b`OP_IMM};
                end
            end

            5'b010_10:      begin   //C_LWSP
                if(c_rd_w != 5'b00000) begin    //-> lw rd, imm(x2)
                    expanded_instruction_r =  {4'b0000, instruction_i[3:2], instruction_i[12], instruction_i[6:4], 2'b00, 5'b00010, 3'b010, c_rd_w, 7'b`LOAD};
                end
            end

            5'b100_01:      begin   //C_SRLI & C_SRAI & C_ANDI & C_SUB & C_XOR & C_OR & C_AND 
                if     (instruction_i[11:10] == 2'b00) begin    //-> srli rd, rd, shamt
                    expanded_instruction_r = {7'b0000000, instruction_i[6:2], c_3rs1_w, 3'b101, c_3rs1_w, 7'b`OP_IMM};
                end
                else if(instruction_i[11:10] == 2'b01) begin    //-> srai rd, rd, shamt
                    expanded_instruction_r = {7'b0100000, instruction_i[6:2], c_3rs1_w, 3'b101, c_3rs1_w, 7'b`OP_IMM};
                end
                else if(instruction_i[11:10] == 2'b10) begin    //-> andi rd, rd, imm
                    expanded_instruction_r = {{6{instruction_i[12]}}, instruction_i[12], instruction_i[6:2], c_3rs1_w, 3'b111, c_3rs1_w, 7'b`OP_IMM};
                end
                else if(instruction_i[12:10] == 3'b011 && instruction_i[6:5] == 2'b00) begin    //-> sub rd', rd', rs2'
                    expanded_instruction_r = {7'b0100000, c_3rs2_w, c_3rs1_w, 3'b000, c_3rs1_w, 7'b`OP};
                end
                else if(instruction_i[12:10] == 3'b011 && instruction_i[6:5] == 2'b01) begin    //-> xor rd', rd', rs2'
                    expanded_instruction_r = {7'b0000000, c_3rs2_w, c_3rs1_w, 3'b100, c_3rs1_w, 7'b`OP};
                end
                else if(instruction_i[12:10] == 3'b011 && instruction_i[6:5] == 2'b10) begin    //-> or  rd', rd', rs2'
                    expanded_instruction_r = {7'b0000000, c_3rs2_w, c_3rs1_w, 3'b110, c_3rs1_w, 7'b`OP};
                end
                else if(instruction_i[12:10] == 3'b011 && instruction_i[6:5] == 2'b11) begin    //-> and rd', rd', rs2'
                    expanded_instruction_r = {7'b0000000, c_3rs2_w, c_3rs1_w, 3'b111, c_3rs1_w, 7'b`OP};
                end
            end

            5'b100_10:      begin   //C_JR & C_MV & C_JALR & C_ADD
                if     (instruction_i[12] == 1'b0 && c_rd_w != 5'b00000 && c_rs2_w == 5'b00000) begin   //-> jalr x0, rd, 0
                    expanded_instruction_r = {12'b000000000000, c_rs1_w, 3'b000, 5'b000000, 7'b`JALR};
                end
                else if((instruction_i[12] == 1'b0) && (c_rd_w != 5'b00000) && (c_rs2_w != 5'b00000)) begin   //-> add rd, x0, rs2
                    expanded_instruction_r = {7'b0000000, c_rs2_w, 5'b000000, 3'b000, c_rd_w, 7'b`OP};
                end
                else if(instruction_i[12] == 1'b1 && c_rd_w != 5'b00000 && c_rs2_w == 5'b00000) begin   //-> jalr x1, rs1, 0
                    expanded_instruction_r = {12'b000000000000, c_rs1_w, 3'b000, 5'b00001, 7'b`JALR};
                end
                else if(instruction_i[12] == 1'b1 && c_rd_w != 5'b00000 && c_rs2_w != 5'b00000) begin   //-> add rd, rd, rs2
                    expanded_instruction_r = {7'b0000000, c_rs2_w, c_rs1_w, 3'b000, c_rs1_w, 7'b`OP};
                end
            end

        endcase
    end   

    assign instruction_o = (instruction_i[1:0] == 2'b11) ? instruction_i : expanded_instruction_r;
endmodule
