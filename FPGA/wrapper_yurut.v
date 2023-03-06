`timescale 1ns / 1ps 

module wrapper_yurut (
        input                    clk_i,
        input                    rst_i,
        input                    durdur_i,
        // \-------------------- COZ-YURUT -> AMB, ORTAK ------------------------------/
        input                    amb_aktif_i,
        input       [31:0]       yazmac_degeri1_i,
        input       [31:0]       yazmac_degeri2_i,
        input		[31:0]		 ps_i,
        input       [31:0]       anlik_i, 
        input       [5:0]        amb_islem_kodu_i,       
        input       [4:0]        hedef_yazmaci_i,
        input                    dallanma_aktif_i,
        input                    yazmaca_yaz_i,
        input       [2:0]        load_save_buyrugu_i,       
        input                    bellege_yaz_i, 
        input                    bellekten_oku_i, 
        input       [2:0]        dallanma_buy_turu_i, 
        input 					 sikistirilmis_mi_i,
        // GETIR->COZ->YURUT
        input                    dallanma_ongorusu_i,
        // \--------------------- COZ-YURUT -> YAPAY ZEKA -----------------------------/		
        input                    yapay_zeka_aktif_i,
        input                    rs2_en_i,
        input       [2:0]        yz_islem_kodu_i,
        output                   yurut_stall_o, // boru hattinin durdurulmasini soyleyen sinyal
        // \--------------------- COZ-YURUT -> KRIPTOGRAFI ----------------------------/		
        input                    kriptografi_aktif_i,
        input       [2:0]        kriptografi_islem_kodu_i,
        // \--------------------- YURUT-GETIR -> DALLANMA -----------------------------/    	        
        // Dallanma ongorucusune
        output                   guncelle_gecerli_o, 
        output                   guncelle_atladi_o, 
        // Dallanma ongorucusu + ps ureticisine
        output      [31:0]       guncelle_ps_o,
        output 	    [31:0]		 guncelle_hedef_adresi_o, 
        output                   bosalt_o, // ayni zamanda boru hattinin bosaltilmasini soyleyen sinyal, kombinasyonel
        // PS ureticisine (jump buyru?undan sonra gidilecek adres)
        output      [31:0]       jal_r_adres_o,  
        output                   jal_r_adres_gecerli_o, // bu adresin gecerli olduguna dair sinyal, getir bunu kontrol edecek, ayni zamanda boru hattinin bosaltilmasini soyleyen sinyal  
        // \--------------------- YURUT-BELLEK ----------------------------------------/		
        output      [31:0]       bellek_adresi_o,
        output      [31:0]       bellek_veri_o, // bellege yazilacak olan veri
        // COZ->YURUT->BELLEK
        output      [2:0]        load_save_buyrugu_o,
        output                   bellekten_oku_o,
        output                   bellege_yaz_o,
        // \--------------------- YURUT-GERI YAZ --------------------------------------/		
        output      [31:0]       hedef_yazmac_verisi_o,
        // COZ->YURUT->GERI YAZ
        output                   yazmaca_yaz_o,
        output      [4:0]        hedef_yazmaci_o
    );

    reg     [4:0]       hedef_yazmaci_r     ;
    reg                 yazmaca_yaz_r       ;
    reg     [2:0]       load_save_buyrugu_r ;
    reg                 bellege_yaz_r       ;
    reg                 bellekten_oku_r     ;
    reg     [31:0]      yazmac_degeri2_r    ;

    wire                veri_sil_i;
    wire                conv_yap_en_i; 
    wire                filtre_sil_i;
    wire                filtre_rs1_en_i;
    wire                veri_rs1_en_i;                                     
    
	assign filtre_sil_i = (yz_islem_kodu_i == 3'b011) && yapay_zeka_aktif_i;
	assign veri_sil_i = (yz_islem_kodu_i == 3'b010) && yapay_zeka_aktif_i;
	assign conv_yap_en_i = (yz_islem_kodu_i == 3'b100) && yapay_zeka_aktif_i;
	assign filtre_rs1_en_i = (yz_islem_kodu_i == 3'b001) && yapay_zeka_aktif_i;
	assign veri_rs1_en_i = (yz_islem_kodu_i == 3'b000) && yapay_zeka_aktif_i;
    

	// AMB den ??kanlar
	wire    [31:0]      AMB_sonuc;      // AMB den ??kan sonu?, adres veya yazamaca yazilacak deger 
	wire                esit_mi;        // ky1 ky2 ye e?it mi
	wire                buyuk_mu;       // ky1 ky2 den b?y?k m? 
	wire                buyuk_mu_unsigned;       // ky1 ky2 den b?y?k m? 
	wire    [31:0]      atlanilmis_adres;
	wire                AMB_hazir;
	wire                amb_stall_o_w;
    
	AMB aritmetik_mantik(
		//		INPUTS
		.rst_i(rst_i),
		.clk_i(clk_i),
		.AMB_aktif_i(amb_aktif_i),
		.anlik_i(anlik_i),
		.yazmac_degeri1_i(yazmac_degeri1_i),
		.yazmac_degeri2_i(yazmac_degeri2_i),  
		.adres_i(ps_i),
		.islem_kodu_i(amb_islem_kodu_i),
		.sikistirilmis_mi_i(sikistirilmis_mi_i),
		// 		OUTPUTS
		.AMB_hazir_o(AMB_hazir),
		.sonuc_o(AMB_sonuc),
		.jal_r_adres_o(atlanilmis_adres),
		.jal_r_adres_gecerli_o(jal_r_adres_gecerli_o),
		.esit_mi_o(esit_mi),
		.buyuk_mu_o(buyuk_mu),
		.buyuk_mu_o_unsigned(buyuk_mu_unsigned),
		.durdur_i(durdur_i),
		.stall_o(amb_stall_o_w)
	);

	dallanma_birimi dallanma(
		// 		INPUTS
		.rst_i(rst_i),
		.blok_aktif_i(dallanma_aktif_i),
		.dal_buy_turu_i(dallanma_buy_turu_i), 
		.dallanma_ongorusu_i(dallanma_ongorusu_i),
		.esit_mi_i(esit_mi),
		.buyuk_mu_i(buyuk_mu),
		.buyuk_mu_i_unsigned(buyuk_mu_unsigned),
		.ps_i(ps_i),
		.br_i(anlik_i),
		.sikistirilmis_mi_i(sikistirilmis_mi_i),
		// 		OUTPUTS
		.guncelle_ps_o(guncelle_ps_o),
		.guncelle_gecerli_o(guncelle_gecerli_o),
		.guncelle_atladi_o(guncelle_atladi_o),
		.dallanma_hata_o(bosalt_o),
		.guncelle_hedef_adresi_o(guncelle_hedef_adresi_o),
		.durdur_i(durdur_i)
	);

	// yapay_zekadan cikanlar
	 wire    [31:0]  convolution_sonuc;
	 wire            conv_hazir;    
	 wire            yz_stall_o_w;
 
	yapay_zeka_hizlandirici yapay_zeka(
		//		INPUTS
		.clk_i(clk_i),
		.rst_i(rst_i),
		.blok_aktif_i(yapay_zeka_aktif_i),
		.rs1_veri_i(yazmac_degeri1_i),
		.rs2_veri_i(yazmac_degeri2_i),
		.filtre_rs1_en_i(filtre_rs1_en_i),
		.filtre_rs2_en_i(rs2_en_i),
		.filtre_sil_i(filtre_sil_i),
		.veri_rs1_en_i(veri_rs1_en_i),
		.veri_rs2_en_i(rs2_en_i),
		.veri_sil_i(veri_sil_i),
		.conv_yap_en_i(conv_yap_en_i), 
		//		OUTPUTS
		.convolution_sonuc_o(convolution_sonuc),
		.conv_hazir_o(conv_hazir),
		.stall_o(yz_stall_o_w),
		.durdur_i(durdur_i)
	);

	// kriptografiden cikanlar
	wire    [31:0]      kriptografi_sonuc;
	wire                kriptografi_hazir;


	kriptografi_birimi kriptografi(
		//		INPUTS
		.clk_i(clk_i),
		.rst_i(rst_i),
		.blok_aktif_i(kriptografi_aktif_i),
		.yazmac_rs1_i(yazmac_degeri1_i),
		.yazmac_rs2_i(yazmac_degeri2_i),
		.islem_kodu_i(kriptografi_islem_kodu_i),
		//		OUTPUTS
		.sonuc_o(kriptografi_sonuc),
		.kriptografi_hazir_o(kriptografi_hazir),
		.durdur_i(durdur_i)
	);



	always @(posedge clk_i) begin
	    if(yurut_stall_o || (!rst_i)) begin
            hedef_yazmaci_r <= 5'd0;
            yazmaca_yaz_r <= 1'b0;
            load_save_buyrugu_r <= 3'd0;
            bellege_yaz_r <= 1'b0;
            bellekten_oku_r <= 1'b0;
            yazmac_degeri2_r <= 32'd0;
		end
		else if (!durdur_i) begin
            hedef_yazmaci_r <= hedef_yazmaci_i;
            yazmaca_yaz_r <= yazmaca_yaz_i;
            load_save_buyrugu_r <= load_save_buyrugu_i;
            bellege_yaz_r <= bellege_yaz_i;
            bellekten_oku_r <= bellekten_oku_i;
            yazmac_degeri2_r <= yazmac_degeri2_i;
		end
	end

	assign load_save_buyrugu_o  =  load_save_buyrugu_r;
	assign hedef_yazmaci_o      =  hedef_yazmaci_r;
	assign bellekten_oku_o      =  bellekten_oku_r;
	assign bellege_yaz_o        =  bellege_yaz_r;
	assign yazmaca_yaz_o        =  yazmaca_yaz_r;
	assign jal_r_adres_o        =  atlanilmis_adres;
	
		// Bellege gidecek degerler icin mux
	assign bellek_adresi_o =  AMB_hazir ? AMB_sonuc : 32'd0;
	assign bellek_veri_o = AMB_hazir ? yazmac_degeri2_r : 32'd0;  
	assign hedef_yazmac_verisi_o = conv_hazir ? convolution_sonuc : kriptografi_hazir ? kriptografi_sonuc : AMB_hazir ? AMB_sonuc : 32'd0;
	
	assign yurut_stall_o = yz_stall_o_w || amb_stall_o_w;
	
	
endmodule
