`timescale 1ns / 1ps

// Dallanma buyrugu ise aktive et BEQ BNE BLT BGE BLTU BGEU
// Dallanma ongorusunun yanlis oldugu nasil anlasilacak, bu durumda ne yapilacak

/*
    GEREKEN SINYALLER 
    1-) blok_aktif_i 
    2-) dal_buy_turu_i
    3-) dallanma_ongorusu_i // *
    3-) ps_i
    4-) esit_mi_i
    5-) buyuk_mu_i
	6-) br_i // BRANCH IMM

    dallanma buyrugu gelirse -> blok_aktif_i = 1 (Coz asamasindan gelmeli)
    
    dal_buy_turu_i : (Coz asamasindan gelmeli)
        BEQ -> 000
        BNE -> 001
        BLT -> 010
        BGE -> 011
        BLTU -> 100
        BGEU -> 101
       
    dallanma_ongorusu_i -> 1 ise atlar denmis, 0 ise atlamaz denmis
       
    ps_i -> dallanmanin program sayaci boru hattinda tasinmali
    
    esit_mi_i -> Dallanma birimine ekstra donaným eklememek icin AMB'den gelmeli
    buyuk_mu_i -> Dallanma birimine ekstra donaným eklememek icin AMB'den gelmeli
    
    
    Dallanmanin atlamadan onceki ps'i boru hattinda ilerletilecek
*/

`include "operations.vh"
// DURDURDA NE YAPILACAGINA BAK
module dallanma_birimi(
    input               rst_i,
    input               durdur_i,  
    input               blok_aktif_i,
    input  [2:0]        dal_buy_turu_i,
    input               dallanma_ongorusu_i,
    input               esit_mi_i,
    input               buyuk_mu_i,
	input  [31:0]       ps_i,
	input  [31:0]       br_i,
    output              guncelle_gecerli_o,
    output              guncelle_atladi_o,
    output              dallanma_hata_o,
	output [31:0]       guncelle_hedef_adresi_o, // hata varsa ps buna donmeli !
	output [31:0]       guncelle_ps_o
    );
    assign guncelle_ps_o = ps_i;
    
    
	reg [31:0] guncelle_hedef_adresi_o_r = 32'd0;
	
    reg guncelle_gecerli_o_r = 1'b0;
    reg guncelle_atladi_o_r = 1'b0;
    
    assign guncelle_gecerli_o = blok_aktif_i ? guncelle_gecerli_o_r : 1'b0;
    assign guncelle_atladi_o = blok_aktif_i ? guncelle_atladi_o_r : 1'b0;
    assign dallanma_hata_o = (blok_aktif_i && rst_i/*reset yok*/) ? !(dallanma_ongorusu_i == guncelle_atladi_o_r) : 1'b0;
    assign guncelle_hedef_adresi_o = blok_aktif_i ? guncelle_hedef_adresi_o_r : 32'd0;
   
    always @ * begin
    
    guncelle_atladi_o_r = 1'b0;
    guncelle_gecerli_o_r = 1'b0; 
    guncelle_hedef_adresi_o_r = 32'd0;
	
     if(!rst_i) begin // rst_i 0 ise reset
        guncelle_gecerli_o_r = 1'b0;
        guncelle_atladi_o_r = 1'b0;
		guncelle_hedef_adresi_o_r = 32'd0;
    end
    else begin
        if(blok_aktif_i && !durdur_i) begin
        guncelle_gecerli_o_r = 1'b1;
        
            case (dal_buy_turu_i) 
            
                `BRA_BEQ : begin
                    if(esit_mi_i) begin
                        guncelle_atladi_o_r = 1'b1;
						guncelle_hedef_adresi_o_r = ps_i + br_i;
					end
                    else begin
                        guncelle_atladi_o_r = 1'b0;
						guncelle_hedef_adresi_o_r = ps_i;
					end
                end
                
                `BRA_BNE : begin
                    if(!esit_mi_i) begin
                        guncelle_atladi_o_r = 1'b1;
						guncelle_hedef_adresi_o_r = ps_i + br_i;
					end
                    else begin
                        guncelle_atladi_o_r = 1'b0;
						guncelle_hedef_adresi_o_r = ps_i;
					end
                end
                 
                `BRA_BLT : begin
                    if(!buyuk_mu_i) begin
                        guncelle_atladi_o_r = 1'b1;
						guncelle_hedef_adresi_o_r = ps_i + br_i;
					end
                    else begin
                        guncelle_atladi_o_r = 1'b0;
						guncelle_hedef_adresi_o_r = ps_i;
					end
                end
                
                `BRA_BGE : begin
                    if(buyuk_mu_i) begin
                        guncelle_atladi_o_r = 1'b1;
						guncelle_hedef_adresi_o_r = ps_i + br_i;
					end
                    else begin
                        guncelle_atladi_o_r = 1'b0;
						guncelle_hedef_adresi_o_r = ps_i;
					end
                end
                
                `BRA_BLTU : begin
                    if(!buyuk_mu_i || esit_mi_i) begin
                        guncelle_atladi_o_r = 1'b1;
						guncelle_hedef_adresi_o_r = ps_i + br_i;
					end
                    else begin
                        guncelle_atladi_o_r = 1'b0;
						guncelle_hedef_adresi_o_r = ps_i;
					end
                end
                
                `BRA_BGEU : begin
                    if(buyuk_mu_i || esit_mi_i) begin
                        guncelle_atladi_o_r = 1'b1;
						guncelle_hedef_adresi_o_r = ps_i + br_i;
					end
                    else begin
                        guncelle_atladi_o_r = 1'b0;
						guncelle_hedef_adresi_o_r = ps_i; // hatanin duzeltilmesi icin
					end
                end
                
                default : begin // bir hata olusursa
                    guncelle_atladi_o_r = 1'b0;
                    guncelle_gecerli_o_r = 1'b0;
					guncelle_hedef_adresi_o_r = 32'd0;
                end
                
            endcase
			
    end
    end
    
    end
    
endmodule
