`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yusuf Aydın
// 
// Create Date: 25.12.2022 21:48:47
// Design Name: 
// Module Name: register_file
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


//TODO: stall sinyalini buraya da input olarak vermek lazim, stall geldigi durumda herhangi bir sekilde
//valid counter uzerinde islem yapilmamali
module register_file(
        input clk_i, rst_i,
        
        //----------------------signals from "instruction decoder"-----------------------
        input reg_read_rs1_i,
        input reg_read_rs2_i,
        input [4:0] reg_rs1_i,
        input [4:0] reg_rs2_i,

        input reg_write_i,
        input [4:0] reg_rd_i,
        //-------------------------------------------------------------------------------

        //------------------signals from "control status register file"------------------
        input        reg_write_csr_i,
        input [31:0] reg_rd_data_csr_i,
        //-------------------------------------------------------------------------------

        //------------------------signals from "write-back stage"------------------------
        input        reg_write_wb_i,
        input [4:0]  reg_rd_wb_i,
        input [31:0] reg_rd_data_wb_i,
        //-------------------------------------------------------------------------------

        //--------------------------signals to "execute stage"---------------------------
        output [31:0] reg_rs1_data_o,
        output [31:0] reg_rs2_data_o,
        //-------------------------------------------------------------------------------

        //------------------signals to "control status register file"--------------------
        output [31:0] reg_csr_data_o,
        //-------------------------------------------------------------------------------

        //------------------------signals to "pipeline controller"-----------------------
        output stall_register_file_o
        //-------------------------------------------------------------------------------
    );

    reg [31:0] register [0:31];
    reg [1:0]  reg_valid_counter [0:31];
    reg        reg_is_ready_rs1_r;
    reg        reg_is_ready_rs2_r;

    reg [31:0] reg_rs1_data_r;
    reg [31:0] reg_rs2_data_r;
    reg [31:0] reg_csr_data_r;

    //TODO: burasi normalde kaldirilmasi lazim, li ile tum reglere 0 atanmali program baslarken
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            register[i]          = i;
            reg_valid_counter[i] = 2'b0;
        end
    end

    always @(*) begin
        reg_rs1_data_r     = 31'b0;
        reg_rs2_data_r     = 31'b0;
        reg_is_ready_rs1_r = 1'b0;
        reg_is_ready_rs2_r = 1'b0;

        //TODO: need to find more proper way to get rid of inst xA, xA, xB kind of situations
        if(reg_read_rs1_i && ((reg_valid_counter[reg_rs1_i] == 2'b00) || (reg_valid_counter[reg_rs1_i] == 2'b01 && (reg_rs1_i == reg_rd_i) && reg_write_i))) begin
            reg_rs1_data_r     = register[reg_rs1_i];
            reg_is_ready_rs1_r = 1'b1;
        end

        if(reg_read_rs2_i && ((reg_valid_counter[reg_rs2_i] == 2'b00) || (reg_valid_counter[reg_rs2_i] == 2'b01 && (reg_rs2_i == reg_rd_i) && reg_write_i))) begin
            reg_rs2_data_r = register[reg_rs2_i];
            reg_is_ready_rs2_r = 1'b1;
        end
        
        //sanirim bu addi buyrugunu csrlardaki veriyi rege yazmak icindi ama unuttum bakmak lazim
        if(reg_write_csr_i) begin
            reg_rs1_data_r = reg_rd_data_csr_i;
        end

        //TODO: bu ne? wire yapilabilir mi?
        reg_csr_data_r = register[reg_rs1_i];
    end

    //burada kesin boku yedik test lazim
    always @(negedge clk_i, negedge rst_i) begin
        if(!rst_i) begin
            for(i = 0; i < 32; i = i + 1) begin
                register[i]          <= 5'b00000;
                reg_valid_counter[i] <= 2'b00;
            end
        end
        else begin
            if(reg_write_wb_i && (reg_rd_wb_i != 5'b00000)) begin
                register[reg_rd_wb_i]          <= reg_rd_data_wb_i;
                reg_valid_counter[reg_rd_wb_i] <= reg_valid_counter[reg_rd_wb_i] - 2'b01;
            end

            if(reg_write_i && (reg_rd_i != 5'b00000)) begin
                reg_valid_counter[reg_rd_i] <= reg_valid_counter[reg_rd_i] + 2'b01;
            end

            //TODO: need to find more proper way to hard wire x0 to zero
            register[0] <= 5'b00000;
        end
    end

    assign reg_rs1_data_o        = reg_rs1_data_r;
    assign reg_rs2_data_o        = reg_rs2_data_r;
    assign reg_csr_data_o        = reg_csr_data_r;
    assign stall_register_file_o = ((reg_read_rs1_i && ~reg_is_ready_rs1_r) || (reg_read_rs2_i && ~reg_is_ready_rs2_r));

endmodule