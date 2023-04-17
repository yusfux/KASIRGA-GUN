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

    wire [149:0] obek_r;

    sky130_sram_2kbytes_1rw_150x128_8 sram_data ( 
        .clk0      (clk_i)                 ,
        .csb0      (!en_i)                 ,
        .web0      (!wen_i)                ,
        .wmask0    (16'hFFFF)              ,
        //.spare_wen0(1'b0)                  ,    //1'b0 mi yoksa 1'b1 mi yapsak bi bakmak lazim
        .addr0     ({1'b0, adres_i})       ,
        .din0      ({1'b0, veri_i}),
        .dout0     (obek_r)
    );

    assign obek_o = obek_r[148:0];

endmodule
