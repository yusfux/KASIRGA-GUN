`timescale 1ns / 1ps

module wrapper_sram (
		input clk_i,
		input rst_i,

		input en_i ,
		input wen_i,
		input [6:0]   adres_i,
		input [148:0] veri_i,

		output [148:0] obek_o
	);
	
	wire [20:0]  obek_21;
	wire [128:0] obek_128;

	sram_21x128 sram_label (
		.clk0 (clk_i)           ,
		.csb0 (!en_i)           ,
		.web0 (!wen_i)          ,
		.addr0({1'b0, adres_i}) ,
		.din0 (veri_i[148:128]) ,
		.dout0(obek_21)
	);

	sram_128x128 sram_data ( 
		.clk0      (clk_i)                 ,
		.csb0      (!en_i)                 ,
		.web0      (!wen_i)                ,
		.wmask0    (16'hFFFF)              ,
		.spare_wen0(1'b0)                  ,	//1'b0 mi yoksa 1'b1 mi yapsak bi bakmak lazim
		.addr0     ({1'b0 ,adres_i})       ,
		.din0      ({1'b0, veri_i[127:0]}) ,
		.dout0     (obek_128)
	);

	
	assign obek_o = {obek_21, obek_128[127:0]};

endmodule
