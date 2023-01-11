`timescale 1ns / 1ps

`include "operations.vh"
 
module veri_onbellek_denetleyici(
    input           clk_i,
    input           rst_i,
    
    // cozden gelen inputlar
    input           bellek_oku_i,
    input           bellek_yaz_i,
    input   [31:0]  adres_i,
    input   [31:0]  veri_i,
    input   [2:0]   buyruk_turu_i,
    
    // onbellek inputlarý
    input           adres_bulundu_i,
    input   [31:0]  onbellek_veri_i,
    input   [127:0] kirli_obek_i,
    input   [31:0]  kirli_obek_adresi_i,
    input           obek_kirli_i,   
    // onbellek outputlarý
    output  [127:0] obek_okunan_o,
    output          onbellek_obek_yaz_o,
    // direkt assignlanýr
    output  [31:0]  onbellek_adres_o,
    output  [31:0]  onbellek_veri_o,
    output          bellek_oku_o,
    output          bellek_yaz_o,
    output  [2:0]   buyruk_turu_o,
    
    // anabellek denetleyiciye verilecek olanlar 
    output          anabellek_yaz_o,
    output          anabellek_oku_o,
    output          anabellek_istek_o, // assignlanýr
    output  [31:0]  anabellek_adres_o,
    output  [127:0] anabellek_kirli_obek_o,
    output  [31:0]  anabellek_kirli_adres_o,
    
    // anabellekten gelecek olan sinyaller
    input           anabellek_musait_i,
    input           anabellek_hazir_i,
    input   [127:0] okunan_obek_i,
                
    // geriyaza verilecekler
    output  [31:0]  veri_o, // veri clklanmalý
    output          veri_hazir_o 
    
    // denetim birimine         
);

localparam  ONBELLEK      = 2'b00;
localparam  ANABELLEK_YAZ = 2'b01;
localparam  ANABELLEK_OKU = 2'b10;
localparam  ONBELLEK_YAZ  = 2'b11;

reg     [1:0]       durum_r = ONBELLEK;
reg     [1:0]       durum_ns;

reg     [31:0]      veri_r = 32'd0;
reg                 veri_hazir_r = 1'b0;

reg     [127:0]     obek_okunan_r = 128'd0;

reg     [31:0]      anabellek_adres_r = 32'd0;
reg     [127:0]     anabellek_kirli_obek_r = 128'd0;
reg     [31:0]      anabellek_kirli_adres_r = 32'd0;

wire     [3:0]    secilen_byte;
assign      secilen_byte   =  adres_i[3:0];

