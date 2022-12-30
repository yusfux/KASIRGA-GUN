`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.12.2022 04:01:57
// Design Name: 
// Module Name: wrapper_decode
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


module wrapper_decode(
        input clk_i, rst_i,

        //------------------------input signals from "fetch stage"-----------------------
        input [31:0]instruction_i,
        input [31:0]program_counter_i,
        input       branch_taken_i,
        //-------------------------------------------------------------------------------

        //-------------------------input signals from "write-back"-----------------------
        input        reg_write_wb_i,
        input [4:0]  reg_rd_wb_i,
        input [31:0] reg_rd_data_wb_i,
        //-------------------------------------------------------------------------------


        //---------output signals from "instruction decoder" to "execute stage" ---------
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

        output mem_read_o,
        output mem_write_o,

        output reg_write_o,
        output [4:0] reg_rd_o,

        output [31:0] immediate_o,

        output enable_rs2_conv_o,
        //-------------------------------------------------------------------------------

        //------------output signals from "register file" to "execute stage" ------------
        output [31:0] reg_rs1_data_o,
        output [31:0] reg_rs2_data_o,
        //-------------------------------------------------------------------------------

        //-------------output signals from "fetch stage" to "execute stage" -------------
        output [31:0] program_counter_o,
        output        branch_taken_o,
        //-------------------------------------------------------------------------------

        //----------------------output signals to stall the pipeline---------------------
        output stall_decode_o,
        output illegal_instruction_o
        //-------------------------------------------------------------------------------
    );

    reg [31:0] instruction_r;
    reg [31:0] program_counter_r;
    reg        branch_taken_r;

    // output signals from "rvc_expander" to "instr_decoder"
    wire [31:0] expanded_instruction_w;

    // output signals from "instr_decoder" to "register_file"
    wire reg_read_rs1_w;
    wire reg_read_rs2_w;
    wire reg_write_w;

    wire [4:0] reg_rs1_w;
    wire [4:0] reg_rs2_w;
    wire [4:0] reg_rd_w;


    //TODO: need to clock the signals that are coming from prev stages in every wrapper

    rvc_expander  compressed_expander (
        .instruction_i(instruction_r),

        .instruction_o(expanded_instruction_w),
        .illegal_instruction_o(illegal_instruction_o)
    );

    instr_decoder instruction_decoder (
        .instruction_i(expanded_instruction_w),

        .en_alu_o(en_alu_o),
        .en_branching_unit_o(en_branching_unit_o),
        .en_ai_unit_o(en_ai_unit_o),
        .en_crypto_unit_o(en_crypto_unit_o),
        .en_mem_o(en_mem_o),
        .op_alu_o(op_alu_o),
        .op_ai_o(op_ai_o),
        .op_crypto_o(op_crypto_o),
        .op_branching_o(op_branching_o),
        .op_mem_o(op_mem_o),
        .immediate_o(immediate_o),
        .mem_read_o(mem_read_o),
        .mem_write_o(mem_write_o),
        .enable_rs2_conv_o(enable_rs2_conv_o),
        .reg_read_rs1_o(reg_read_rs1_w),
        .reg_read_rs2_o(reg_read_rs2_w),
        .reg_write_o(reg_write_w),
        .reg_rs1_o(reg_rs1_w),
        .reg_rs2_o(reg_rs2_w),
        .reg_rd_o(reg_rd_w)
    );

    register_file register_file       (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .reg_read_rs1_i(reg_read_rs1_w),
        .reg_read_rs2_i(reg_read_rs2_w),
        .reg_rs1_i(reg_rs1_w),
        .reg_rs2_i(reg_rs2_w),
        .reg_write_i(reg_write_w),
        .reg_rd_i(reg_rd_w),
        .reg_write_wb_i(reg_write_wb_i),
        .reg_rd_wb_i(reg_rd_wb_i),
        .reg_rd_data_wb_i(reg_rd_data_wb_i),
        
        .reg_rs1_data_o(reg_rs1_data_o),
        .reg_rs2_data_o(reg_rs2_data_o),
        .stall_register_file_o(stall_decode_o)
    );

    //TODO: check if signals from write-backs stage need to get clocked
    always @(posedge clk_i) begin
        instruction_r     <= instruction_i;
        program_counter_r <= program_counter_i;
        branch_taken_r    <= branch_taken_i;
    end

    assign program_counter_o = program_counter_r;
    assign branch_taken_o    = branch_taken_r;

    assign reg_rd_o          = reg_rd_w;
    assign reg_write_o       = reg_write_w;

endmodule
