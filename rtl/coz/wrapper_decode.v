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

        //FROM FETCH STAGE - POSEDGE
        input [31:0] instruction_i,
        input [31:0] program_counter_i,
        input branch_taken_i,

        //FROM WRITE-BACK STAGE - COMBINATIONAL
        input        reg_write_wb_i,
        input [4:0]  reg_rd_wb_i,
        input [31:0] reg_rd_data_wb_i,

        //FROM PIPELINE CONTROLLER - COMBINATONAL
        input stall_decode_stage_i,
        input flush_decode_stage_i,
        input en_exception_i,
        input [2:0]  exception_cause_i,
        input [31:0] exception_adress_i,
        input [31:0] exception_program_counter_i,

        //TO PIPELINE CONTROLLER - COMBINATIONAL
        output [31:0] program_counter_decode_stage_o,
        output en_stall_decode_stage_o,
        output en_flush_mret_instruction_o,
        output exception_illegal_instruction_o,
        output exception_breakpoint_o,
        output exception_env_call_from_M_mode_o,

        //TO FETCH STAGE - COMBINATIONAL
        output en_excep_program_counter_o,
        output [31:0] excep_program_counter_o,

        //TO EXECUTION STAGE - POSEDGE
        output reg en_alu_o,
        output reg en_branching_unit_o,
        output reg en_ai_unit_o,
        output reg en_crypto_unit_o,
        output reg en_mem_o,
        output reg [5:0] op_alu_o,
        output reg [2:0] op_ai_o,
        output reg [2:0] op_crypto_o,
        output reg [2:0] op_branching_o,
        output reg [2:0] op_mem_o,
        output reg mem_read_o,
        output reg mem_write_o,
        output reg enable_rs2_conv_o,
        output reg reg_write_o,
        output reg [4:0] reg_rd_o,
        output reg [31:0] immediate_o,
        output reg [31:0] reg_rs1_data_o,
        output reg [31:0] reg_rs2_data_o,

        output reg [31:0] program_counter_o,
        output reg        branch_taken_o

    );

    reg [31:0] instruction_r;
    reg [31:0] program_counter_r;

    // RISC V COMPRESS EXPANDER
    wire [31:0] expanded_instruction_w;
    wire        exception_illegal_inst_expander_w;


    //INSTRUCTION DECODER
    wire en_alu_w;
    wire en_branching_unit_w;
    wire en_ai_unit_w;
    wire en_crypto_unit_w;
    wire en_mem_w;

    wire [5:0] op_alu_w;
    wire [2:0] op_ai_w;
    wire [2:0] op_crypto_w;
    wire [2:0] op_branching_w;
    wire [2:0] op_mem_w;

    wire [31:0] immediate_w;
    wire [31:0] csr_immediate_w;

    wire mem_read_w;
    wire mem_write_w;
    
    wire enable_rs2_conv_w;

    wire en_csr_read_w;
    wire en_csr_write_w;
    wire en_mret_instruction_w;
    wire [11:0] adress_csr_w;
    wire [2:0]  op_csr_w;

    wire exception_illegal_instr_decode_w;
    wire exception_breakpoint_w;
    wire exception_env_call_from_M_mode_w;

    wire reg_write_csr_w;
    wire reg_read_rs1_w;
    wire reg_read_rs2_w;
    wire reg_write_w;

    wire [4:0] reg_rs1_w;
    wire [4:0] reg_rs2_w;
    wire [4:0] reg_rd_w;


    //REGISTER FILE
    wire [31:0] reg_rs1_data_w;
    wire [31:0] reg_rs2_data_w;

    wire [31:0] reg_csr_data_w;

    wire stall_register_file_w;


    //CONTROL & STATUS REGISTER FILE
    wire        en_excep_program_counter_w;
    wire [31:0] excep_program_counter_w;
    wire [31:0] data_csr_read_w;


    rvc_expander riscv_expander(
        .instruction_i(instruction_r),

        .instruction_o(expanded_instruction_w),
        .exception_illegal_instruction_o(exception_illegal_inst_expander_w)
    );

    instr_decoder instruction_decoder(
        .instruction_i(expanded_instruction_w),

        .en_alu_o(en_alu_w),
        .en_branching_unit_o(en_branching_unit_w),
        .en_ai_unit_o(en_ai_unit_w),
        .en_crypto_unit_o(en_crypto_unit_w),
        .en_mem_o(en_mem_w),
        .op_alu_o(op_alu_w),
        .op_ai_o(op_ai_w),
        .op_crypto_o(op_crypto_w),
        .op_branching_o(op_branching_w),
        .op_mem_o(op_mem_w),
        .immediate_o(immediate_w),
        .csr_immediate_o(csr_immediate_w),
        .mem_read_o(mem_read_w),
        .mem_write_o(mem_write_w),
        .enable_rs2_conv_o(enable_rs2_conv_w),
        .en_csr_read_o(en_csr_read_w),
        .en_csr_write_o(en_csr_write_w),
        .en_mret_instruction_o(en_mret_instruction_w),
        .adress_csr_o(adress_csr_w),
        .op_csr_o(op_csr_w),
        .exception_illegal_instruction_o(exception_illegal_instr_decode_w),
        .exception_breakpoint_o(exception_breakpoint_w),
        .exception_env_call_from_M_mode_o(exception_env_call_from_M_mode_w),
        .reg_write_csr_o(reg_write_csr_w),
        .reg_read_rs1_o(reg_read_rs1_w),
        .reg_read_rs2_o(reg_read_rs2_w),
        .reg_write_o(reg_write_w),
        .reg_rs1_o(reg_rs1_w),
        .reg_rs2_o(reg_rs2_w),
        .reg_rd_o(reg_rd_w)
    );

    register_file register_file(
        .clk_i(clk_i),
        .rst_i(rst_i),

        .reg_read_rs1_i(reg_read_rs1_w),
        .reg_read_rs2_i(reg_read_rs2_w),
        .reg_rs1_i(reg_rs1_w),
        .reg_rs2_i(reg_rs2_w),
        .reg_write_i(reg_write_w),
        .reg_rd_i(reg_rd_w),
        .reg_write_csr_i(reg_write_csr_w),
        .reg_rd_data_csr_i(data_csr_read_w),
        
        .reg_rs1_data_o(reg_rs1_data_w),
        .reg_rs2_data_o(reg_rs2_data_w),
        .stall_register_file_o(stall_register_file_w)
    );

    cont_stat_register_file control_status_register_file(
        .clk_i(clk_i),
        .rst_i(rst_i),

        .en_exception_i(en_exception_i),
        .exception_cause_i(exception_cause_i),
        .exception_adress_i(exception_adress_i),
        .exception_program_counter_i(exception_program_counter_i),
        .en_mret_instruction_i(en_mret_instruction_w),
        .op_csr_i(op_csr_w),
        .en_csr_read_i(reg_write_w),
        .en_csr_write_i(reg_read_rs1_w),
        .adress_csr_i(adress_csr_w),

        .data_csr_read_o(reg_csr_data_w),
        .en_excep_program_counter_o(en_excep_program_counter_w),
        .excep_program_counter_o(excep_program_counter_w)
    );


    //TODO: reset ile ilgili herhangi bir sey yapmamiza gerek var mi? reset geldiginde unspecified bir sonuc donmesi gerekmez mi?
    always @(posedge clk_i) begin
        if(stall_decode_stage_i || en_stall_decode_stage_o) begin
            //NO INPUT TAKEN

            //NOP AS OUTPUT
            en_alu_o            <= 1'b0;
            en_branching_unit_o <= 1'b0;
            en_ai_unit_o        <= 1'b0;
            en_crypto_unit_o    <= 1'b0;
            en_mem_o            <= 1'b0;
            mem_read_o          <= 1'b0;
            mem_write_o         <= 1'b0;
            enable_rs2_conv_o   <= 1'b0;
            reg_write_o         <= 1'b0;
        end
        else if(flush_decode_stage_i) begin
            //REGULAR INPUTS
            instruction_r     <= instruction_i;
            program_counter_r <= program_counter_i;

            //OUTPUT AS NOP
            en_alu_o            <= 1'b0;
            en_branching_unit_o <= 1'b0;
            en_ai_unit_o        <= 1'b0;
            en_crypto_unit_o    <= 1'b0;
            en_mem_o            <= 1'b0;
            mem_read_o          <= 1'b0;
            mem_write_o         <= 1'b0;
            enable_rs2_conv_o   <= 1'b0;
            reg_write_o         <= 1'b0;
            
        end
        else begin
            //REGULAR INPUTS
            instruction_r       <= instruction_i;
            program_counter_r   <= program_counter_i;

            //OUTPUT SIGNALS
            en_alu_o            <= en_alu_w;
            en_branching_unit_o <= en_branching_unit_w;
            en_ai_unit_o        <= en_ai_unit_w;
            en_crypto_unit_o    <= en_crypto_unit_w;
            en_mem_o            <= en_mem_w;
            op_alu_o            <= op_alu_w;
            op_ai_o             <= op_ai_w;
            op_crypto_o         <= op_crypto_w;
            op_branching_o      <= op_branching_w;
            op_mem_o            <= op_mem_w;
            mem_read_o          <= mem_read_w;
            mem_write_o         <= mem_write_w;
            enable_rs2_conv_o   <= enable_rs2_conv_w;
            reg_write_o         <= reg_write_w;
            reg_rd_o            <= reg_rd_w;
            immediate_o         <= immediate_w;
            reg_rs1_data_o      <= reg_rs1_data_w;
            reg_rs2_data_o      <= reg_rs2_data_w;

            program_counter_o   <= program_counter_i;
            branch_taken_o      <= branch_taken_i;
            
        end
    end

    assign en_stall_decode_stage_o          = stall_register_file_w;
    assign en_flush_mret_instruction_o      = en_mret_instruction_w;
    assign program_counter_decode_stage_o   = program_counter_r;
    assign exception_illegal_instruction_o  = exception_illegal_inst_expander_w || exception_illegal_instr_decode_w;
    assign exception_breakpoint_o           = exception_breakpoint_w;
    assign exception_env_call_from_M_mode_o = exception_env_call_from_M_mode_w;
endmodule
