`timescale 1ns / 1ps

`include "operations.vh"

module buyruk_onbellegi_denetleyici(

    input               clk_i,                    
    input               rst_i,
    
    input               durdur_i,
    input   [31:0]      adres_i,
    input   [31:0]      adres_kontrol_i,      
  
    // onbellek sinyalleri
    input               onbellek_adres_bulundu_i, // eski adi => adres_bulundu_i
    input   [31:0]      onbellek_buyruk_i,        // eski adi => buyruk_i
    
    output  [127:0]     onbellek_buyruk_obegi_o,  // veri_obegi_o
    output              onbellek_obek_yaz_o,      
    output  [31:0]      onbellek_yaz_adres_o,
    
    // anabellek denetleyici sinyalleri   
    input               anabellek_musait_i,
    input               anabellek_hazir_i,        
    input   [127:0]     anabellek_obek_i,
    
    output  [31:0]      anabellek_adres_o,
    output              anabellek_istek_o,
    output              anabellek_yaz_o,
    output              anabellek_oku_o,
    
    // oncozucuye gidecek olanlar    
    output  [31:0]      buyruk_o,
    output              buyruk_hazir_o
); 

localparam  BOSTA         = 3'd0;
localparam  ONBELLEK_OKU  = 3'd1;
localparam  ANABELLEK_OKU = 3'd2;
localparam  ONBELLEK_YAZ  = 3'd3;

reg     [1:0]       durum_r;
reg     [1:0]       durum_ns;

reg     [31:0]      buyruk_r;

reg                 buyruk_hazir_r;

reg     [127:0]     onbellek_buyruk_obegi_r;

reg     [31:0]      anabellek_adres_r; 

reg     [1:0]       secilen_byte_r;
reg     [1:0]       secilen_byte_ns;

reg     [127:0]     anabellek_obek_r; 
reg     [127:0]     anabellek_obek_ns;

reg     [31:0]      adres_r; 
reg     [31:0]      adres_ns;
 
always @(*) begin 
   
   secilen_byte_ns = secilen_byte_r; 
   durum_ns = durum_r;
   anabellek_obek_ns = anabellek_obek_r;
   adres_ns = adres_r;
   
   buyruk_r = 32'd0;
   buyruk_hazir_r = 1'b0;   
   anabellek_adres_r = 32'd0;
   onbellek_buyruk_obegi_r = 128'd0;
    
   case(durum_r) 
          
         BOSTA: begin
            if(!durdur_i) begin
                buyruk_hazir_r   =   1'b0;
                durum_ns         =   ONBELLEK_OKU;
            end
         end      
          
         ONBELLEK_OKU: begin
            if(!durdur_i) begin  
                if(onbellek_adres_bulundu_i) begin
                    buyruk_r        =   onbellek_buyruk_i;       
                    buyruk_hazir_r  =   1'b1;
                    durum_ns        =   BOSTA;
                end
                else begin   
                    buyruk_hazir_r = 1'b0;
                    if(anabellek_musait_i) begin
                        anabellek_adres_r  =  {adres_i[31:4], 4'b0000};
                        buyruk_hazir_r     =  1'b0;
                        secilen_byte_ns    =  adres_i[3:2];
                        adres_ns           =  adres_i; 
                        durum_ns           =  ANABELLEK_OKU ;                     
                    end
                end
             end   
         end      
                                     
         ANABELLEK_OKU : begin 
        
             anabellek_adres_r = {adres_i[31:4], 4'b0000};
             if(anabellek_hazir_i) begin               
                 onbellek_buyruk_obegi_r = anabellek_obek_i; 
                 anabellek_obek_ns = anabellek_obek_i;
                 durum_ns = ONBELLEK_YAZ; 
             end
         end
         
         ONBELLEK_YAZ : begin 
            if(!durdur_i) begin
                if(adres_kontrol_i == adres_r) begin 
                    buyruk_r  =  anabellek_obek_r[secilen_byte_ns*32 +: 32];  
                    buyruk_hazir_r = 1'b1;                
                end
                durum_ns  =  BOSTA;
            end
         end  
         
    endcase  
 end      


always @(posedge clk_i) begin
    if(!rst_i) begin
        durum_r <= 2'd0;
        secilen_byte_r <= 4'd0; 
        anabellek_obek_r <= 128'd0;
    end
    else begin
        anabellek_obek_r <= anabellek_obek_ns;
        secilen_byte_r  <= secilen_byte_ns;
        durum_r <= durum_ns;   
        adres_r <= adres_ns;                                                                                     
    end
end

assign onbellek_buyruk_obegi_o =  onbellek_buyruk_obegi_r;
assign onbellek_obek_yaz_o     =  (durum_r==ANABELLEK_OKU)&&(durum_ns==ONBELLEK_YAZ); 
assign anabellek_adres_o       =  anabellek_adres_r;
assign anabellek_istek_o       =  ((durum_r == ONBELLEK_OKU && !onbellek_adres_bulundu_i) || (durum_r == ANABELLEK_OKU && !anabellek_hazir_i));      
assign anabellek_yaz_o         =   1'b0;                                                            
assign anabellek_oku_o         =   1'b1;                                                                              
assign buyruk_o                =   buyruk_r;                                                      
assign buyruk_hazir_o          =   buyruk_hazir_r;  
assign onbellek_yaz_adres_o    =   adres_r;                                            

endmodule