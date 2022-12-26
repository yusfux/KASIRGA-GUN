`timescale 1ns / 1ps

// Dallanma buyrugu ise aktive et BEQ BNE BLT BGE BLTU BGEU
// Dallanma ongorusunun yanlis oldugu nasil anlasilacak, bu durumda ne yapilacak

/*
    GEREKEN SINYALLER 
    1-) blok_aktif_i 
    2-) dal_buy_turu_i
    3-) dal_ongorusu_i // *
    3-) dallanma_ps_i
    4-) esit_mi_i
    5-) buyuk_mu_i

    dallanma buyrugu gelirse -> blok_aktif_i = 1 (Coz asamasindan gelmeli)
    
    dal_buy_turu_i : (Coz asamasindan gelmeli)
        BEQ -> 000
        BNE -> 001
        BLT -> 010
        BGE -> 011
        BLTU -> 100
        BGEU -> 101
       
    dal_ongorusu_i -> 1 ise atlar denmis, 0 ise atlamaz denmis
       
    dallanma_ps_i -> dallanmanin program sayaci boru hattinda tasinmali
    
    esit_mi_i -> Dallanma birimine ekstra donaným eklememek icin AMB'den gelmeli
    buyuk_mu_i -> Dallanma birimine ekstra donaným eklememek icin AMB'den gelmeli
    
    
    Dallanmanin atlamadan onceki ps'i boru hattinda ilerletilecek
*/


module Dallanma_Birimi(
    input rst_i,
    input blok_aktif_i,
    input [2:0] dal_buy_turu_i,
    input dallanma_ongorusu_i,
    input esit_mi_i,
    input buyuk_mu_i,
    output guncelle_gecerli_o,
    output guncelle_atladi_o,
    output dallanma_hata_o
    );
    
    reg guncelle_gecerli_o_r = 0;
    reg guncelle_atladi_o_r = 0;
    reg guncelle_ps_o_r = 0;
    
    assign guncelle_gecerli_o = guncelle_gecerli_o_r;
    assign guncelle_atladi_o = guncelle_atladi_o_r;
    assign dallanma_hata_o = blok_aktif_i ? !(dallanma_ongorusu_i && guncelle_atladi_o_r) : 1'b0;
    
    localparam  BEQ = 3'b000;
    localparam  BNE = 3'b001;
    localparam  BLT = 3'b010;
    localparam  BGE = 3'b011;
    localparam  BLTU = 3'b100;
    localparam  BGEU = 3'b101;
    
    always @ * begin
    
    guncelle_atladi_o_r = 1'b0;
    guncelle_gecerli_o_r = 1'b0; 
    
     if(rst_i) begin
        guncelle_gecerli_o_r = 1'b0;
        guncelle_atladi_o_r = 1'b0;
    end
    else begin
        if(blok_aktif_i) begin
        guncelle_gecerli_o_r = 1'b1;
        
            case (dal_buy_turu_i) 
            
                BEQ : begin
                    if(esit_mi_i) 
                        guncelle_atladi_o_r = 1'b1;
                    else 
                        guncelle_atladi_o_r = 1'b0;
                end
                
                BNE : begin
                    if(!esit_mi_i) 
                        guncelle_atladi_o_r = 1'b1;
                    else 
                        guncelle_atladi_o_r = 1'b0;
                end
                 
                BLT : begin
                    if(!buyuk_mu_i) 
                        guncelle_atladi_o_r = 1'b1;
                    else 
                        guncelle_atladi_o_r = 1'b0;
                end
                
                BGE : begin
                    if(buyuk_mu_i) 
                        guncelle_atladi_o_r = 1'b1;
                    else 
                        guncelle_atladi_o_r = 1'b0;
                end
                
                BLTU : begin
                    if(!buyuk_mu_i || esit_mi_i) 
                        guncelle_atladi_o_r = 1'b1;
                    else
                        guncelle_atladi_o_r = 1'b0;
                end
                
                BGEU : begin
                    if(buyuk_mu_i || esit_mi_i) 
                        guncelle_atladi_o_r = 1'b1;
                    else 
                        guncelle_atladi_o_r = 1'b0;
                end
                
                default : begin // bir hata oluþursa
                    guncelle_atladi_o_r = 1'b0;
                    guncelle_gecerli_o_r = 1'b0;
                end
                
            endcase
    end
    end
    
    end
    
endmodule
