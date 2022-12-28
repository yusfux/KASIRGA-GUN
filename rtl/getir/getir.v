`timescale 1ns / 1ps
module getir(
    input         clk_i,
    input         rst_i,

    output [31:0] ps_o,
    output [31:0] buyruk_o,
    output        buyruk_sikisik_o

    );

wire        ps_durdur;

wire        buyruk_hazir;

wire        ongoru_aktif;

reg [31:0]  okunan_buyruk;

reg         kuyruk_aktif;

wire        guncelle_gecerli;

wire [31:0] atlanan_ps;
wire        ongoru_gecerli;


wire [31:0] ps_ongorucu;

ps_uretici ps_uretici(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .ps_durdur_i(ps_durdur),
    .ps_atlat_aktif_i(ongoru_gecerli),
    .ps_atlanacak_adres_i(atlanan_ps),
    .ps_ongorucu_o(ps_ongorucu),
    .ps_o(ps_o)
    );

buyruk_kuyrugu buyruk_kuyrugu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .kuyruk_aktif_i(kuyruk_aktif),
    .buyruk_i(okunan_buyruk),
    .buyruk_o(buyruk_o),
    .buyruk_sikisik_o(buyruk_sikisik_o),
    .buyruk_hazir_o(buyruk_hazir),
    .ps_durdur_o(ps_durdur)
    );

oncozucu oncozucu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .buyruk_i(buyruk_o),
    .ongoru_aktif_o(ongoru_aktif)
    );
    
dallanma_ongoru_blogu dallanma_ongoru_blogu(
    .clk_i(clk_i),
    .rst_i(!rst_i),
    .ongoru_aktif_i(ongoru_aktif),
    .guncelle_gecerli_i(0),
    //.guncelle_atladi_i(),
    //.guncelle_ps_i(),
    .ps_i(ps_ongorucu),
    .atlanan_ps_o(atlanan_ps),
    .ongoru_gecerli_o(ongoru_gecerli)
);

always @(*) begin
    
end

always @(posedge clk_i) begin
    
end

endmodule
