`timescale 1ns / 1ps

module wrapper_getir (
        input         clk_i,
        input         rst_i,
        input         durdur_i,
    
        // buyruk onbelleginden gelecek sinyaller
        input [31:0] buyruk_i,
        input        buyruk_hazir_i,

        // buyruk onbellegine gidecek sinyaller
        output [31:0] buyruk_adres_o,
        output        bbellek_durdur_o,


        input         guncelle_gecerli_i,
        input         guncelle_atladi_i,
        input [31:0]  guncelle_ps_i,
        input [31:0]  guncelle_hedef_adresi_i,
        input         dallanma_hata_i,

        input         jal_gecerli_i,
        input [31:0]  jal_adres_i,

        output        ongoru_gecerli_o,

        //bunlar coz asamasina gidiyor
        output [31:0] ps_o,
        output [31:0] buyruk_o
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

    wire         ps_uretici_durdur_w;

    wire         durum_sikistirilmis_w; 
    reg          kuyruk_aktif_cmb;
    reg          buffer_aktif_r;
    reg          buffer_aktif_ns;
    reg  [31:0]  buyruk_buffer_r;
    reg  [31:0]  buyruk_buffer_ns;

    ps_uretici ps_uretici(
        .clk_i(clk_i),
        .rst_i(rst_i),

        .ps_durdur_i(ps_uretici_durdur_w),
        .ps_iki_artir_i(ps_iki_artir_w),

        .ps_atlat_aktif_i(ongoru_gecerli_o_w),
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

        .kuyruk_aktif_i(kuyruk_aktif_cmb),
        .durdur_i(durdur_i),
        .ps_atladi_i(ongoru_gecerli_o | dallanma_hata_i | jal_gecerli_i),

        .ps_i(ps_ns_w),
        .buyruk_i(buffer_aktif_r ? buyruk_buffer_r : buyruk_i),

        .buyruk_o(kuyruk_gelen_buyruk_w),
        .ps_o(ps_kuyruk_w),
        .ps_gecerli_o(ps_kuyruk_gecerli_w),
        .buyruk_hazir_o(kuyruk_buyruk_hazir_w),

        .ps_durdur_o(ps_durdur_w),
        .ps_iki_artir_o(ps_iki_artir_w),
        .durum_sikistirilmis_o(durum_sikistirilmis_w)
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

    reg [31:0] ps_r;
    reg [31:0] buyruk_r;

    always @(*) begin
        kuyruk_aktif_cmb = 0;
        buffer_aktif_ns = buffer_aktif_r;
        buyruk_buffer_ns = buyruk_buffer_r;

        if(buyruk_hazir_i && !durdur_i) begin
            kuyruk_aktif_cmb = 1;
        end
        else if(buyruk_hazir_i && durdur_i) begin
            buyruk_buffer_ns = buyruk_i;
            buffer_aktif_ns = 1;
        end

        if(buffer_aktif_r && !durdur_i) begin
            kuyruk_aktif_cmb = 1;
            buffer_aktif_ns = 0;
        end
    end

    always @(posedge clk_i) begin
        if(!rst_i) begin
            buffer_aktif_r <= 0;
        end
        else begin
            buyruk_buffer_r <= buyruk_buffer_ns;
            buffer_aktif_r <= buffer_aktif_ns;

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
    end


    assign bbellek_durdur_o    = durdur_i;
    assign buyruk_adres_o      = ps_r_w;
    
    assign ps_o                = ps_r;
    assign buyruk_o            = buyruk_r;
    assign ps_uretici_durdur_w = (ps_durdur_w | durdur_i | !kuyruk_buyruk_hazir_w);
    assign ongoru_gecerli_o    = ongoru_gecerli_o_r;

endmodule