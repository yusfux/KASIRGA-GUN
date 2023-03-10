`timescale 1ns / 1ps

module wrapper_cekirdek (
        input clk_i, rst_i,

        // buyruk bellegi <-> getir
        input  [31:0] buyruk_i,
        input         buyruk_hazir_i,
        output [31:0] buyruk_adres_o,
        output        bbellek_durdur_o,
        output        ps_guncellendi_o,

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

        output       timer_o
    );

    //-----------------------------------------------------------------------------------
    //------------------------ CEKIRDEK DISINA CIKACAK SINYALLER ------------------------
    //-----------------------------------------------------------------------------------

    // getir -> buyruk bellegi
    wire [31:0] buyruk_adres_w;
    wire        bbellek_durdur_w;
    wire        ps_guncellendi_w;

    // bellek -> veri bellegi
    wire        vbellek_onbellekten_oku_w;
    wire        vbellek_onbellege_yaz_w;
    wire [31:0] vbellek_adres_w;
    wire [31:0] vbellek_veri_w;
    wire [2:0]  vbellek_buyruk_turu_w;

    // bellek -> axi
    wire giris_cikis_aktif_w;


    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------


    // getir -> coz
    wire [31:0] ps_w;
    wire [31:0] buyruk_w;
    wire        ongoru_gecerli_w;

    // coz -> yurut
    wire        en_alu_w;
    wire        en_branching_unit_w;
    wire        en_ai_unit_w;
    wire        en_crypto_unit_w;
    wire        en_mem_w;
    wire [5:0]  op_alu_w;
    wire [2:0]  op_ai_w;
    wire [2:0]  op_crypto_w;
    wire [2:0]  op_branching_w;
    wire [2:0]  op_mem_w;
    wire        mem_read_w;
    wire        mem_write_w;
    wire        enable_rs2_conv_w;
    wire        reg_write_w;
    wire [4:0]  reg_rd_w;
    wire [31:0] immediate_w;
    wire [31:0] reg_rs1_data_w;
    wire [31:0] reg_rs2_data_w;
    wire [31:0] program_counter_w;
    wire        branch_taken_w;
    wire        is_compressed_w;
    
    // YURUT -> GETIR
    wire        guncelle_gecerli_w;
    wire        guncelle_atladi_w;
    wire [31:0] guncelle_hedef_adresi_w;
    wire [31:0] jal_r_adres_w;
    wire [31:0] guncelle_ps_w;
    wire        jal_r_adres_gecerli_w;
    
     // PIPELINE CONTROLLER
    wire stall_fetch_stage_w;
    wire stall_decode_stage_w;
    wire stall_execute_stage_w;
    wire flush_decode_stage_w;
    
    // DURDUR/FLUSH SINYALLERI
    wire vbellek_durdur_w;
    wire yurut_stall_w;
    wire yurut_flush_w;
    wire dallanma_hata_w;
  
    //TO PIPELINE CONTROLLER - COMBINATIONAL
    wire en_stall_decode_stage_w;
    
    // GERI YAZ -> COZ
    wire        gy_yazmaca_yaz_w;
    wire [4:0]  gy_hedef_yazmaci_w;
    wire [31:0] gy_yazmac_veri_w;
	 
    // YURUT -> BELLEK
    wire [31:0] bellek_adresi_o_w;
	wire [31:0] bellek_veri_o_w;
    wire [2:0]  load_save_buyrugu_o_w;
    wire        bellekten_oku_o_w;
    wire        bellege_yaz_o_w;
	 
    // YURUT -> GERI YAZ	
    wire [31:0] hedef_yazmac_verisi_o_w;
	wire        yazmaca_yaz_o_w;
	wire [4:0]  hedef_yazmaci_o_w;

    // GIRIS/CIKIS
    wire        gc_veri_gecerli_w;
    wire [31:0] gc_okunan_veri_w;
    
	 // BELLEK -> GERI YAZ
    wire [31:0] hedef_yazmac_verisi_bellek_w;
    wire        yazmaca_yaz_bellek_w;
    wire [4:0]  hedef_yazmaci_bellek_w;
    wire        bellek_veri_hazir_w;
    wire [31:0] bellek_geriyaz_veri_w;
    
    wire bellekten_oku_haha_w;

    wire timer_w;
    assign timer_o = timer_w; 

    wrapper_getir       asama_getir       (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .durdur_i(stall_fetch_stage_w),

        .buyruk_i(buyruk_i),
        .buyruk_hazir_i(buyruk_hazir_i),
        .buyruk_adres_o(buyruk_adres_w),
        .bbellek_durdur_o(bbellek_durdur_w),
        .ps_guncellendi_o(ps_guncellendi_w),

        .guncelle_gecerli_i(guncelle_gecerli_w),
        .guncelle_atladi_i(guncelle_atladi_w),        
        .guncelle_hedef_adresi_i(guncelle_hedef_adresi_w),
        .guncelle_ps_i(guncelle_ps_w),
        .jal_adres_i(jal_r_adres_w),
        .jal_gecerli_i(jal_r_adres_gecerli_w),
        .dallanma_hata_i(dallanma_hata_w),

        .ps_o(ps_w),
        .buyruk_o(buyruk_w),
        .ongoru_gecerli_o(ongoru_gecerli_w)
    );

    wrapper_coz         asama_coz         (
        .clk_i(clk_i),
        .rst_i(rst_i),
        
        .instruction_i(buyruk_w),
        .program_counter_i(ps_w),
        .branch_taken_i(ongoru_gecerli_w),

        .reg_write_wb_i(gy_yazmaca_yaz_w),
        .reg_rd_wb_i(gy_hedef_yazmaci_w),
        .reg_rd_data_wb_i(gy_yazmac_veri_w),

        .stall_decode_stage_i(stall_decode_stage_w),
        .flush_decode_stage_i(flush_decode_stage_w),
        .en_stall_decode_stage_o(en_stall_decode_stage_w),

        .en_alu_o(en_alu_w),
        .en_branching_unit_o(en_branching_unit_w),  
        .en_ai_unit_o(en_ai_unit_w),     
        .en_crypto_unit_o(en_crypto_unit_w),
        .en_mem_o(en_mem_w),
        .op_alu_o(op_alu_w),
        .op_ai_o(op_ai_w),   
        .op_crypto_o(op_crypto_w),
        .op_branching_o(op_branching_w),
        .op_mem_o(op_mem_w),
        .mem_read_o(mem_read_w),
        .mem_write_o(mem_write_w),
        .enable_rs2_conv_o(enable_rs2_conv_w),
        .reg_write_o(reg_write_w),
        .reg_rd_o(reg_rd_w),
        .immediate_o(immediate_w),
        .reg_rs1_data_o(reg_rs1_data_w),
        .reg_rs2_data_o(reg_rs2_data_w),

        .program_counter_o(program_counter_w),
        .branch_taken_o(branch_taken_w),
        .is_compressed_o(is_compressed_w)
    );

    wrapper_yurut       asama_yurut       (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .durdur_i(stall_execute_stage_w),

        .amb_aktif_i(en_alu_w),
        .yazmac_degeri1_i(reg_rs1_data_w),
        .yazmac_degeri2_i(reg_rs2_data_w),
        .ps_i(program_counter_w),
        .anlik_i(immediate_w),
        .amb_islem_kodu_i(op_alu_w),
        .hedef_yazmaci_i(reg_rd_w),
        .dallanma_aktif_i(en_branching_unit_w),
        .yazmaca_yaz_i(reg_write_w),
        .load_save_buyrugu_i(op_mem_w),
        .bellege_yaz_i(mem_write_w),
        .bellekten_oku_i(mem_read_w),
        .dallanma_buy_turu_i(op_branching_w),
        .sikistirilmis_mi_i(is_compressed_w),

        .dallanma_ongorusu_i(branch_taken_w),

        .yapay_zeka_aktif_i(en_ai_unit_w),
        .rs2_en_i(enable_rs2_conv_w),
        .yz_islem_kodu_i(op_ai_w),
        .yurut_stall_o(yurut_stall_w),

        .kriptografi_aktif_i(en_crypto_unit_w),
        .kriptografi_islem_kodu_i(op_crypto_w),

        .guncelle_gecerli_o(guncelle_gecerli_w),
        .guncelle_atladi_o(guncelle_atladi_w),

        .guncelle_ps_o(guncelle_ps_w),
        .guncelle_hedef_adresi_o(guncelle_hedef_adresi_w),
        .bosalt_o(dallanma_hata_w),

        .jal_r_adres_o(jal_r_adres_w),
        .jal_r_adres_gecerli_o(jal_r_adres_gecerli_w),

        .bellek_adresi_o(bellek_adresi_o_w),
        .bellek_veri_o(bellek_veri_o_w),

        .load_save_buyrugu_o(load_save_buyrugu_o_w),
        .bellekten_oku_o(bellekten_oku_o_w),
        .bellege_yaz_o(bellege_yaz_o_w),

        .hedef_yazmac_verisi_o(hedef_yazmac_verisi_o_w),

        .yazmaca_yaz_o(yazmaca_yaz_o_w),
        .hedef_yazmaci_o(hedef_yazmaci_o_w)
    );

    wrapper_bellek      asama_bellek      (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .hedef_yazmac_verisi_i(hedef_yazmac_verisi_o_w),
        .yazmaca_yaz_i(yazmaca_yaz_o_w),
        .hedef_yazmaci_i(hedef_yazmaci_o_w),
        .bellek_adresi_i(bellek_adresi_o_w),
        .bellek_veri_i(bellek_veri_o_w),
        .load_save_buyrugu_i(load_save_buyrugu_o_w),
        .bellekten_oku_i(bellekten_oku_o_w),
        .bellege_yaz_i(bellege_yaz_o_w),

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

        .hedef_yazmac_verisi_o(hedef_yazmac_verisi_bellek_w),
        .yazmaca_yaz_o(yazmaca_yaz_bellek_w),
        .bellekten_oku_o(bellekten_oku_haha_w),
        .hedef_yazmaci_o(hedef_yazmaci_bellek_w),
        .bellek_veri_hazir_o(bellek_veri_hazir_w),
        .bellek_veri_o(bellek_geriyaz_veri_w),
        .gc_okunan_veri_o(gc_okunan_veri_w),
        .gc_veri_gecerli_o(gc_veri_gecerli_w),        

        .giris_cikis_aktif_o(giris_cikis_aktif_w),
        
        .timer_o(timer_w),

        .durdur_o(vbellek_durdur_w)
    );

    wrapper_geri_yaz    asama_geri_yaz    (
        .bellekten_oku_i(bellekten_oku_haha_w),
        .yazmaca_yaz_i(yazmaca_yaz_bellek_w),
        .hedef_yazmaci_i(hedef_yazmaci_bellek_w),
        .hedef_yazmac_verisi_i(hedef_yazmac_verisi_bellek_w),
        .bellek_veri_hazir_i(bellek_veri_hazir_w),
        .bellek_veri_i(bellek_geriyaz_veri_w),
        .gc_veri_gecerli_i(gc_veri_gecerli_w),
        .gc_okunan_veri_i(gc_okunan_veri_w),

        .yazmaca_yaz_o(gy_yazmaca_yaz_w),
        .hedef_yazmaci_o(gy_hedef_yazmaci_w),
        .yazmac_veri_o(gy_yazmac_veri_w)
    );

    pipeline_controller boruhatti_denetim (
        .en_stall_decode_stage_i(en_stall_decode_stage_w),
        .en_stall_execute_stage_i(yurut_stall_w),
        .en_stall_memory_stage_i(vbellek_durdur_w),
        
        .en_flush_branch_misprediction_i(yurut_flush_w),
        
        .stall_fetch_stage_o(stall_fetch_stage_w),
        .stall_decode_stage_o(stall_decode_stage_w),
        .stall_execute_stage_o(stall_execute_stage_w),
        
        .flush_decode_stage_o(flush_decode_stage_w)
    );

    // getir -> buyruk bellegi
    assign buyruk_adres_o   = buyruk_adres_w;
    assign bbellek_durdur_o = bbellek_durdur_w;
    assign ps_guncellendi_o = ps_guncellendi_w;

    // bellek -> veri bellegi
    assign vbellek_onbellekten_oku_o = vbellek_onbellekten_oku_w;
    assign vbellek_onbellege_yaz_o   = vbellek_onbellege_yaz_w;
    assign vbellek_adres_o           = vbellek_adres_w;
    assign vbellek_veri_o            = vbellek_veri_w;
    assign vbellek_buyruk_turu_o     = vbellek_buyruk_turu_w;

    // bellek -> axi
    assign giris_cikis_aktif_o = giris_cikis_aktif_w;

    assign yurut_flush_w = dallanma_hata_w || jal_r_adres_gecerli_w;  //????

endmodule