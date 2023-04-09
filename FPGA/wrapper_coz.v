`timescale 1ns / 1ps

module wrapper_coz (
        input [31:0] bellek_hedef_yazmac_verisi_i,
        input        bellek_yazmaca_yaz_i,
        input [4:0]  bellek_hedef_yazmaci_i,

        input bellekten_oku_i,
        input [31:0] hedef_yazmac_verisi_i,
        input        yazmaca_yaz_i,
        input [4:0]  hedef_yazmaci_i,

        input clk_i, rst_i,

        //FROM FETCH STAGE - POSEDGE
        input [31:0] instruction_i,
        input [31:0] program_counter_i,
        input        branch_taken_i,

        //FROM WRITE-BACK STAGE - COMBINATIONAL
        input        reg_write_wb_i,
        input [4:0]  reg_rd_wb_i,
        input [31:0] reg_rd_data_wb_i,

        //FROM PIPELINE CONTROLLER - COMBINATONAL
        input stall_decode_stage_i,
        input flush_decode_stage_i,
        
        output en_stall_decode_stage_o,

        //TO EXECUTE STAGE - POSEDGE
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
        output enable_rs2_conv_o,
        output reg_write_o,
        output [4:0] reg_rd_o,
        output [31:0] immediate_o,
        output [31:0] reg_rs1_data_o,
        output [31:0] reg_rs2_data_o,

        output [31:0] program_counter_o,
        output        branch_taken_o,
        output        is_compressed_o

    );


    // RISC V COMPRESS EXPANDER
    wire [31:0] expanded_instruction_w;
    wire        is_compressed_w;


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

    wire mem_read_w;
    wire mem_write_w;
    
    wire enable_rs2_conv_w;

    wire reg_read_rs1_w;
    wire reg_read_rs2_w;
    wire reg_write_w;

    wire [4:0] reg_rs1_w;
    wire [4:0] reg_rs2_w;
    wire [4:0] reg_rd_w;


    //REGISTER FILE
    wire [31:0] reg_rs1_data_w;
    wire [31:0] reg_rs2_data_w;

    //CHECK WHY THIS IS HERE
    wire stall_register_file_w;

    rvc_expander riscv_expander(
        .instruction_i(instruction_i),

        .instruction_o(expanded_instruction_w),
        .is_compressed_o(is_compressed_w)
    );

    instr_decoder instruction_decoder(
        .instruction_i(flush_decode_stage_i ? 32'h00000013 : expanded_instruction_w),

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
        .mem_read_o(mem_read_w),
        .mem_write_o(mem_write_w),
        .enable_rs2_conv_o(enable_rs2_conv_w),
        .reg_read_rs1_o(reg_read_rs1_w),
        .reg_read_rs2_o(reg_read_rs2_w),
        .reg_write_o(reg_write_w),
        .reg_rs1_o(reg_rs1_w),
        .reg_rs2_o(reg_rs2_w),
        .reg_rd_o(reg_rd_w)
    );

    register_file register_file(
        .bellek_hedef_yazmac_verisi_i(bellek_hedef_yazmac_verisi_i),
        .bellek_yazmaca_yaz_i(bellek_yazmaca_yaz_i),
        .bellek_hedef_yazmaci_i(bellek_hedef_yazmaci_i),

        .bellekten_oku_i(bellekten_oku_i),
        .hedef_yazmac_verisi_i(hedef_yazmac_verisi_i),
        .yazmaca_yaz_i(yazmaca_yaz_i),
        .hedef_yazmaci_i(hedef_yazmaci_i),

        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_register_file_i(stall_decode_stage_i || flush_decode_stage_i),

        .reg_read_rs1_i(reg_read_rs1_w),
        .reg_read_rs2_i(reg_read_rs2_w),
        .reg_rs1_i(reg_rs1_w),
        .reg_rs2_i(reg_rs2_w),

        .reg_write_i(reg_write_w),
        .reg_rd_i(reg_rd_w),

        .reg_write_wb_i(reg_write_wb_i),
        .reg_rd_wb_i(reg_rd_wb_i),
        .reg_rd_data_wb_i(reg_rd_data_wb_i),
        
        .reg_rs1_data_o(reg_rs1_data_w),
        .reg_rs2_data_o(reg_rs2_data_w),
        .stall_register_file_o(stall_register_file_w)
    );

    //-------------------------------------------------------
    reg        en_alu_r;
    reg        en_branching_unit_r;
    reg        en_ai_unit_r;
    reg        en_crypto_unit_r;
    reg        en_mem_r;
    reg [5:0]  op_alu_r;
    reg [2:0]  op_ai_r;
    reg [2:0]  op_crypto_r;
    reg [2:0]  op_branching_r;
    reg [2:0]  op_mem_r;
    reg        mem_read_r;
    reg        mem_write_r;
    reg        enable_rs2_conv_r;
    reg        reg_write_r;
    reg [4:0]  reg_rd_r;
    reg [31:0] immediate_r;
    reg [31:0] reg_rs1_data_r;
    reg [31:0] reg_rs2_data_r;

    reg [31:0] program_counter_r;
    reg        branch_taken_r;
    reg        is_compressed_r;
    //-------------------------------------------------------

    always @(posedge clk_i) begin
        if(!stall_decode_stage_i && (en_stall_decode_stage_o || flush_decode_stage_i)) begin
            //NOP AS OUTPUT
            en_alu_r            <= 1'b0;
            en_branching_unit_r <= 1'b0;
            en_ai_unit_r        <= 1'b0;
            en_crypto_unit_r    <= 1'b0;
            en_mem_r            <= 1'b0;
            mem_read_r          <= 1'b0;
            mem_write_r         <= 1'b0;
            reg_write_r         <= 1'b0;
        end
        else if(!stall_decode_stage_i) begin

            //OUTPUT SIGNALS
            en_alu_r            <= en_alu_w;
            en_branching_unit_r <= en_branching_unit_w;
            en_ai_unit_r        <= en_ai_unit_w;
            en_crypto_unit_r    <= en_crypto_unit_w;
            en_mem_r            <= en_mem_w;
            op_alu_r            <= op_alu_w;
            op_ai_r             <= op_ai_w;
            op_crypto_r         <= op_crypto_w;
            op_branching_r      <= op_branching_w;
            op_mem_r            <= op_mem_w;
            mem_read_r          <= mem_read_w;
            mem_write_r         <= mem_write_w;
            enable_rs2_conv_r   <= enable_rs2_conv_w;
            reg_write_r         <= reg_write_w;
            reg_rd_r            <= reg_rd_w;
            immediate_r         <= immediate_w;
            reg_rs1_data_r      <= reg_rs1_data_w;
            reg_rs2_data_r      <= reg_rs2_data_w;

            program_counter_r   <= program_counter_i;
            branch_taken_r      <= branch_taken_i;
            is_compressed_r     <= is_compressed_w;
            
        end
    end

    assign en_alu_o            = en_alu_r;
    assign en_branching_unit_o = en_branching_unit_r;
    assign en_ai_unit_o        = en_ai_unit_r;
    assign en_crypto_unit_o    = en_crypto_unit_r;
    assign en_mem_o            = en_mem_r;
    assign op_alu_o            = op_alu_r;
    assign op_ai_o             = op_ai_r;
    assign op_crypto_o         = op_crypto_r;
    assign op_branching_o      = op_branching_r;
    assign op_mem_o            = op_mem_r;
    assign mem_read_o          = mem_read_r;
    assign mem_write_o         = mem_write_r;
    assign enable_rs2_conv_o   = enable_rs2_conv_r;
    assign reg_write_o         = reg_write_r;
    assign reg_rd_o            = reg_rd_r;
    assign immediate_o         = immediate_r;
    assign reg_rs1_data_o      = reg_rs1_data_r;
    assign reg_rs2_data_o      = reg_rs2_data_r;

    assign program_counter_o   = program_counter_r;
    assign branch_taken_o      = branch_taken_r;
    assign is_compressed_o     = is_compressed_r;

    assign en_stall_decode_stage_o          = stall_register_file_w;
endmodule