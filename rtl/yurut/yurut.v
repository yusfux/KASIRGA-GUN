`timescale 1ns / 1ps

/*
    ****��zden gelmesi gerekenler****
  
        yazmac_degeri1       ==>     kaynak yazmac� 1 den �ikan deger
        yazmaz_degeri2       ==>     kaynak yazmaci 2 den cikanb deger
        anlik_i              ==>     ��zde genisletilmis anlik
        adres_i              ==>     i�erdeki buyru�un adresi    
        islem_kodu_i         ==>     12 bitlik hangi i�lemin yapilacagini s�yleyen deger 
        hedef_yazmaci_i      ==>     hedef yazmaci kaybolmamal� bu y�zden b�t�n a�amalarda ta��n�r
        bellege_yaz_i        ==>     save buyru�uysa onu belirtmek i�in y�r�tte kullan�lmaz
        bellekten_oku_i      ==>     load buyru�uysa onu belirtmek i�in y�r�tte kullan�lmaz
        dallanma_ongorusu_i  ==>     �ng�r�c�den cikan sonuc
        dallanma_mi_i        ==>     dallanma birimini aktif yapmak i�in
        load_save_buyrugu_i      ==>     bellege hangi t�r load veya save in gittigini soyler
        
    ****denetime gitmesi gerekenler****
 
        dallanma_hata_o        ==>     dallanma yanl�� �ng�r�lm�� ��z bo�alt�lmal�
    
    ****yurutten getire gidecek olanlar****
 
        guncelle_gecerli_o      ==>     dallanma biriminde islem biiti �ng�r�c�de ilgili degisiklikler yap�labilir
        guncelle_ps_o           ==>     yeni adres degeri
        guncelle_atladi_o       ==>     dallanma atladi 
        
    ****yurutten bellege gidecek olanlar****
       bellek_adresi_o          ==>     amb de hesaplnan de�er
       bellek_veri_o            ==>     yazmac_degeri2_i ye e�it
       load_save_buyrugu_o      ==>     bellege hangi t�r load veya save in gittigini soyler
*/
module yurut(
    
    input                   clk_i,
    input                   rst_i,
    
    // coz-yurut
    input       [31:0]      yazmac_degeri1_i,
    input       [31:0]      yazmac_degeri2_i,
    input       [31:0]      anlik_i,
    input       [31:0]      adres_i,
    input       [5:0]       islem_kodu_i,       ////////////12 bit de�il d�zenle
    input       [4:0]       hedef_yazmaci_i,
    input                   dallanma_mi_i,
    input                   yazmaca_yaz_i,
    input       [2:0]       load_save_buyrugu_i,       
    input                   bellege_yaz_i, 
    input                   bellekten_oku_i, 
    input                   dallanma_ongorusu_i,
    input       [2:0]       dallanma_buy_turu_i, 
    
    // denetim birimi
    output                  dallanma_hata_o,                      
    
    // yurut-getir       
    output                   guncelle_gecerli_o, // bu 3 u ongorucuye
    output      [31:0]       guncelle_ps_o,   // dallanmalardan sonra gidilecek adres, hem ps ye hem de btf ye 
    output                   guncelle_atladi_o, 
    
    output      [31:0]      atlanilmis_adres_o, // bu ps ye, jump buyru�undan sonra gidilecek adres              
    // yurut-bellek
    output      [2:0]        load_save_buyrugu_o,
    output      [4:0]        hedef_yazmaci_o,
    output                   bellekten_oku_o,
    output                   bellege_yaz_o,
    output                   yazmaca_yaz_o,
    
    output      [31:0]       bellek_adresi_o,
    output      [31:0]       bellek_veri_o // bellege yazilacak olan veri
);

reg     [4:0]       hedef_yazmaci_r ;

reg                 bellekten_oku_r ;

reg                 bellege_yaz_r   ;

reg                 yazmaca_yaz_r   ;

reg     [31:0]      bellek_adresi_r ;

reg     [31:0]      bellek_veri_r   ;

reg                 guncelle_gecerli_r;

reg                 guncelle_atladi_r;

reg                 guncelle_ps_r;

reg                 dallanma_hata_r;

reg      [31:0]     atlanilmis_adres_r;

reg      [2:0]      load_save_buyrugu_r;

// AMB den ��kanlar
wire    [31:0]      AMB_sonuc;      // AMB den ��kan sonu�, adres veya yazamaca yazilacak deger 
wire                esit_mi;        // ky1 ky2 ye e�it mi
wire                buyuk_mu;       // ky1 ky2 den b�y�k m� 
wire                atlanilmis_adres;
 
AMB amb(
    // inputlar
    .anlik_i(anlik_i),
    .yazmac_degeri1_i(yazmac_degeri1_i),
    .yazmac_degeri2_i(yazmac_degeri2_i),
    .adres_i(adres_i),
    .islem_kodu_i(islem_kodu_i),
    // outputlar
    .sonuc_o(AMB_sonuc),
    .adres_o(atlanilmis_adres),
    .esit_mi_o(esit_mi),
    .buyuk_mu_o(buyuk_mu)
);
    
// Dallanma biriminden cikanlar
wire                guncelle_gecerli;
wire                guncelle_atladi;
wire                guncelle_ps;
wire                dallanma_hata;


Dallanma_Birimi dallanma_birimi(
    // inputlar
    .rst_i(rst_i),
    .blok_aktif_i(dallama_mi_i),
    .dallanma_ps_i(adres_i),
    .dal_buy_turu_i(dallanma_buy_turu_i), 
    .dallanma_ongorusu_i(dallanma_ongorusu_i),
    .esit_mi_i(esit_mi),
    .buyuk_mu_i(buyuk_mu),
    // outputlar
    .guncelle_gecerli_o(guncelle_gecerli),
    .guncelle_atladi_o(guncelle_atladi),
    .guncelle_ps_o(guncelle_ps),
    .dallanma_hata_o(dallanma_hata)
);


always @(posedge clk_i) begin
    
    /// bu k�s�m clk la m� sor
    guncelle_gecerli_r  <= guncelle_gecerli;
    guncelle_atladi_r   <= guncelle_atladi;
    guncelle_ps_r       <= guncelle_ps;
    dallanma_hata_r     <= dallanma_hata;
  
    atlanilmis_adres_r  <= atlanilmis_adres;
    /// 
    bellek_adresi_r     <= AMB_sonuc;
    bellek_veri_r       <= yazmac_degeri2_i;
    
    hedef_yazmaci_r     <= hedef_yazmaci_i;    
    bellege_yaz_r       <= bellege_yaz_i;
    yazmaca_yaz_r       <= yazmaca_yaz_i;
    bellekten_oku_r     <= bellekten_oku_i;
    load_save_buyrugu_r <= load_save_buyrugu_i;
    
end


assign guncelle_gecerli_o =  guncelle_gecerli_r;
assign guncelle_atladi_o  =  guncelle_atladi_r;
assign guncelle_ps_o      =  guncelle_ps_r;
assign dallanma_hata_o    =  dallanma_hata_r;
assign atlanilmis_adres_o =  atlanilmis_adres_r;

assign bellek_veri_o      =  bellek_veri_r;
assign bellek_adresi_o    =  bellek_adresi_r;

assign load_save_buyrugu_o=  load_save_buyrugu_r;
assign hedef_yazmaci_o    =  hedef_yazmaci_r;
assign bellekten_oku_o    =  bellekten_oku_r;
assign bellege_yaz_o      =  bellege_yaz_r;
assign yazmaca_yaz_o      =  yazmaca_yaz_r;

endmodule
