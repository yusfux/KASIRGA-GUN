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

module register_file (
        input [31:0] bellek_hedef_yazmac_verisi_i,
        input        bellek_yazmaca_yaz_i,
        input [4:0]  bellek_hedef_yazmaci_i,

        input        bellekten_oku_i,
        input [31:0] hedef_yazmac_verisi_i,
        input        yazmaca_yaz_i,
        input [4:0]  hedef_yazmaci_i,

        input clk_i, rst_i,
        input stall_register_file_i,
        
        //----------------------signals from "instruction decoder"-----------------------
        input       reg_read_rs1_i,
        input       reg_read_rs2_i,
        input       reg_write_i,

        input [4:0] reg_rs1_i,
        input [4:0] reg_rs2_i,
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

    always @(*) begin
        reg_rs1_data_r     = 32'b0;
        reg_rs2_data_r     = 32'b0;
        reg_is_ready_rs1_r = 1'b0;
        reg_is_ready_rs2_r = 1'b0;

        if(reg_read_rs1_i && reg_valid_counter[reg_rs1_i] == 2'b00) begin
            reg_rs1_data_r     = register[reg_rs1_i];
            reg_is_ready_rs1_r = 1'b1;
        end else if(reg_read_rs1_i && reg_rs1_i == hedef_yazmaci_i && yazmaca_yaz_i && !bellekten_oku_i) begin
            reg_rs1_data_r = hedef_yazmac_verisi_i;
            reg_is_ready_rs1_r = 1'b1;
        end else if(!bellekten_oku_i || (hedef_yazmaci_i != reg_rs1_i && bellekten_oku_i)) begin
            if(reg_read_rs1_i && reg_rs1_i == bellek_hedef_yazmaci_i && bellek_yazmaca_yaz_i) begin
                reg_rs1_data_r = bellek_hedef_yazmac_verisi_i;
                reg_is_ready_rs1_r = 1'b1;
            end else if (reg_read_rs1_i && reg_rs1_i == reg_rd_wb_i && reg_write_wb_i) begin
                reg_rs1_data_r = reg_rd_data_wb_i;
                reg_is_ready_rs1_r = 1'b1;
            end
        end

        if(reg_read_rs2_i && reg_valid_counter[reg_rs2_i] == 2'b00) begin
            reg_rs2_data_r = register[reg_rs2_i];
            reg_is_ready_rs2_r = 1'b1;
        end else if(reg_read_rs2_i && reg_rs2_i == hedef_yazmaci_i && yazmaca_yaz_i && !bellekten_oku_i) begin
            reg_rs2_data_r = hedef_yazmac_verisi_i;
            reg_is_ready_rs2_r = 1'b1;
        end else if(!bellekten_oku_i || (hedef_yazmaci_i != reg_rs2_i && bellekten_oku_i)) begin
            if(reg_read_rs2_i && reg_rs2_i == bellek_hedef_yazmaci_i && bellek_yazmaca_yaz_i) begin
                reg_rs2_data_r = bellek_hedef_yazmac_verisi_i;
                reg_is_ready_rs2_r = 1'b1;
            end else if (reg_read_rs2_i && reg_rs2_i == reg_rd_wb_i && reg_write_wb_i) begin
                reg_rs2_data_r = reg_rd_data_wb_i;
                reg_is_ready_rs2_r = 1'b1;
            end
        end
    end

    integer i;
    always @(posedge clk_i) begin
        if(!rst_i) begin
            for(i = 0; i < 32; i = i + 1) begin
                register[i]          <= 5'b00000;
                reg_valid_counter[i] <= 2'b00;
            end
        end

        else begin
            //TODO: STILL NEED TO FIND MORE PROPER WAY
            if (reg_write_wb_i && reg_write_i && reg_rd_wb_i == reg_rd_i) begin
                register[reg_rd_wb_i]          <= reg_rd_data_wb_i;
                if((stall_register_file_o || stall_register_file_i) && reg_rd_wb_i != 5'b00000)
                    reg_valid_counter[reg_rd_wb_i] <= reg_valid_counter[reg_rd_wb_i] - 2'b01;
            end
            else begin
                if(reg_write_wb_i && (reg_rd_wb_i != 5'b00000)) begin
                    register[reg_rd_wb_i]          <= reg_rd_data_wb_i;
                    reg_valid_counter[reg_rd_wb_i] <= reg_valid_counter[reg_rd_wb_i] - 2'b01;
                end

                if(reg_write_i && (reg_rd_i != 5'b00000) && !stall_register_file_o && !stall_register_file_i) begin
                    reg_valid_counter[reg_rd_i] <= reg_valid_counter[reg_rd_i] + 2'b01;
                end
            end
        end

        register[0] <= 5'b00000;
    end

    assign reg_rs1_data_o        = reg_rs1_data_r;
    assign reg_rs2_data_o        = reg_rs2_data_r;
    assign stall_register_file_o = ((reg_read_rs1_i && ~reg_is_ready_rs1_r) || (reg_read_rs2_i && ~reg_is_ready_rs2_r));

endmodule