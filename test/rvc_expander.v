`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yusuf Aydın
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
        //--------------------------signals from "fetch stage"---------------------------
        input  [31:0] instruction_i,
        //-------------------------------------------------------------------------------


        //-----------------------signals to "instruction decoder"------------------------
        output [31:0] instruction_o,
        output        is_compressed_o,
        //-------------------------------------------------------------------------------

        //-----------------------signals to "control status unit"------------------------
        output exception_illegal_instruction_o
        //-------------------------------------------------------------------------------
    );
    

    wire [1:0] c_op_code_w  = instruction_i[1:0];
    wire [2:0] c_funct3_w   = instruction_i[15:13];
    wire [3:0] c_funct4_w   = instruction_i[15:12];

    wire [4:0] c_rd_w       = instruction_i[11:7];
    wire [4:0] c_rs1_w      = instruction_i[11:7];
    wire [4:0] c_rs2_w      = instruction_i[6:2];

    //populer registers, which corresponds to x8 to x15 for CIW, CL, CS and CB types.
    wire [4:0] c_3rd_w      = {2'b01, instruction_i[4:2]};
    wire [4:0] c_3rs1_w     = {2'b01, instruction_i[9:7]};
    wire [4:0] c_3rs2_w     = {2'b01, instruction_i[4:2]};

    reg [31:0] expanded_instruction_r;
    reg        exception_illegal_instruction_r;

    always @(*) begin

        expanded_instruction_r = 32'h0000_0000;
        exception_illegal_instruction_r  = 1'b0;

        case ({c_funct3_w, c_op_code_w})

            5'b`C_ADDI4SPN: begin   //-> addi rd', x2, imm
                if(instruction_i[12:5] == 8'b0) //reserved nzuimm = 0
                    exception_illegal_instruction_r = 1'b1;
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
                if({instruction_i[12], instruction_i[6:2]} == 6'b0) //reserved nzimm = 0 for both ADDI16SP and LUI
                    exception_illegal_instruction_r = 1'b1;

                if     (c_rd_w == 5'b00010) begin   //-> addi x2, x2, nzimm
                    expanded_instruction_r = {{3{instruction_i[12]}}, instruction_i[4:3], instruction_i[5], instruction_i[2], instruction_i[6], 4'b0000, 5'b000010, 3'b000, 5'b000010, 7'b`OP_IMM};
                end
                else if(c_rd_w != 5'b00000 && c_rd_w != 5'b00010) begin //-> lui rd, imm
                    expanded_instruction_r = {{15{instruction_i[12]}}, instruction_i[6:2], c_rd_w, 7'b`LUI};

                end
            end

            5'b000_10:      begin   //C_SLLI
                if(c_rd_w != 5'b00000) begin    //-> slli rd, rd, shamt
                    if(instruction_i[12] == 1'b1)   //non standart extension nzuimm[5] = 1
                        exception_illegal_instruction_r = 1'b1;
                    expanded_instruction_r =  {7'b0000000, instruction_i[6:2], c_rd_w, 3'b001, c_rd_w, 7'b`OP_IMM};
                end
            end

            5'b010_10:      begin   //C_LWSP
                if(c_rd_w == 5'b00000)    //-> lw rd, imm(x2)
                    exception_illegal_instruction_r = 1'b1;   //reserved rd=0
                expanded_instruction_r =  {4'b0000, instruction_i[3:2], instruction_i[12], instruction_i[6:4], 2'b00, 5'b00010, 3'b010, c_rd_w, 7'b`LOAD};
            end

            5'b100_01:      begin   //C_SRLI & C_SRAI & C_ANDI & C_SUB & C_XOR & C_OR & C_AND 
                if     (instruction_i[11:10] == 2'b00) begin    //-> srli rd, rd, shamt
                    if(instruction_i[12] == 1'b1)   //non standart extension nzuimm[5] = 1
                        exception_illegal_instruction_r = 1'b1;
                    expanded_instruction_r = {7'b0000000, instruction_i[6:2], c_3rs1_w, 3'b101, c_3rs1_w, 7'b`OP_IMM};
                end
                else if(instruction_i[11:10] == 2'b01) begin    //-> srai rd, rd, shamt
                    if(instruction_i[12] == 1'b1)   //non standart extension nzuimm[5] = 1
                        exception_illegal_instruction_r = 1'b1;
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
                if     (instruction_i[12] == 1'b0 && c_rs2_w == 5'b00000) begin   //-> jalr x0, rd, 0
                    if(c_rs1_w == 5'b00000)  //reserved rs1 = 0
                        exception_illegal_instruction_r = 1'b1;
                    expanded_instruction_r = {12'b000000000000, c_rs1_w, 3'b000, 5'b000000, 7'b`JALR};
                end
                else if((instruction_i[12] == 1'b0) && (c_rs2_w != 5'b00000)) begin   //-> add rd, x0, rs2 | since rd != 0 is HINT, we can ignore this check
                    expanded_instruction_r = {7'b0000000, c_rs2_w, 5'b000000, 3'b000, c_rd_w, 7'b`OP};
                end
                else if(instruction_i[12] == 1'b1 && c_rd_w != 5'b00000 && c_rs2_w == 5'b00000) begin   //-> jalr x1, rs1, 0
                    expanded_instruction_r = {12'b000000000000, c_rs1_w, 3'b000, 5'b00001, 7'b`JALR};
                end
                else if(instruction_i[12] == 1'b1 && c_rs2_w != 5'b00000) begin   //-> add rd, rd, rs2 | since rd != 0 is HINT, we can ignore this check
                    expanded_instruction_r = {7'b0000000, c_rs2_w, c_rs1_w, 3'b000, c_rs1_w, 7'b`OP};
                end
            end

            default:        begin
                //encoding with bits instruction[15:0] all zeros are defined as illegal instruction
                //the encoding with bits [31:0] all ones are also illegal
                exception_illegal_instruction_r = 1'b1;
            end
        endcase
    end   

    assign is_compressed_o                 = (instruction_i[1:0] == 2'b11) ? 0 : 1;
    assign instruction_o                   = (instruction_i[1:0] == 2'b11) ? instruction_i : expanded_instruction_r;
    assign exception_illegal_instruction_o = exception_illegal_instruction_r && (instruction_i[1:0] != 2'b11);
endmodule
