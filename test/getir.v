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
    output        anabellek_yaz_o,
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

wire         ps_durdur_w;
wire         ps_iki_artir_w;

wire         kuyruk_buyruk_hazir_w;
wire [31:0]  kuyruk_gelen_buyruk_w;

wire         ongoru_aktif_w;
wire         ongoru_gecerli_o_w;
reg          ongoru_gecerli_o_r;

wire [31:0]  atlanan_ps_w;

wire [31:0]  ps_r_w;
wire [31:0]  ps_ns_w;
wire [31:0]  ps_kuyruk_w;
wire         ps_kuyruk_gecerli_w;

wire [31:0]  buyruk_w;
wire         adres_bulundu_w;
wire [127:0] veri_obegi_w;
wire         onbellege_obek_yaz_w;
wire [31:0]  onbellek_yaz_adres_w;
wire         ps_uretici_durdur_w;

wire [31:0]  bellek_gelen_buyruk_w;
wire         bellek_buyruk_hazir_w;

ps_uretici ps_uretici(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .ps_durdur_i(ps_uretici_durdur_w),
    .ps_iki_artir_i(ps_iki_artir_w),

    .ps_atlat_aktif_i(ongoru_gecerli_o),
    .ps_atlanacak_adres_i(atlanan_ps_w),
    .ps_ongorucu_o(ps_r_w),
    .ps_o(ps_ns_w),

    .guncelle_hedef_adresi_i(guncelle_hedef_adresi_i),
    .dallanma_hata_i(dallanma_hata_i),

    .jal_gecerli_i(jal_gecerli_i),
    .jal_adres_i(jal_adres_i)
);

buyruk_kuyrugu buyruk_kuyrugu(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .kuyruk_aktif_i(bellek_buyruk_hazir_w),
    .ps_atladi_i(ongoru_gecerli_o | dallanma_hata_i | jal_gecerli_i),

    .ps_i(ps_ns_w),
    .buyruk_i(bellek_gelen_buyruk_w),

    .buyruk_o(kuyruk_gelen_buyruk_w),
    .ps_o(ps_kuyruk_w),
    .ps_gecerli_o(ps_kuyruk_gecerli_w),
    .buyruk_hazir_o(kuyruk_buyruk_hazir_w),

    .ps_durdur_o(ps_durdur_w),
    .ps_iki_artir_o(ps_iki_artir_w)
);

oncozucu oncozucu(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .buyruk_i(kuyruk_gelen_buyruk_w),
    .ongoru_aktif_o(ongoru_aktif_w)
);
    
dallanma_ongoru_blogu dallanma_ongoru_blogu(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .ongoru_aktif_i(ongoru_aktif_w & kuyruk_buyruk_hazir_w),

    .guncelle_gecerli_i(guncelle_gecerli_i),
    .guncelle_atladi_i(guncelle_atladi_i),
    .guncelle_ps_i(guncelle_ps_i),
    .guncelle_hedef_adresi_i(guncelle_hedef_adresi_i),

    .ps_i(ps_kuyruk_gecerli_w ? ps_kuyruk_w : ps_r_w),

    .dallanma_hata_i(dallanma_hata_i),

    .atlanan_ps_o(atlanan_ps_w),
    .ongoru_gecerli_o(ongoru_gecerli_o_w)
);

buyruk_onbellegi_denetleyici buyruk_onbellegi_denetleyici(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .durdur_i(durdur_i),

    .adres_i(ps_ns_w),
    .adres_kontrol_i(ps_r_w),
    .adres_bulundu_i(adres_bulundu_w),
    .buyruk_i(buyruk_w),
    .veri_obegi_o(veri_obegi_w),
    .onbellege_obek_yaz_o(onbellege_obek_yaz_w),
    .onbellek_yaz_adres_o(onbellek_yaz_adres_w),

    .anabellek_musait_i(anabellek_musait_i),
    .getir_asamasina_veri_hazir_i(getir_asamasina_veri_hazir_i),
    .okunan_obek_i(okunan_obek_i),
    .anabellek_adres_o(getir_adres_o),
    .anabellek_istek_o(getir_asamasi_istek_o),
    .anabellek_yaz_o(anabellek_yaz_o),
    .anabellek_oku_o(getir_oku_o),

    .buyruk_o(bellek_gelen_buyruk_w),
    .buyruk_hazir_o(bellek_buyruk_hazir_w)
);

buyruk_onbellegi buyruk_onbellegi(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .adres_i(ps_ns_w),
    .buyruk_obegi_i(veri_obegi_w),
    .anabellekten_obek_geldi_i(onbellege_obek_yaz_w),
    .onbellek_yaz_adres_i(onbellek_yaz_adres_w),
    .buyruk_o(buyruk_w),
    .adres_bulundu_o(adres_bulundu_w)
);

always @(*) begin
    
end

reg [31:0] ps_r;
reg [31:0] buyruk_r;

always @(posedge clk_i) begin
    if(!durdur_i && kuyruk_buyruk_hazir_w && !dallanma_hata_i && !jal_gecerli_i) begin
        ps_r <=  ps_kuyruk_gecerli_w ? ps_kuyruk_w : ps_r_w;
        buyruk_r <= kuyruk_gelen_buyruk_w;
        ongoru_gecerli_o_r <= ongoru_gecerli_o_w;
    end
    else if((!durdur_i && !kuyruk_buyruk_hazir_w) || dallanma_hata_i || jal_gecerli_i) begin
        buyruk_r <= 32'h0000_0013;
        ongoru_gecerli_o_r <= 1'b0;
    end
end



assign ps_o = ps_r;
assign buyruk_o = buyruk_r;
assign ps_uretici_durdur_w = ps_durdur_w | durdur_i | !bellek_buyruk_hazir_w;
assign ongoru_gecerli_o = ongoru_gecerli_o_r;

endmodule
