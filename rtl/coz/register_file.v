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
        input [31:0] reg_data_rd_wb_i,
        //-------------------------------------------------------------------------------

        //--------------------------signals to "execute stage"---------------------------
        output [31:0] reg_rs1_data_o,
        output [31:0] reg_rs2_data_o,
        //-------------------------------------------------------------------------------

        //we need to stall the "fetch stage" due to the "read after write" hazard
        //until that register gets ready to read, 
        output stall_register_file_o
    );

    //TODO: x0 have to be zero
    reg [31:0] register [0:31];
    reg [1:0]  reg_is_valid [0:31];
    reg        reg_is_ready;

    reg [31:0] reg_rs1_data;
    reg [31:0] reg_rs2_data;
    reg        reg_rs1_data_valid;
    reg        reg_rs2_data_valid;

    integer i;
    initial begin
        for(i = 0; i < 31; i = i + 1) begin
            register[i]     = 32'b0;
            reg_is_valid[i] = 2'b0;
        end
    end

    always @(*) begin
        reg_rs1_data = 32'b0;
        reg_rs2_data = 32'b0;
        reg_rs1_data_valid = 2'b00;
        reg_rs2_data_valid = 2'b00;

        if(reg_is_valid[reg_rs1_i] == 2'b00) begin
            reg_rs1_data_valid = 1'b1;
        end
        if(reg_is_valid[reg_rs2_i] == 2'b00) begin
            reg_rs2_data_valid = 1'b1;
        end
    end

    always @(negedge clk_i) begin
        if(reg_write_wb_i) begin
            register[reg_rd_wb_i]     <= reg_data_rd_wb_i;
            reg_is_valid[reg_rd_wb_i] <= reg_is_valid[reg_rd_wb_i] - 2'b01;
        end

        if(reg_write_i) begin
            reg_is_valid[reg_rd_i] = reg_is_valid[reg_rd_i] + 2'b01;
        end
    end

    always @(posedge clk_i) begin
        if(reg_read_rs1_i) begin
            if(reg_rs1_data_valid) begin
                reg_rs1_data <= register[reg_rs1_i];
                reg_is_ready <= 1'b1;
            end
            else begin
                reg_is_ready <= 1'b0;
            end
        end

        if(reg_read_rs2_i) begin
            if(reg_rs2_data_valid) begin
                reg_rs2_data <= register[reg_rs2_i];
                reg_is_ready <= 1'b1;
            end
            else begin
                reg_is_ready <= 1'b0;
            end
        end
    end

    assign reg_rs1_data_o = reg_rs1_data;
    assign reg_rs2_data_o = reg_rs2_data;
    assign stall_register_file_o = reg_is_ready;

endmodule
