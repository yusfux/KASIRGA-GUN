`timescale 1ns / 1ps

module bellek_wrapper(
    input                   clk_i,            //active-low reset
    input                   rst_i,

	// \--------------------- YURUT-GERI YAZ --------------------------------------/		
    input      [31:0]       hedef_yazmac_verisi_i,
    output     [31:0]       hedef_yazmac_verisi_o,
	// COZ->YURUT->GERI YAZ
	input                   yazmaca_yaz_i,
    input      [4:0]        hedef_yazmaci_i,
	output                  yazmaca_yaz_o,
	output     [4:0]        hedef_yazmaci_o,
	output                  bellek_veri_hazir_o,
	output     [31:0]	    bellek_veri_o,
	// \--------------------- YURUT-BELLEK ----------------------------------------/		
	input      [31:0]       bellek_adresi_i,
	input      [31:0]       bellek_veri_i, // bellege yazilacak olan veri
	// COZ->YURUT->BELLEK
    input      [2:0]        load_save_buyrugu_i,
    input                   bellekten_oku_i,
    input                   bellege_yaz_i,
    // \--------------------- BELLEK-ANABELLEK DENETLEYICI-------------------------/
    input                   anabellek_musait_i,        
    input       [127:0]     okunan_veri_obegi_i,
    input                   bellek_asamasina_veri_hazir_i,
    
    output                  bellek_asamasi_istek_o,
    output      [31:0]      bellek_adres_o,             // obegin baslangic adresi yani hep 32'bx0000 seklinde
    output                  bellek_oku_o,
    output                  bellek_yaz_o,
    output      [127:0]     yazilacak_veri_obegi_o,
   //\---------------------------------------------------------/
    output                  durdur_o,
    // giris_cikis
    input                   rx_i,
    output                  tx_o,
	output                  pwm1_o,
    output                  pwm2_o,
    output                  gc_veri_gecerli_o,
    output      [31:0]      gc_okunan_veri_o, // gc_veri_gecerli_o 1 ise yazmaca yazilmasi icin

    output reg bellekten_oku_o
);
    //***ONBELLEK DENETLEYICI modulu wirelari**/
    wire [127:0]    obek_okunan_o;       
    wire            onbellek_obek_yaz_o;
                           
                           
    wire            anabellek_yaz_o;     
    wire            anabellek_oku_o;     
    wire            anabellek_istek_o;   
    wire [31:0]     anabellek_adres_o;   
    wire [127:0]    anabellek_kirli_obek_o;
    
    wire            denetleyici_musait;
        // geriyaza verilecekler
    wire [31:0]     veri_o; 
    wire            veri_hazir_o; 

   //***ONBELLEK modulu wirelari**/
    wire [127:0]    veri_obegi_o;    
    wire [31:0]     okunan_veri_o;     
    wire [31:0]     kirli_obek_adresi_o;
    wire            adres_bulundu_o;   
    wire            obek_kirli_o;   
    
    //*Adres duzenleme ve axi***/
    wire            bellege_yaz_w;
    wire            bellekten_oku_w;
    wire            giris_cikis_aktif_w;
    wire  [31:0]    gc_okunan_veri_w;
    wire            gc_stall_w;
    wire            gc_veri_gecerli_w;

    reg             bellek_veri_hazir_r;

	reg     [31:0]	bellek_veri_r;

    
    veri_onbellek_denetleyici   onbellek_denetleyici(
        .clk_i(clk_i),
        .rst_i(rst_i),          
                  
        .bellek_oku_i(bellekten_oku_w),   
        .bellek_yaz_i(bellege_yaz_w),  
        .adres_i(bellek_adresi_i),      
        .buyruk_turu_i(load_save_buyrugu_i),  
                 
        .adres_bulundu_i(adres_bulundu_o),
        .onbellek_veri_i(okunan_veri_o),        
        .kirli_obek_i(veri_obegi_o),           
        .kirli_obek_adresi_i(kirli_obek_adresi_o),    
        .obek_kirli_i(obek_kirli_o),           
                        
        .obek_okunan_o(obek_okunan_o),          
        .onbellek_obek_yaz_o(onbellek_obek_yaz_o),    

              
        .anabellek_musait_i(anabellek_musait_i), 
        .anabellek_hazir_i(bellek_asamasina_veri_hazir_i),  
        .okunan_obek_i(okunan_veri_obegi_i),   
                                     
        .anabellek_yaz_o(anabellek_yaz_o),        
        .anabellek_oku_o(anabellek_oku_o),        
        .anabellek_istek_o(anabellek_istek_o),      
        .anabellek_adres_o(anabellek_adres_o),      
        .anabellek_kirli_obek_o(anabellek_kirli_obek_o), 
        
        .veri_o(veri_o),
        .veri_hazir_o(veri_hazir_o),
                
        .denetim_hazir_o(denetleyici_musait)  
    );

    veri_onbellek   onbellek(
         .clk_i(clk_i),                    
         .rst_i(rst_i),                    
                                              
         .denetleyici_obek_i(obek_okunan_o),             
         .adres_i(bellek_adresi_i),                  
         .veri_i(bellek_veri_i),                   
         .bellekten_oku_i(bellekten_oku_i),          
         .bellege_yaz_i(bellege_yaz_i),            
         .anabellekten_obek_geldi_i(bellek_asamasina_veri_hazir_i),
         .buyruk_turu_i(load_save_buyrugu_i),        
                                
         .veri_obegi_o(veri_obegi_o),            
         .okunan_veri_o(okunan_veri_o),            
         .kirli_obek_adresi_o(kirli_obek_adresi_o),      
         .adres_bulundu_o(adres_bulundu_o),          
         .obek_kirli_o(obek_kirli_o)
    );
   
   adres_duzenleyici adres_duz(
         .bellege_yaz_i(bellege_yaz_i),
         .bellekten_oku_i(bellekten_oku_i),
         .bellek_adresi30_i(bellek_adresi_i[30]), //bellek_adresi[30]
         .bellege_yaz_o(bellege_yaz_w),
         .bellekten_oku_o(bellekten_oku_w),
         .giris_cikis_aktif_o(giris_cikis_aktif_w)
    );
    
    axi4_lite_wrapper giris_cikis(
         .axi_aclk_i(clk_i),
         .axi_aresetn_i(rst_i),
         .address_i(bellek_adresi_i),
	      .buyruk_turu_i(load_save_buyrugu_i),
	      .okunan_veri_o(gc_okunan_veri_o),
	      .data_i(bellek_veri_i),
	      .tx_o(tx_o),
	      .rx_i(rx_i),
	      .pwm1_o(pwm1_o),
         .pwm2_o(pwm2_o),
         .stall_o(gc_stall_w),
         .okunan_gecerli_o(gc_veri_gecerli_o),
         .giris_cikis_aktif_i(giris_cikis_aktif_w)
    );
    
   
    reg        yazmaca_yaz_r;
    reg [4:0]  hedef_yazmaci_r;
    reg [31:0] hedef_yazmac_verisi_r;
    reg        yazmaca_yaz_ns;
    reg [4:0]  hedef_yazmaci_ns;
    reg [31:0] hedef_yazmac_verisi_ns;
    
    always @* begin //clk ile bellek asamasina gelen sinyaller icin
            yazmaca_yaz_ns         = yazmaca_yaz_i;
            hedef_yazmaci_ns       = hedef_yazmaci_i;
            hedef_yazmac_verisi_ns = hedef_yazmac_verisi_i;
    end
    
    always @(posedge clk_i) begin
        if(!rst_i) begin
            yazmaca_yaz_r         = 1'b0;
            hedef_yazmaci_r       = 5'd0;
            hedef_yazmac_verisi_r = 32'd0;
        end
        else begin
		    if((!denetleyici_musait && (bellekten_oku_i || bellege_yaz_i) && !giris_cikis_aktif_w) || gc_stall_w)begin
                yazmaca_yaz_r         <= 1'b0;        // SOR: 1 mi olmali?
            end
            else begin
                yazmaca_yaz_r         <= yazmaca_yaz_ns;
                hedef_yazmaci_r       <= hedef_yazmaci_ns;
                hedef_yazmac_verisi_r <= hedef_yazmac_verisi_ns;     
                bellekten_oku_o       <= bellekten_oku_i;  
                bellek_veri_hazir_r   <= veri_hazir_o;
                bellek_veri_r         <= veri_o;
            end
        end
    end
    
    //GERIYAZ ASMASINA GIDECEK SINYALLER
    assign yazmaca_yaz_o          = yazmaca_yaz_r;
    assign hedef_yazmaci_o        = hedef_yazmaci_r;
    assign hedef_yazmac_verisi_o  = hedef_yazmac_verisi_r;
    //ANABELLEK DENETLEYICIYE GIDECEK SINYALLER
    assign bellek_asamasi_istek_o = anabellek_istek_o;
    assign bellek_adres_o         = anabellek_adres_o;
    assign bellek_oku_o           = anabellek_oku_o;
    assign bellek_yaz_o           = anabellek_yaz_o;
    assign yazilacak_veri_obegi_o = anabellek_kirli_obek_o;
    assign bellek_veri_hazir_o    = bellek_veri_hazir_r;
    assign bellek_veri_o          = bellek_veri_r;	
    
	assign durdur_o = (~denetleyici_musait && (bellekten_oku_w || bellege_yaz_w)) || gc_stall_w;

	
endmodule
