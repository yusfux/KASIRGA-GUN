`timescale 1ns / 1ps

module wrapper_cekirdek (
        input clk_i, rst_i,

        // buyruk bellegi <-> getir
        input  [31:0] buyruk_i,
        input         buyruk_hazir_i,
        output [31:0] buyruk_adres_o,
        output        bbellek_durdur_o,

        // veri bellegi <-> bellek 
        input  [31:0] vbellek_veri_i,
        input         vbellek_veri_hazir_i,
        input         vbellek_denetim_hazir_i,
        output        vbellek_onbellekten_oku_o,
        output        vbellek_onbellege_yaz_o,
        output [31:0] vbellek_adres_o,
        output [31:0] vbellek_veri_o,
        output [2:0]  vbellek_buyruk_turu_o,

        // axi <-> bellek
        input [31:0] gc_okunan_veri_i,
        input        gc_veri_gecerli_i,
        input        gc_stall_i,
        output       giris_cikis_aktif_o,
        output       gc_veri_gecerli_o,
    );

    // getir -> buyruk bellegi
    wire [31:0] buyruk_adres_w;
    wire        bbellek_durdur_w;

    // bellek -> veri bellegi
    wire        vbellek_onbellekten_oku_w;
    wire        vbellek_onbellege_yaz_w;
    wire [31:0] vbellek_adres_w;
    wire [31:0] vbellek_veri_w;
    wire [2:0]  vbellek_buyruk_turu_w;

    // bellek -> axi
    wire giris_cikis_aktif_w;
    wire gc_veri_gecerli_w;

    wrapper_getir       asama_getir       (
        .clk_i(clk_i),
        .rst_i(rst_o),
        .durdur_i()

        .buyruk_i(buyruk_i),
        .buyruk_hazir_i(buyruk_hazir_i),
        .buyruk_adres_o(buyruk_adres_w),
        .bbellek_durdur_o(bbellek_durdur_w),

        .guncelle_gecerli_i(),
        .guncelle_atladi_i(),        
        .guncelle_hedef_adresi_i(),
        .guncelle_ps_i(),
        .jal_adres_i(),
        .jal_gecerli_i(),
        .dallanma_hata_i(),

        .ps_o(),
        .buyruk_o(),
        .ongoru_gecerli_o(),
    );

    wrapper_coz         asama_coz         (
        .clk_i(clk_i),
        .rst_i(rst_i),
        
        .instruction_i(),
        .program_counter_i(),
        .branch_taken_i(),

        .reg_write_wb_i(),
        .reg_rd_wb_i(),
        .reg_rd_data_wb_i(),

        .stall_decode_stage_i(),
        .flush_decode_stage_i(),
        .en_stall_decode_stage_o(),

        .en_alu_o(),
        .en_branching_unit_o(),
        .en_ai_unit_o(),
        .en_crypto_unit_o(),
        .en_mem_o(),
        .op_alu_o(),
        .op_ai_o(),
        .op_crypto_o(),
        .op_branching_o(),
        .op_mem_o(),
        .mem_read_o(),
        .mem_write_o(),
        .enable_rs2_conv_o(),
        .reg_write_o(),
        .reg_rd_o(),
        .immediate_o(),
        .reg_rs1_data_o(),
        .reg_rs2_data_o(),

        .program_counter_o(),
        .branch_taken_o(),
        .is_compressed_o()
    );

    wrapper_yurut       asama_yurut       (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .durdur_i(),

        .amb_aktif_i(),
        .yazmac_degeri1_i(),
        .yazmac_degeri2_i(),
        .ps_i(),
        .anlik_i(),
        .amb_islem_kodu_i(),
        .hedef_yazmaci_i(),
        .dallanma_aktif_i(),
        .yazmaca_yaz_i(),
        .load_save_buyrugu_i(),
        .bellege_yaz_i(),
        .bellekten_oku_i(),
        .dallanma_buy_turu_i(),
        .sikistirilmis_mi_i(),

        .dallanma_ongorusu_i(),

        .yapay_zeka_aktif_i(),
        .rs2_en_i(),
        .yz_islem_kodu_i(),
        .yurut_stall_o(),
        
        .kriptografi_aktif_i(),
        .kriptografi_islem_kodu_i(),
        
        .guncelle_gecerli_o(),
        .guncelle_atladi_o(),
        
        .guncelle_ps_o(),
        .guncelle_hedef_adresi_o(),
        .bosalt_o(),
        
        .jal_r_adres_o(),
        .jal_r_adres_gecerli_o(),

        .bellek_adresi_o(),
        .bellek_veri_o(),

        .load_save_buyrugu_o(),
        .bellekten_oku_o(),
        .bellege_yaz_o(),

        .hedef_yazmac_verisi_o(),

        .yazmaca_yaz_o(),
        .hedef_yazmaci_o()
    );

    wrapper_bellek      asama_bellek      (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .hedef_yazmac_verisi_i(),
        .yazmaca_yaz_i(),
        .hedef_yazmaci_i(),
        .bellek_adresi_i(),
        .bellek_veri_i(),
        .load_save_buyrugu_i(),
        .bellekten_oku_i(),
        .bellege_yaz_i(),

        .gc_okunan_veri_i(gc_okunan_veri_i),
        .gc_veri_gecerli_i(gc_veri_gecerli_i),
        .gc_stall_i(gc_stall_i),


        .vbellek_veri_i(vbellek_veri_i),
        .vbellek_veri_hazir_i(vbellek_veri_hazir_i),
        .vbellek_denetim_hazir_i(vbellek_denetim_hazir_i),

        .vbellek_onbellekten_oku_o(vbellek_onbellekten_oku_w),
        .vbellek_onbellege_yaz_o(vbellek_onbellege_yaz_w),
        .vbellek_adres_o(vbellek_adres_w),
        .vbellek_veri_o(vbellek_veri_w),
        .vbellek_buyruk_turu_o(vbellek_buyruk_turu_w),

        .hedef_yazmac_verisi_o(),
        .yazmaca_yaz_o(),
        .bellekten_oku_o(),
        .hedef_yazmaci_o(),
        .bellek_veri_hazir_o(),
        .bellek_veri_o(),

        .giris_cikis_aktif_o(giris_cikis_aktif_w),
        .gc_veri_gecerli_o(gc_veri_gecerli_w),        

        .durdur_o()
    );

    wrapper_geri_yaz    asama_geri_yaz    (
        .bellekten_oku_i(),
        .yazmaca_yaz_i(),
        .hedef_yazmaci_i(),
        .hedef_yazmac_verisi_i(),
        .bellek_veri_hazir_i(),
        .bellek_veri_i(),
        .gc_veri_gecerli_i(),
        .gc_okunan_veri_i(),

        .yazmaca_yaz_o(),
        .hedef_yazmaci_o(),
        .yazmac_veri_o(),
    );

    pipeline_controller boruhatti_denetim (
        .en_stall_decode_stage_i(),
        .en_stall_execute_stage_i(),
        .en_stall_memory_stage_i(),

        .en_flush_branch_misprediction_i(),

        .stall_fetch_stage_o(),
        .stall_decode_stage_o(),
        .stall_execute_stage_o(),

        .flush_decode_stage_(),
    );

    // getir -> buyruk bellegi
    assign buyruk_adres_o   = buyruk_adres_w;
    assign bbellek_durdur_o = bbellek_durdur_w;

    // bellek -> veri bellegi
    assign vbellek_onbellekten_oku_o = vbellek_onbellekten_oku_w;
    assign vbellek_onbellege_yaz_o   = vbellek_onbellege_yaz_w;
    assign vbellek_adres_o           = vbellek_adres_w;
    assign vbellek_veri_o            = vbellek_veri_w;
    assign vbellek_buyruk_turu_o     = vbellek_buyruk_turu_w;

    // bellek -> axi
    assign giris_cikis_aktif_o = giris_cikis_aktif_w;
    assign gc_veri_gecerli_o   = gc_veri_gecerli_w;

endmodule