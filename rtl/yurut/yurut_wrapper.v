`timescale 1ns / 1ps

/*
    ****çözden gelmesi gerekenler****
  
        yazmac_degeri1       ==>     kaynak yazmacý 1 den çikan deger
        yazmaz_degeri2       ==>     kaynak yazmaci 2 den cikanb deger
        anlik_i              ==>     çözde genisletilmis anlik
        adres_i              ==>     içerdeki buyruðun adresi    
        islem_kodu_i         ==>     12 bitlik hangi iþlemin yapilacagini söyleyen deger 
        hedef_yazmaci_i      ==>     hedef yazmaci kaybolmamalý bu yüzden bütün aþamalarda taþýnýr
        bellege_yaz_i        ==>     save buyruðuysa onu belirtmek için yürütte kullanýlmaz
        bellekten_oku_i      ==>     load buyruðuysa onu belirtmek için yürütte kullanýlmaz
        dallanma_ongorusu_i  ==>     öngörücüden cikan sonuc
        dallanma_mi_i        ==>     dallanma birimini aktif yapmak için
        load_save_buyrugu_i  ==>     bellege hangi tür load veya save in gittigini soyler
        
    ****denetime gitmesi gerekenler****
 
        dallanma_hata_o        ==>     dallanma yanlýþ öngörülmüþ çöz boþaltýlmalý
    
    ****yurutten getire gidecek olanlar****
 
        guncelle_gecerli_o      ==>     dallanma biriminde islem biiti öngörücüde ilgili degisiklikler yapýlabilir
        guncelle_ps_o           ==>     yeni adres degeri
        guncelle_atladi_o       ==>     dallanma atladi 
        
    ****yurutten bellege gidecek olanlar****
       bellek_adresi_o          ==>     amb de hesaplnan deðer
       bellek_veri_o            ==>     yazmac_degeri2_i ye eþit
       load_save_buyrugu_o      ==>     bellege hangi tür load veya save in gittigini soyler
*/
module yurut_wrapper(
    
    input                    clk_i,
    input                    rst_i,
	// \-------------------- COZ-YURUT -> AMB, ORTAK ------------------------------/
    input                    amb_aktif_i,
    input       [31:0]       yazmac_degeri1_i,
    input       [31:0]       yazmac_degeri2_i,
	input		[31:0]		 ps_i,
    input       [31:0]       anlik_i, 
    input       [5:0]        islem_kodu_i,       
    input       [4:0]        hedef_yazmaci_i,
    input                    dallanma_aktif_i,
    input                    yazmaca_yaz_i,
    input       [2:0]        load_save_buyrugu_i,       
    input                    bellege_yaz_i, 
    input                    bellekten_oku_i, 
    input       [2:0]        dallanma_buy_turu_i, 
    // GETIR->COZ->YURUT
    input                    dallanma_ongorusu_i,
	// \--------------------- COZ-YURUT -> YAPAY ZEKA -----------------------------/		
    input                    yapay_zeka_aktif_i,
    input                    rs2_en_i,
    input       [2:0]        yz_islem_kodu_i,
    output                   yz_stall_o, 
    // \--------------------- COZ-YURUT -> KRIPTOGRAFI ----------------------------/		
    input                    kriptografi_aktif_i,
    input       [2:0]        kriptografi_islem_kodu_i,
    // \--------------------- YURUT-DENETIM -> STALL ICIN GEREKEBILIR--------------/   		              
    output                   conv_hazir_o,
    output                   kriptografi_hazir_o,
    output                   AMB_hazir_o,
    // \--------------------- YURUT-GETIR -> DALLANMA -----------------------------/    	        
	// Dallanma ongorucusune
    output                   guncelle_gecerli_o, 
    output                   guncelle_atladi_o, 
	// Dallanma ongorucusu + ps ureticisine
	output 	    [31:0]		 guncelle_hedef_adresi_o, 
	output                   dallanma_hata_o,
	// PS ureticisine (jump buyruðundan sonra gidilecek adres)
    output      [31:0]       atlanilmis_adres_o,    
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


    wire                    veri_sil_i;
    wire                    conv_yap_en_i; 
    wire                    filtre_sil_i;
    wire                    filtre_rs1_en_i;
    wire                    veri_rs1_en_i;                                     
    
    assign filtre_sil_i = (yz_islem_kodu_i == 3'b011);
    assign veri_sil_i = (yz_islem_kodu_i == 3'b010);
    assign conv_yap_en_i = (yz_islem_kodu_i == 3'b100);
    assign filtre_rs1_en_i = (yz_islem_kodu_i == 3'b001);
    assign veri_rs1_en_i = (yz_islem_kodu_i == 3'b000);
    
	wire    [31:0]      bellek_veri_r;
	wire    [31:0]      bellek_adresi_r;

	reg     [4:0]       hedef_yazmaci_r     =    0;
	reg                 bellekten_oku_r     =    0;
	reg                 bellege_yaz_r       =    0;
	reg                 yazmaca_yaz_r       =    0;
	reg      [2:0]      load_save_buyrugu_r =    0;



	// AMB den çýkanlar
	wire    [31:0]      AMB_sonuc;      // AMB den çýkan sonuç, adres veya yazamaca yazilacak deger 
	wire                esit_mi;        // ky1 ky2 ye eþit mi
	wire                buyuk_mu;       // ky1 ky2 den büyük mü 
	wire    [31:0]      atlanilmis_adres;
	wire                AMB_hazir;
 
	AMB aritmetik_mantik(
		//		INPUTS
		.rst_i(rst_i),
		.clk_i(clk_i),
		.AMB_aktif_i(amb_aktif_i),
		.anlik_i(anlik_i),
		.yazmac_degeri1_i(yazmac_degeri1_i),
		.yazmac_degeri2_i(yazmac_degeri2_i),  
		.adres_i(ps_i),
		.islem_kodu_i(islem_kodu_i),
		// 		OUTPUTS
		.AMB_hazir_o(AMB_hazir),
		.sonuc_o(AMB_sonuc),
		.adres_o(atlanilmis_adres),
		.esit_mi_o(esit_mi),
		.buyuk_mu_o(buyuk_mu)
	);

	dallanma_birimi dallanma(
		// 		INPUTS
		.rst_i(rst_i),
		.blok_aktif_i(dallanma_aktif_i),
		.dal_buy_turu_i(dallanma_buy_turu_i), 
		.dallanma_ongorusu_i(dallanma_ongorusu_i),
		.esit_mi_i(esit_mi),
		.buyuk_mu_i(buyuk_mu),
		.ps_i(ps_i),
		.br_i(anlik_i),
		// 		OUTPUTS
		.guncelle_gecerli_o(guncelle_gecerli_o),
		.guncelle_atladi_o(guncelle_atladi_o),
		.dallanma_hata_o(dallanma_hata_o),
		.guncelle_hedef_adresi_o(guncelle_hedef_adresi_o)
	);

	// yapay_zekadan cikanlar
	 wire    [31:0]  convolution_sonuc;
	 wire            conv_hazir;    
 
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
		.stall_o(yz_stall_o)
	);

	// kriptografiden çýkanlar
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
		.kriptografi_hazir_o(kriptografi_hazir)
	);

	// Bellege gidecek degerler icin mux
	assign bellek_adresi_r =  AMB_hazir ? AMB_sonuc : 0;
	assign bellek_veri_r = AMB_hazir ? yazmac_degeri2_i : 0;  
	assign hedef_yazmac_verisi_o = conv_hazir ? convolution_sonuc : kriptografi_hazir ? kriptografi_sonuc : 0;
																							   
	always @(posedge clk_i) begin                               
																
		if(rst_i == 1'b1) begin
		// COZDEN GELENLER
		hedef_yazmaci_r      <=   0;
		bellege_yaz_r        <=   0;
		yazmaca_yaz_r        <=   0;
		bellekten_oku_r      <=   0;
		load_save_buyrugu_r  <=   0;       
		end
		
		else begin
		// COZDEN GELENLER
		hedef_yazmaci_r     <=   hedef_yazmaci_i;    
		bellege_yaz_r       <=   bellege_yaz_i;
		yazmaca_yaz_r       <=   yazmaca_yaz_i;
		bellekten_oku_r     <=   bellekten_oku_i;
		load_save_buyrugu_r <=   load_save_buyrugu_i;
		end
	end

	assign load_save_buyrugu_o  =  load_save_buyrugu_r;
	assign hedef_yazmaci_o      =  hedef_yazmaci_r;
	assign bellekten_oku_o      =  bellekten_oku_r;
	assign bellege_yaz_o        =  bellege_yaz_r;
	assign yazmaca_yaz_o        =  yazmaca_yaz_r;
	assign atlanilmis_adres_o   =  atlanilmis_adres;
	assign conv_hazir_o         =  conv_hazir;
	assign kriptografi_hazir_o  =  kriptografi_hazir;
	assign bellek_veri_o        = bellek_veri_r;
	assign bellek_adresi_o      = bellek_adresi_r;
	assign AMB_hazir_o          = AMB_hazir;

	endmodule