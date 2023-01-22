`timescale 1ns / 1ps

`include "operations.vh"
/*
    ***** cozden gelen inputlar *****
    bellek_oku_i => load geldi?ini s?yler
    bellek_yaz_i => store geldi?ini s?yler
    adres_i      => gelen buyru?un adresi
    veri_i       => yaz?lacak olan veri
    buyruk_turu_i => load sa hangi load t?r? storesa hangi store t?r?
    
    ***** onbellek inputlar? *****
    adres_bulundu_i  =>  onbellekte adres bulundu
    onbellek_veri_i  =>  onbellekte load da gelen veri
    kirli_obek_i     =>  anabelle?e yaz?lmas? gereken kirli veri
    kirli_obek_adresi_i => belle?e kirli ?be?i yazacakken onun adresi
    obek_kirli_i   
    
    ***** onbellek outputlar? *****
    
    obek_okunan_o  => anabellekten gelen obe?i onbelle?e gondermek i?in            
    onbellek_obek_yaz_o  =>   anabellketen obek gelid onbelle?e yaz demek i?in
    
    **** direkt assignlan?rlar yani denetleyicide bi i?lem yap?lmaz bunlara ****
    
     onbellek_adres_o => gelen adres_i direkt buna atan?r
     onbellek_veri_o  => gelen veri_i direkt buna atan?r 
     bellek_oku_o     => gelen bellek_oku_i  ""   
     bellek_yaz_o,    => gelen bellek_yaz_i  ""
     buyruk_turu_o,   => gelen buyruk_turu_i ""
     
     
     **** anabellek denetleyiciyle ilgili olanlar?n anlamlar? a??k ****
    
    **** geri yaza ***
    veri_o
    veri_hazir_o
    
    **** denetim birimi ****
    denetim_i => 1 olursa durdurur
    denetim_hazir_o => e?er 0 sa pipeline durmal? 1 se yeni adres gelebilir  
 */
module veri_onbellek_denetleyici(
    input           clk_i,
    input           rst_i,
    
    // cozden gelen inputlar
    input           bellek_oku_i, 
    input           bellek_yaz_i,
    input   [31:0]  adres_i,
   // input   [31:0]  veri_i,
    input   [2:0]   buyruk_turu_i,
    
    // onbellek inputlari
    input           adres_bulundu_i,
    input   [31:0]  onbellek_veri_i,
    input   [127:0] kirli_obek_i,
    input   [31:0]  kirli_obek_adresi_i,
    input           obek_kirli_i,   

    // onbellek outputlari
    output  [127:0] obek_okunan_o,
    output          onbellek_obek_yaz_o,
    
    // anabellek denetleyiciye verilecek olanlar 
    output          anabellek_yaz_o,
    output          anabellek_oku_o,
    output          anabellek_istek_o, 
    output  [31:0]  anabellek_adres_o,
    output  [127:0] anabellek_kirli_obek_o,
    
    // anabellekten gelecek olan sinyaller
    input           anabellek_musait_i,
    input           anabellek_hazir_i,
    input   [127:0] okunan_obek_i,
                
    // geriyaza verilecekler
    output  [31:0]  veri_o, 
    output          veri_hazir_o, 
    
    // denetim birimine     
    output          denetim_hazir_o
           
);

localparam  ONBELLEK      = 2'b00;
localparam  ANABELLEK_YAZ = 2'b01;
localparam  ANABELLEK_OKU = 2'b10;
localparam  ONBELLEK_YAZ  = 2'b11;

reg     [1:0]       durum_r = ONBELLEK;
reg     [1:0]       durum_ns;

reg     [31:0]      veri_r;
reg                 veri_hazir_r ;

reg     [127:0]     obek_okunan_r;

reg     [31:0]      anabellek_adres_r; 
reg     [127:0]     anabellek_kirli_obek_r ;
reg     [31:0]      anabellek_kirli_adres_r ;

reg                 denetim_hazir_r;

