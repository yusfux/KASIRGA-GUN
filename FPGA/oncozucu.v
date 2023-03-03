`timescale 1ns / 1ps
module oncozucu(
    input        clk_i,
    input        rst_i,

    input [31:0] buyruk_i,

    output       ongoru_aktif_o
    
    );

localparam OPCODE_DALLANMA   = 7'b1100011;
localparam OPCODE_C_DALLANMA = 2'b01;
localparam FONKSIYON_BEQ     = 3'b000;
localparam FONKSIYON_BNE     = 3'b001;
localparam FONKSIYON_BLT     = 3'b100;
localparam FONKSIYON_BGE     = 3'b101;
localparam FONKSIYON_BLTU    = 3'b110;
localparam FONKSIYON_BGEU    = 3'b111;
localparam FONKSIYON_C_BEQZ  = 3'b110;
localparam FONKSIYON_C_BNEZ  = 3'b111;

wire [6:0] buyruk_opcode_w;
wire [2:0] buyruk_fonksiyon_w;
wire [1:0] buyruk_c_opcode_w;
wire [2:0] buyruk_c_fonksiyon_w;

reg        ongoru_aktif_o_cmb; // TODO: Kombinasyonel mi olmali??? Ve bu sinyalin gecerli oldugunu belirten bir sinyal gerekli mi?

always @(*) begin
    ongoru_aktif_o_cmb = 0;

    if ((buyruk_opcode_w     == OPCODE_DALLANMA      && (
        buyruk_fonksiyon_w   == FONKSIYON_BEQ        ||
        buyruk_fonksiyon_w   == FONKSIYON_BNE        ||
        buyruk_fonksiyon_w   == FONKSIYON_BLT        ||
        buyruk_fonksiyon_w   == FONKSIYON_BGE        ||
        buyruk_fonksiyon_w   == FONKSIYON_BLTU       ||
        buyruk_fonksiyon_w   == FONKSIYON_BGEU)      || ((
        buyruk_c_opcode_w    == OPCODE_C_DALLANMA)   && (
        buyruk_c_fonksiyon_w == FONKSIYON_C_BEQZ     ||
        buyruk_c_fonksiyon_w == FONKSIYON_C_BNEZ)))) begin

        ongoru_aktif_o_cmb = 1;

    end
end

always @(posedge clk_i) begin
    if(!rst_i) begin
        
    end
    else begin
        
    end
end

assign buyruk_opcode_w      = buyruk_i [6:0];
assign buyruk_fonksiyon_w   = buyruk_i [14:12];
assign buyruk_c_opcode_w    = buyruk_i [1:0];
assign buyruk_c_fonksiyon_w = buyruk_i [15:13];
assign ongoru_aktif_o       = ongoru_aktif_o_cmb;

endmodule
