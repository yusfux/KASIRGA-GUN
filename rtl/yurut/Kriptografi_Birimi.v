`timescale 1ns / 1ps

/*
    Gereken sinyaller
    1-) islem_kodu_i
    hmdst -> 000
    pkg -> 001
    rvrs -> 010
    sladd -> 011
    cntz -> 100
    cntp -> 101
    2-) yazmac_rs1_i
    3-) yazmac_rs2_i
    4-) blok_aktif_i
*/

module Kriptografi_Birimi(
    input clk_i,
    input rst_i,
    input blok_aktif_i,
    input [31:0] yazmac_rs1_i,
    input [31:0] yazmac_rs2_i,
    input [2:0]islem_kodu_i,
    output [31:0] sonuc_o,
    output kriptografi_hazir_o // ayarlanilmali
    );
    
    reg kriptografi_hazir_r = 1'b0;
    reg kriptografi_hazir_r_next = 1'b0;
    assign kriptografi_hazir_o = kriptografi_hazir_r;
    
    localparam hmdst = 3'b000; 
    localparam pkg = 3'b001;   
    localparam rvrs = 3'b010;  
    localparam sladd = 3'b011; 
    localparam cntz = 3'b100;  
    localparam cntp = 3'b101;  
        
    reg [31:0] sonuc_r = 0;
    reg [31:0] sonuc_r_next = 0;
    
    assign sonuc_o = sonuc_r;
   
    reg dur = 0;
    integer i=0;
    
    always @* begin
    sonuc_r_next = sonuc_r;
    kriptografi_hazir_r_next = 1'b0; // simdilik
    
    if(blok_aktif_i) begin
        case(islem_kodu_i) 
        hmdst : begin // KAC CEVRIMDE YAPILACAGINA KARAR VERILMELI
            // Hamming distance
                sonuc_r_next = 0; // simdilik
        end
        
        pkg : begin
                sonuc_r_next = {yazmac_rs2_i[15:0],yazmac_rs1_i[15:0]};
        end
        
        rvrs : begin
            for(i=0;i<32;i=i+1) begin
                sonuc_r_next[31-i] =  yazmac_rs1_i[i];
            end
        end
        
        sladd : begin
                sonuc_r_next = (1<<yazmac_rs1_i) + yazmac_rs2_i;
        end
        
        cntz : begin // KAC CEVRIMDE YAPILACAGINA KARAR VERILMELI
            // Ilk 1'e kadar olan 0'lar sayilacak
                sonuc_r_next = 0; // simdilik
      
        end
        
        cntp : begin // KAC CEVRIMDE YAPILACAGINA KARAR VERILMELI
            // Kac tane 1 oldugunu sayar
            //sonuc_r_next = $countones(yazmac_rs1_i);
            sonuc_r_next = 0; // simdilik
        end
        
        endcase
    end
    
    end
    
    always @(posedge clk_i) begin
    if(rst_i || (!blok_aktif_i)) begin
        sonuc_r <= 0;
        kriptografi_hazir_r <= 0; 
    end
    else begin
        sonuc_r <= sonuc_r_next;
    end
    
    
    end
    
    
    
endmodule
