`timescale 1ns / 1ps

// en_flush_mret_instruction_o_w cozden cikiyor, bosta kaldi

module user_processor(
      input         clk,       
      input         resetn,       
      output        iomem_valid,  
      input         iomem_ready,  
      output [3:0]  iomem_wstrb,  
      output [31:0] iomem_addr,   
      output [31:0] iomem_wdata,  
      input  [31:0] iomem_rdata,  
      output        spi_cs_o,  // ayarlanmali   
      output        spi_sck_o, // ayarlanmali   
      output        spi_mosi_o,// ayarlanmali   
      input         spi_miso_i, // ayarlanmali  
      output        uart_tx_o,    
      input         uart_rx_i,    
      output        pwm0_o,       
      output        pwm1_o       
    );
    
    // GETIR -> COZ
    wire      [31:0]       ps_o_w;
    wire      [31:0]       buyruk_o_w;
    wire                   dallanma_ongorusu_o_w;
    
    // YURUT -> GETIR
    wire                   guncelle_gecerli_o_w;
    wire                   guncelle_atladi_o_w;
    wire      [31:0]       guncelle_hedef_adresi_o_w;
    wire      [31:0]       jal_r_adres_o_w;
    wire      [31:0]       guncelle_ps_o_w;
    wire                   jal_r_adres_gecerli_o_w;
    
    // PIPELINE CONTROLLER -> GETIR
    wire                   en_excep_program_counter_o_w;
    wire      [31:0]       excep_program_counter_o_w;
    
     // PIPELINE CONTROLLER stall/flush
    wire                   stall_fetch_stage_o_w;
    wire                   stall_decode_stage_o_w;
    wire                   stall_execute_stage_o_w;
    wire                   flush_fetch_stage_o_w;
    wire                   flush_decode_stage_o_w;
    wire                   flush_execute_stage_o_w;
    
    // DURDUR/FLUSH SINYALLERI
    wire                   bellek_durdur_o_w;
    wire                   yz_stall_o_w;
    wire                   yurut_flush_o_w;
    wire                   dallanma_hata_o_w;
    wire                   en_flush_mret_instruction_o_w;
    wire                   en_exception_o_w;  
    wire      [31:0]       exception_program_counter_o_w;  
    assign  yurut_flush_o_w = dallanma_hata_o_w || jal_r_adres_gecerli_o_w; // dallanma biriminden ya da jal/jalr -> COZ
	  
    // BUYRUK ONBELLEK - ANABELLEK DENETLEY�C�
    wire                   getir_asamasi_istek_o_w;
    wire      [31:0]       getir_adres_o_w;
    wire                   getir_oku_o_w;
    wire                   getir_asamasina_veri_hazir_o_w;
	 
    // ANABELLEK DENETLEYICI -> BUYRUK + VERI ONBELLEK
    wire      [127:0]      okunan_veri_obegi_o_w;
    wire                   anabellek_musait_o_w;
    
    // FROM PIPELINE CONTROLLER - COMBINATONAL
    wire      [2:0]        exception_cause_o_w;
    wire      [31:0]       exception_adress_o_w;
  
    //TO PIPELINE CONTROLLER - COMBINATIONAL
    wire                   [31:0] program_counter_decode_stage_o_w;
    wire                   en_stall_decode_stage_o_w;
    wire                   exception_illegal_instruction_o_w;
    wire                   exception_breakpoint_o_w;
    wire                   exception_env_call_from_M_mode_o_w;

    // COZ -> YURUT
    wire                   en_alu_o_w;
    wire                   en_branching_unit_o_w;
    wire                   en_ai_unit_o_w;
    wire                   en_crypto_unit_o_w;
    wire                   en_mem_o_w;
    wire      [5:0]        op_alu_o_w;
    wire      [2:0]        op_ai_o_w;
    wire      [2:0]        op_crypto_o_w;
    wire      [2:0]        op_branching_o_w;
    wire      [2:0]        op_mem_o_w;
    wire                   mem_read_o_w;
    wire                   mem_write_o_w;
    wire                   enable_rs2_conv_o_w;
    wire                   reg_write_o_w;
    wire      [4:0]        reg_rd_o_w;
    wire      [31:0]       immediate_o_w;
    wire      [31:0]       reg_rs1_data_o_w;
    wire      [31:0]       reg_rs2_data_o_w;
    wire      [31:0]       program_counter_o_w;
    wire                   branch_taken_o_w;
    
    // GERI YAZ -> COZ
    wire                   gy_yazmaca_yaz_o_w;
    wire      [4:0]        gy_hedef_yazmaci_o_w;
    wire      [31:0]       gy_yazmac_veri_o_w;
	 
	 // YURUT -> BELLEK
    wire      [31:0]       bellek_adresi_o_w;
	wire      [31:0]       bellek_veri_o_w; // bellege yazilacak olan veri
    wire      [2:0]        load_save_buyrugu_o_w;
    wire                   bellekten_oku_o_w;
    wire                   bellege_yaz_o_w;
	 
    // YURUT -> GERI YAZ	
    wire      [31:0]       hedef_yazmac_verisi_o_w;
	wire                   yazmaca_yaz_o_w;
	wire      [4:0]        hedef_yazmaci_o_w;

    // GIRIS/CIKIS
    wire                   tx_o_w;
	 wire                  pwm1_o_w;
    wire                   pwm2_o_w;
    wire                   gc_veri_gecerli_o_w;
    wire      [31:0]       gc_okunan_veri_o_w; // gc_veri_gecerli_o 1 ise yazmaca yazilmasi icin
    
	 // BELLEK -> GERI YAZ
    wire      [31:0]       hedef_yazmac_verisi_bellek_o_w;
    wire                   yazmaca_yaz_bellek_o_w;
    wire      [4:0]        hedef_yazmaci_bellek_o_w;
    wire                   bellek_veri_hazir_o_w;
    wire      [31:0]       bellek_geriyaz_veri_o_w;
    
	 // ANABELLEK DENETLEYICI -> BELLEK
    wire                   bellek_asamasina_veri_hazir_o_w;
    
    // VERI ONBELLEK DENETLEYICI -> ANABELLEK DENETLEYICI
    wire                   bellek_asamasi_istek_o_w;
    wire      [31:0]       bellek_adres_o_w;               // obegin baslangic adresi yani hep 32'bx0000 seklinde
    wire                   bellek_oku_o_w;
    wire                   bellek_yaz_o_w;
    wire      [127:0]      yazilacak_veri_obegi_o_w;

    wire bellekten_oku_w;
	 
    getir getir_pipeline (
        .clk_i(clk),
        .rst_i(resetn),
        .guncelle_gecerli_i(guncelle_gecerli_o_w),
        .guncelle_atladi_i(guncelle_atladi_o_w),        
        .guncelle_hedef_adresi_i(guncelle_hedef_adresi_o_w),
        .guncelle_ps_i(guncelle_ps_o_w),
        .jal_adres_i(jal_r_adres_o_w),
        .jal_gecerli_i(jal_r_adres_gecerli_o_w),
        .dallanma_hata_i(dallanma_hata_o_w),
        .durdur_i(stall_fetch_stage_o_w),
        .ps_o(ps_o_w),
        .buyruk_o(buyruk_o_w),
        .ongoru_gecerli_o(dallanma_ongorusu_o_w),
        .getir_asamasi_istek_o(getir_asamasi_istek_o_w),  
        .getir_adres_o(getir_adres_o_w),          
        .getir_oku_o(getir_oku_o_w),
        .anabellek_musait_i(anabellek_musait_o_w),
        .getir_asamasina_veri_hazir_i(getir_asamasina_veri_hazir_o_w),
        .okunan_obek_i(okunan_veri_obegi_o_w),
        .mret_gecerli_i(en_excep_program_counter_o_w),
        .mret_ps_i(excep_program_counter_o_w)    
    );
    
    wrapper_decode coz_pipeline(
            // inputs
        .clk_i(clk),
        .rst_i(resetn),
        
        //FROM FETCH STAGE - POSEDGE
        .instruction_i(buyruk_o_w),
        .program_counter_i(ps_o_w),
        .branch_taken_i(dallanma_ongorusu_o_w),

        // *** FROM WRITE-BACK STAGE - COMBINATIONAL
        .reg_write_wb_i(gy_yazmaca_yaz_o_w),
        .reg_rd_wb_i(gy_hedef_yazmaci_o_w),
        .reg_rd_data_wb_i(gy_yazmac_veri_o_w),

        //FROM PIPELINE CONTROLLER - COMBINATONAL
        .stall_decode_stage_i(stall_decode_stage_o_w),
        .flush_decode_stage_i(flush_decode_stage_o_w),
        .en_exception_i(en_exception_o_w),   
        .exception_cause_i(exception_cause_o_w),
        .exception_adress_i(exception_adress_o_w),
        .exception_program_counter_i(exception_program_counter_o_w),
            // outputs
        //TO PIPELINE CONTROLLER - COMBINATIONAL
        .program_counter_decode_stage_o(program_counter_decode_stage_o_w),
        .en_stall_decode_stage_o(en_stall_decode_stage_o_w),
        .en_flush_mret_instruction_o(en_flush_mret_instruction_o_w),//*
        .exception_illegal_instruction_o(exception_illegal_instruction_o_w),
        .exception_breakpoint_o(exception_breakpoint_o_w),
        .exception_env_call_from_M_mode_o(exception_env_call_from_M_mode_o_w),

        //TO FETCH STAGE - COMBINATIONAL
        .en_excep_program_counter_o(en_excep_program_counter_o_w),
        .excep_program_counter_o(excep_program_counter_o_w),

        //TO EXECUTION STAGE - POSEDGE
        .en_alu_o(en_alu_o_w),
        .en_branching_unit_o(en_branching_unit_o_w),  
        .en_ai_unit_o(en_ai_unit_o_w),     
        .en_crypto_unit_o(en_crypto_unit_o_w),
        .en_mem_o(en_mem_o_w),
        .op_alu_o(op_alu_o_w),
        .op_ai_o(op_ai_o_w),   
        .op_crypto_o(op_crypto_o_w),
        .op_branching_o(op_branching_o_w),
        .op_mem_o(op_mem_o_w),
        .mem_read_o(mem_read_o_w),
        .mem_write_o(mem_write_o_w),
        .enable_rs2_conv_o(enable_rs2_conv_o_w),
        .reg_write_o(reg_write_o_w),
        .reg_rd_o(reg_rd_o_w),
        .immediate_o(immediate_o_w),
        .reg_rs1_data_o(reg_rs1_data_o_w),
        .reg_rs2_data_o(reg_rs2_data_o_w),

        .program_counter_o(program_counter_o_w),
        .branch_taken_o(branch_taken_o_w)
    );
    
    pipeline_controller pipeline_denetim (
        .en_stall_decode_stage_i(en_stall_decode_stage_o_w),
        .en_stall_execute_stage_i(yz_stall_o_w),
        .en_stall_memory_stage_i(bellek_durdur_o_w),
        
        .en_flush_branch_misprediction_i(yurut_flush_o_w),
        
        .program_counter_fetch_stage_i(ps_o_w),
        .program_counter_decode_stage_i(program_counter_decode_stage_o_w),
        //.program_counter_memory_stage_i,
        
        //.adress_memory_stage_i,
        
        //.exception_instr_adress_misaligned_i,
        .exception_illegal_instruction_i(exception_illegal_instruction_o_w),
        .exception_breakpoint_i(exception_breakpoint_o_w),
        //.exception_load_adress_misaligned_i,
        //.exception_store_adress_misaligned_i,
        .exception_env_call_from_M_mode_i(exception_env_call_from_M_mode_o_w),


        .en_exception_o(en_exception_o_w),
        .exception_program_counter_o(exception_program_counter_o_w),
        .exception_adress_o(exception_adress_o_w),
        .exception_cause_o(exception_cause_o_w),
        
        .stall_fetch_stage_o(stall_fetch_stage_o_w),
        .stall_decode_stage_o(stall_decode_stage_o_w),
        .stall_execute_stage_o(stall_execute_stage_o_w),
        
        .flush_fetch_stage_o(flush_fetch_stage_o_w),
        .flush_decode_stage_o(flush_decode_stage_o_w),
        .flush_execute_stage_o(flush_execute_stage_o_w)
    );
    
    yurut_wrapper pipeline_yurut(
        .clk_i(clk),
        .rst_i(resetn),
        .durdur_i(stall_execute_stage_o_w),
        .bosalt_i(flush_execute_stage_o_w),
        // \-------------------- COZ-YURUT -> AMB, ORTAK ------------------------------/
        .amb_aktif_i(en_alu_o_w),
        .yazmac_degeri1_i(reg_rs1_data_o_w),  
        .yazmac_degeri2_i(reg_rs2_data_o_w),
        .ps_i(program_counter_o_w),
        .anlik_i(immediate_o_w), 
        .amb_islem_kodu_i(op_alu_o_w),       
        .hedef_yazmaci_i(reg_rd_o_w),
        .dallanma_aktif_i(en_branching_unit_o_w),
        .yazmaca_yaz_i(reg_write_o_w),
        .load_save_buyrugu_i(op_mem_o_w),//*       
        .bellege_yaz_i(mem_write_o_w), 
        .bellekten_oku_i(mem_read_o_w), 
        .dallanma_buy_turu_i(op_branching_o_w), 
        // GETIR->COZ->YURUT
        .dallanma_ongorusu_i(branch_taken_o_w),
        // \--------------------- COZ-YURUT -> YAPAY ZEKA -----------------------------/		
        .yapay_zeka_aktif_i(en_ai_unit_o_w),
        .rs2_en_i(enable_rs2_conv_o_w),
        .yz_islem_kodu_i(op_ai_o_w),
        .yz_stall_o(yz_stall_o_w), // boru hattinin durdurulmasini soyleyen sinyal
        // \--------------------- COZ-YURUT -> KRIPTOGRAFI ----------------------------/		
        .kriptografi_aktif_i(en_crypto_unit_o_w),
        .kriptografi_islem_kodu_i(op_crypto_o_w),
        // \--------------------- YURUT-GETIR -> DALLANMA -----------------------------/    	        
        // Dallanma ongorucusune
        .guncelle_gecerli_o(guncelle_gecerli_o_w), 
        .guncelle_atladi_o(guncelle_atladi_o_w), 
        // Dallanma ongorucusu + ps ureticisine
        .guncelle_ps_o(guncelle_ps_o_w),
        .guncelle_hedef_adresi_o(guncelle_hedef_adresi_o_w), 
        .bosalt_o(dallanma_hata_o_w), // ayni zamanda boru hattinin bosaltilmasini soyleyen sinyal, kombinasyonel
        // PS ureticisine (jump buyru?undan sonra gidilecek adres)
        .jal_r_adres_o(jal_r_adres_o_w),  
        .jal_r_adres_gecerli_o(jal_r_adres_gecerli_o_w), // bu adresin gecerli olduguna dair sinyal, getir bunu kontrol edecek, ayni zamanda boru hattinin bosaltilmasini soyleyen sinyal  
        // \--------------------- YURUT-BELLEK ----------------------------------------/		
        .bellek_adresi_o(bellek_adresi_o_w),
        .bellek_veri_o(bellek_veri_o_w), // bellege yazilacak olan veri
        // COZ->YURUT->BELLEK
        .load_save_buyrugu_o(load_save_buyrugu_o_w),
        .bellekten_oku_o(bellekten_oku_o_w),
        .bellege_yaz_o(bellege_yaz_o_w),
        // \--------------------- YURUT-GERI YAZ --------------------------------------/		
        .hedef_yazmac_verisi_o(hedef_yazmac_verisi_o_w),
        // COZ->YURUT->GERI YAZ
        .yazmaca_yaz_o(yazmaca_yaz_o_w),
        .hedef_yazmaci_o(hedef_yazmaci_o_w)
    );
            
    anabellek_denetleyici pipeline_ab_denetleyici(
         .clk_i(clk),
         .rst_i(resetn),      
          // getirle baglantisi 
         .getir_asamasi_istek_i(getir_asamasi_istek_o_w),
         .getir_adres_i(getir_adres_o_w),              // obegin baslangic adresi yani hep 32'bx0000 seklinde
         .getir_oku_i(getir_oku_o_w),    
         //BELLEK asamasindan gelecek sinyaller  
         .bellek_asamasi_istek_i(bellek_asamasi_istek_o_w),
         .bellek_adres_i(bellek_adres_o_w),             // obegin baslangic adresi yani hep 32'bx0000 seklinde
         .bellek_oku_i(bellek_oku_o_w),
         .bellek_yaz_i(bellek_yaz_o_w),
         .yazilacak_veri_obegi_i(yazilacak_veri_obegi_o_w),
   
         //anabellekten gelecek sinyaller
         .iomem_ready_i(iomem_ready),
         .anabellekten_veri_i(iomem_rdata),
         //anabellege gidecek sinyaller
         .adres_o(iomem_addr),                    // obegin baslangic adresi yani hep 32'bx0000 seklinde
         .yaz_veri_o(iomem_wdata),                 // parca parca yaziyor
         .iomem_valid_o(iomem_valid),
         .wr_strb_o(iomem_wstrb),
         
         //onbellek denetleyicilere gidecek sinyaller
         .anabellek_musait_o(anabellek_musait_o_w),        //bu sinyal bellege yazma islemi bittiginde 1 olacagi icin ayrica yazilan_veri_hazir_o sinyali yok
         .okunan_veri_obegi_o(okunan_veri_obegi_o_w),    
         .bellek_asamasina_veri_hazir_o(bellek_asamasina_veri_hazir_o_w),
         .getir_asamasina_veri_hazir_o(getir_asamasina_veri_hazir_o_w)
    );
    
    bellek_wrapper pipeline_bellek(
        .clk_i(clk),            //active-low reset
        .rst_i(resetn),
      
        // \--------------------- YURUT-GERI YAZ --------------------------------------/		
        .hedef_yazmac_verisi_i(hedef_yazmac_verisi_o_w),
        .hedef_yazmac_verisi_o(hedef_yazmac_verisi_bellek_o_w),
        // COZ->YURUT->GERI YAZ
        .yazmaca_yaz_i(yazmaca_yaz_o_w),
        .hedef_yazmaci_i(hedef_yazmaci_o_w),
        .yazmaca_yaz_o(yazmaca_yaz_bellek_o_w),
        .hedef_yazmaci_o(hedef_yazmaci_bellek_o_w),
        .bellek_veri_hazir_o(bellek_veri_hazir_o_w),
        .bellek_veri_o(bellek_geriyaz_veri_o_w),
        // \--------------------- YURUT-BELLEK ----------------------------------------/		
        .bellek_adresi_i(bellek_adresi_o_w),
        .bellek_veri_i(bellek_veri_o_w), // bellege yazilacak olan veri
        // COZ->YURUT->BELLEK
        .load_save_buyrugu_i(load_save_buyrugu_o_w),
        .bellekten_oku_i(bellekten_oku_o_w),
        .bellege_yaz_i(bellege_yaz_o_w),
        // \--------------------- BELLEK-ANABELLEK DENETLEYICI-------------------------/
        .anabellek_musait_i(anabellek_musait_o_w),        
        .okunan_veri_obegi_i(okunan_veri_obegi_o_w),
        .bellek_asamasina_veri_hazir_i(bellek_asamasina_veri_hazir_o_w),
       
        .bellek_asamasi_istek_o(bellek_asamasi_istek_o_w),
        .bellek_adres_o(bellek_adres_o_w),             // obegin baslangic adresi yani hep 32'bx0000 seklinde
        .bellek_oku_o(bellek_oku_o_w),
        .bellek_yaz_o(bellek_yaz_o_w),
        .yazilacak_veri_obegi_o(yazilacak_veri_obegi_o_w),
       //\---------------------------------------------------------/
        .durdur_o(bellek_durdur_o_w),
        .rx_i(uart_rx_i),
        .tx_o(tx_o_w),
        .pwm1_o(pwm1_o_w),
        .pwm2_o(pwm2_o_w),
        .gc_veri_gecerli_o(gc_veri_gecerli_o_w),
        .gc_okunan_veri_o(gc_okunan_veri_o_w), // gc_veri_gecerli_o 1 ise yazmaca yazilmasi icin
        .bellekten_oku_o(bellekten_oku_w)
    );
    
    geri_yaz_wrapper pipeline_geri_yaz(
        .bellekten_oku_i(bellekten_oku_w),
        .yazmaca_yaz_i(yazmaca_yaz_bellek_o_w),
        .hedef_yazmaci_i(hedef_yazmaci_bellek_o_w),
        .yazmaca_yaz_o(gy_yazmaca_yaz_o_w),
        .hedef_yazmaci_o(gy_hedef_yazmaci_o_w),    
        .hedef_yazmac_verisi_i(hedef_yazmac_verisi_bellek_o_w),   
        .bellek_veri_hazir_i(bellek_veri_hazir_o_w),
        .bellek_veri_i(bellek_geriyaz_veri_o_w),
        .gc_veri_gecerli_i(gc_veri_gecerli_o_w),
        .gc_okunan_veri_i(gc_okunan_veri_o_w), 
        .yazmac_veri_o(gy_yazmac_veri_o_w)
    );
  
    assign uart_tx_o = tx_o_w;
    assign pwm0_o = pwm1_o_w;
    assign pwm1_o = pwm2_o_w;
    assign spi_cs_o = 0;  // ayarlanmali   
    assign spi_sck_o = 0; // ayarlanmali   
    assign spi_mosi_o = 0;// ayarlanmali   

    
    
    
endmodule