always @(*) begin 
    
    durum_ns = durum_r;
    veri_r = 32'd0;
    veri_hazir_r = 1'b0;   
    obek_okunan_r = 128'd0;
    anabellek_kirli_adres_r = 32'd0;
    anabellek_kirli_obek_r = 128'd0;
    anabellek_adres_r = 32'd0;
    
    if(bellek_oku_i != 1'b1 && bellek_yaz_i != 1'b1) begin
        veri_r = adres_i;
        veri_hazir_r = 1'b1;
    end
    else begin
    
    case(durum_r) 
          
          ONBELLEK: begin  
              if(bellek_oku_i) begin
                   if(adres_bulundu_i) begin 
                        veri_r = onbellek_veri_i;
                        veri_hazir_r = 1'b1;      
                   end 
                   else begin
                        veri_hazir_r = 1'b0;
                        if(anabellek_musait_i) begin
                            
                              if(obek_kirli_i) begin                                        
                                durum_ns = ANABELLEK_YAZ;
                                anabellek_kirli_adres_r = kirli_obek_adresi_i;
                                anabellek_kirli_obek_r = kirli_obek_i;                               
                              end
                              else begin
                                durum_ns = ANABELLEK_OKU;                                                           
                              end
            
                        end  
                   end               
              end
              else if(bellek_yaz_i) begin
                    if(adres_bulundu_i) begin
                        veri_hazir_r = 1'b0;                     
                   end
                   else begin
                        veri_hazir_r = 1'b0;
                        if(anabellek_musait_i) begin
                        
                              if(obek_kirli_i) begin                                        
                                durum_ns = ANABELLEK_YAZ;
                                anabellek_kirli_adres_r = kirli_obek_adresi_i;
                                anabellek_kirli_obek_r = kirli_obek_i;
                                
                              end
                              else begin
                                durum_ns = ANABELLEK_OKU;                                                           
                              end            
                        end  
                   end
              end
          end          
          
          ANABELLEK_YAZ : begin 
          
             if(anabellek_hazir_i) begin 
                   anabellek_adres_r = {adres_i[31:4], 4'b0000};
                   
                   if(anabellek_musait_i) begin
                    veri_hazir_r = 1'b0;  
                    durum_ns = ANABELLEK_OKU;
                   end
             end      
               
          end
              
          ANABELLEK_OKU : begin 
          
             if(anabellek_hazir_i) begin
                
                if(bellek_oku_i) begin  
                    case(buyruk_turu_i)
                        `MEM_LB  : begin
                            veri_r  = {{24{okunan_obek_i[secilen_byte*8 + 7]}} , okunan_obek_i[secilen_byte*8 +: 7]};
                         end                     
                        `MEM_LH  : begin 
                            veri_r  = {{16{okunan_obek_i[secilen_byte*8 + 15]}} , okunan_obek_i[secilen_byte*8 +: 15]};
                         end
                        `MEM_LW  : begin  
                            veri_r  = okunan_obek_i[secilen_byte*8 +: 31];
                         end
                        `MEM_LBU :  begin 
                            veri_r = { {24{1'b0}}, okunan_obek_i[secilen_byte*8 +: 7]};
                         end                      
                        `MEM_LHU : begin 
                            veri_r = { {16{1'b0}}, okunan_obek_i[secilen_byte*8 +: 15]}; 
                         end
                     endcase
                     veri_hazir_r = 1'b1; 
                 end
                                    
                 obek_okunan_r = okunan_obek_i; 
                 durum_ns = ONBELLEK_YAZ;
                      
            end
        end
        
        ONBELLEK_YAZ : begin 
            durum_ns = ONBELLEK;
                 
        end  
        
    endcase 
    end      
end 

always @(posedge clk_i) begin
    if(rst_i) begin
        
        durum_r <= durum_ns;
    end
    else begin
        durum_r       <= 2'd0;                                                                          
        veri_r        <= 32'd0;                      
        veri_hazir_r  <= 1'b0;                                                                    
        obek_okunan_r <= 128'd0;                                                               
        anabellek_adres_r <= 32'd0;           
        anabellek_kirli_obek_r  <= 128'd0;     
        anabellek_kirli_adres_r <= 32'd0;            
    end
end

assign      veri_o  =   veri_r; 
assign      veri_hazir_o  = veri_hazir_r; 
assign      anabellek_istek_o = ((durum_r==ONBELLEK && durum_ns == ANABELLEK_YAZ) || (durum_r == ONBELLEK && durum_ns == ANABELLEK_OKU) || (durum_r==ANABELLEK_YAZ && anabellek_hazir_i==1'b1));
assign      obek_okunan_o = obek_okunan_r;
assign      onbellek_obek_yaz_o = (durum_r==ANABELLEK_OKU)&&(durum_ns==ONBELLEK_YAZ);

assign      onbellek_adres_o  = adres_i;
assign      onbellek_veri_o  =  veri_i;
assign      bellek_oku_o = bellek_oku_i;  
assign      bellek_yaz_o = bellek_yaz_i;  
assign      buyruk_turu_o = buyruk_turu_i; 

assign      anabellek_yaz_o = (durum_ns == ANABELLEK_YAZ);        
assign      anabellek_oku_o = (durum_ns == ANABELLEK_OKU);        
assign      anabellek_adres_o = anabellek_adres_r;      
assign      anabellek_kirli_obek_o = anabellek_kirli_obek_r; 
assign      anabellek_kirli_adres_o = anabellek_kirli_adres_r;

endmodule