`timescale 1ns / 1ps
module getir(
    input         clk_i,
    input         rst_i,

    input         durdur_i,
   
    output [31:0] ps_o,
    output [31:0] buyruk_o,

    output        getir_asamasi_istek_o,
    output [31:0] getir_adres_o,
    output        getir_oku_o,

    input         anabellek_musait_i,
    input         getir_asamasina_veri_hazir_i,
    input [127:0] okunan_obek_i,

    output        ongoru_gecerli_o,
    input         guncelle_gecerli_i,
    input         guncelle_atladi_i,
    input [31:0]  guncelle_ps_i,
    input [31:0]  guncelle_hedef_adresi_i,
    input         dallanma_hata_i,

    input         jal_gecerli_i,
    input [31:0]  jal_adres_i

);

wire         ps_durdur;

wire         buyruk_hazir;

wire         ongoru_aktif;

reg  [31:0]  okunan_buyruk;

reg          kuyruk_aktif;

wire         guncelle_gecerli;

wire [31:0]  atlanan_ps;

wire [31:0]  ps_ongorucu;

wire [31:0]  buyruk_w;
wire         adres_bulundu_w;
wire [127:0] veri_obegi_w;
wire         onbellege_obek_yaz_w;

wire [31:0]  gelen_buyruk_w;
wire         buyruk_hazir_w;

ps_uretici ps_uretici(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .ps_durdur_i(ps_durdur),
    .ps_atlat_aktif_i(ongoru_gecerli_o),
    .ps_atlanacak_adres_i(atlanan_ps),
    .ps_ongorucu_o(ps_ongorucu),
    //.ps_o(ps_o)
    .jal_gecerli_i(jal_gecerli_i),
    .jal_adres_i(jal_adres_i)
);

buyruk_kuyrugu buyruk_kuyrugu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .kuyruk_aktif_i(kuyruk_aktif),
    .buyruk_i(okunan_buyruk),
    .buyruk_o(buyruk_o),
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

    .guncelle_gecerli_i(guncelle_gecerli_i),
    .guncelle_atladi_i(guncelle_atladi_i),
    .guncelle_ps_i(guncelle_ps_i),
    .guncelle_hedef_adresi_i(guncelle_hedef_adresi_i),

    .ps_i(ps_ongorucu),

    .dallanma_hata_i(dallanma_hata_i),

    .atlanan_ps_o(atlanan_ps),
    .ongoru_gecerli_o(ongoru_gecerli_o)
);

buyruk_onbellegi_denetleyici buyruk_onbellegi_denetleyici(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .durdur_i(durdur_i),

    .adres_i(ps_o),
    .adres_bulundu_i(adres_bulundu_w),
    .buyruk_i(buyruk_w),
    .veri_obegi_o(veri_obegi_w),
    .onbellege_obek_yaz_o(onbellege_obek_yaz_w), // TODO INCELE

    .anabellek_musait_i(anabellek_musait_i),
    .getir_asamasina_veri_hazir_i(getir_asamasina_veri_hazir_i),
    .okunan_obek_i(okunan_obek_i),
    .anabellek_adres_o(getir_adres_o),
    .anabellek_istek_o(getir_asamasi_istek_o),
    .anabellek_yaz_o(0),
    .anabellek_oku_o(getir_oku_o),

    .buyruk_o(gelen_buyruk_w),
    .buyruk_hazir_o(buyruk_hazir_w)
);

buyruk_onbellegi buyruk_onbellegi(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .adres_i(ps_o),
    .buyruk_obegi_i(veri_obegi_w),
    .anabellekten_obek_geldi_i(onbellege_obek_yaz_w),
    .buyruk_o(buyruk_w),
    .adres_bulundu_o(adres_bulundu_w)
);

always @(*) begin
    
end

always @(posedge clk_i) begin
    
end

assign ps_o = ps_ongorucu;

endmodule
