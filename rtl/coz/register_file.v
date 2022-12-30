`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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

        //------------------------signals from "write-back stage"------------------------
        input        reg_write_wb_i,
        input [4:0]  reg_rd_wb_i,
        input [31:0] reg_rd_data_wb_i,
        //-------------------------------------------------------------------------------

        //--------------------------signals to "execute stage"---------------------------
        output [31:0] reg_rs1_data_o,
        output [31:0] reg_rs2_data_o,
        //-------------------------------------------------------------------------------

        //we need to stall the "fetch stage" due to the "read after write" hazard
        //until that register gets ready to read, 
        //input stall,
        output stall_register_file_o
    );

    reg [31:0] register [0:31];
    reg [1:0]  reg_valid_counter [0:31];
    reg        reg_is_ready_rs1_r;
    reg        reg_is_ready_rs2_r;

    reg [31:0] reg_rs1_data_r;
    reg [31:0] reg_rs2_data_r;

    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            register[i]     = i;
            reg_valid_counter[i] = 2'b0;
        end
        reg_rs1_data_r       = 32'b0;
        reg_rs2_data_r       = 32'b0;
        reg_is_ready_rs1_r   = 1'b1;
        reg_is_ready_rs2_r   = 1'b1;
    end

    always @(negedge clk_i) begin
        if(reg_write_wb_i) begin
            register[reg_rd_wb_i]          <= reg_rd_data_wb_i;
            reg_valid_counter[reg_rd_wb_i] <= reg_valid_counter[reg_rd_wb_i] - 2'b01;
        end

        if(reg_write_i) begin
            reg_valid_counter[reg_rd_i] <= reg_valid_counter[reg_rd_i] + 2'b01;
        end

        register[0] <= 1'b0;
    end

    always @(posedge clk_i, negedge rst_i) begin
        if(!rst_i) begin

        end else begin
            if(reg_read_rs1_i) begin           
                if(reg_valid_counter[reg_rs1_i] == 2'b00) begin
                    reg_rs1_data_r <= register[reg_rs1_i];
                    reg_is_ready_rs1_r <= 1'b1;
                end else begin
                    reg_is_ready_rs1_r <= 1'b0;
                end
            end
    
            if(reg_read_rs2_i) begin
                if(reg_valid_counter[reg_rs2_i] == 2'b00) begin
                    reg_rs2_data_r <= register[reg_rs2_i];
                    reg_is_ready_rs2_r <= 1'b1;
                end else begin
                    reg_is_ready_rs2_r <= 1'b0;
                end
            end
        end 
    end

    assign reg_rs1_data_o        = reg_rs1_data_r;
    assign reg_rs2_data_o        = reg_rs2_data_r;
    assign stall_register_file_o = ~(reg_is_ready_rs1_r & reg_is_ready_rs2_r);

endmodule