reg     [3:0]       secilen_byte_r;
reg     [3:0]       secilen_byte_ns;

   
always @(*) begin 
   
   secilen_byte_ns = secilen_byte_r; 
   durum_ns = durum_r;
   
   veri_r = 32'd0;
   veri_hazir_r = 1'b0;   
   obek_okunan_r = 128'd0;
   anabellek_kirli_adres_r = 32'd0;
   anabellek_kirli_obek_r = 128'd0;
   anabellek_adres_r = 32'd0;
   denetim_hazir_r = 1'b0; 
 
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
                        denetim_hazir_r = 1'b1;     
                   end 
                   else begin
                        veri_hazir_r = 1'b0;
                        denetim_hazir_r = 1'b0;
                        secilen_byte_ns   =  adres_i[3:0];
                        if(anabellek_musait_i) begin
                            
                              if(obek_kirli_i) begin                                        
                                durum_ns = ANABELLEK_YAZ;
                                //anabellek_kirli_adres_r = kirli_obek_adresi_i;
                                anabellek_adres_r = kirli_obek_adresi_i;
                                anabellek_kirli_obek_r = kirli_obek_i;                               
                              end
                              else begin
                                durum_ns = ANABELLEK_OKU;    
                                anabellek_adres_r = {adres_i[31:4], 4'b0000};                                                       
                              end
                        end  
                   end               
              end
              else if(bellek_yaz_i) begin
                    if(adres_bulundu_i) begin
                        veri_hazir_r = 1'b1;
                        denetim_hazir_r = 1'b1;                     
                    end
                    else begin
                        veri_hazir_r = 1'b0;
                        denetim_hazir_r = 1'b0;
                        if(anabellek_musait_i) begin
                        
                              if(obek_kirli_i) begin                                        
                                durum_ns = ANABELLEK_YAZ;
                                //anabellek_kirli_adres_r = kirli_obek_adresi_i;
                                anabellek_adres_r = kirli_obek_adresi_i;
                                anabellek_kirli_obek_r = kirli_obek_i;
                                
                              end
                              else begin
                                durum_ns = ANABELLEK_OKU; 
                                anabellek_adres_r = {adres_i[31:4], 4'b0000};                                                           
                              end            
                        end  
                    end
              end
          end          
          
          ANABELLEK_YAZ : begin 
             anabellek_adres_r = kirli_obek_adresi_i;
             anabellek_kirli_obek_r = kirli_obek_i;
             
             if(anabellek_hazir_i) begin 
                    
                   anabellek_adres_r = {adres_i[31:4], 4'b0000};
                   veri_hazir_r = 1'b0;
                   denetim_hazir_r = 1'b0;  
                   durum_ns = ANABELLEK_OKU;
             end        
          
          end
              
          ANABELLEK_OKU : begin 
          
             anabellek_adres_r = {adres_i[31:4], 4'b0000};
             if(anabellek_hazir_i) begin
                
                 obek_okunan_r = okunan_obek_i; 
                 durum_ns = ONBELLEK_YAZ;
             end
          end
        
          ONBELLEK_YAZ : begin 
            durum_ns = ONBELLEK;
            if(bellek_oku_i) begin  
                case(buyruk_turu_i)
                    `MEM_LB  : begin
                        veri_r  = {{24{okunan_obek_i[secilen_byte_ns*8 + 7]}} , okunan_obek_i[secilen_byte_ns*8 +: 8]};
                     end                     
                    `MEM_LH  : begin 
                        veri_r  = {{16{okunan_obek_i[secilen_byte_ns*8 + 15]}} , okunan_obek_i[secilen_byte_ns*8 +: 16]};
                     end
                    `MEM_LW  : begin  
                        veri_r  = okunan_obek_i[secilen_byte_ns*8 +: 32];
                     end
                    `MEM_LBU :  begin 
                        veri_r = { {24{1'b0}}, okunan_obek_i[secilen_byte_ns*8 +: 8]};
                     end                      
                    `MEM_LHU : begin 
                        veri_r = { {16{1'b0}}, okunan_obek_i[secilen_byte_ns*8 +: 16]}; 
                     end
                 endcase
                 
            end
            veri_hazir_r = 1'b1;
            denetim_hazir_r = 1'b1;                     
          end  
    endcase 
    end
    end      


always @(posedge clk_i) begin
    if(!rst_i) begin
        durum_r <= 2'd0;
        secilen_byte_r <= 4'd0; 
        
    end
    else begin
        secilen_byte_r  <= secilen_byte_ns;
        durum_r <= durum_ns;
                                                                                         
    end
end

assign      veri_o  =   veri_r; 
assign      veri_hazir_o  = veri_hazir_r; 
assign      anabellek_istek_o = ((durum_r==ONBELLEK && durum_ns == ANABELLEK_YAZ) || (durum_r == ONBELLEK && durum_ns == ANABELLEK_OKU) || (durum_r==ANABELLEK_YAZ && anabellek_hazir_i==1'b1));
assign      obek_okunan_o = obek_okunan_r;
assign      onbellek_obek_yaz_o = (durum_r==ANABELLEK_OKU)&&(durum_ns==ONBELLEK_YAZ);

assign      anabellek_yaz_o = (durum_ns == ANABELLEK_YAZ);        
assign      anabellek_oku_o = (durum_ns == ANABELLEK_OKU);        
assign      anabellek_adres_o = anabellek_adres_r;      
assign      anabellek_kirli_obek_o = anabellek_kirli_obek_r; 
assign      denetim_hazir_o = denetim_hazir_r;

endmodule