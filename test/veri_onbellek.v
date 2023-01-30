`timescale 1ns / 1ps

`include "operations.vh"

module  veri_onbellek(
    
    input                   clk_i,
    input                   rst_i,
    
    input       [127:0]     denetleyici_obek_i, // wrapperda deðiþ veri_obek_i eski hali
    input       [31:0]      adres_i,
    input       [31:0]      veri_i,
    input                   bellekten_oku_i, 
    input                   bellege_yaz_i,
    input                   anabellekten_obek_geldi_i,
    input       [2:0]       buyruk_turu_i,
        
    output      [127:0]     veri_obegi_o ,
    output      [31:0]      okunan_veri_o,
    output      [31:0]      kirli_obek_adresi_o,
    output                  adres_bulundu_o,
    output                  obek_kirli_o
          
);       
localparam  BOSTA = 0;     
localparam  ONBELLEK_OKU = 1;                                   
localparam  ANABELLEK = 2;
localparam  ONBELLEK_YAZ = 3;
                                   
reg     [1:0]          durum_r;                                
reg     [1:0]          durum_ns;

reg     [127:0]        veri_obegi_r;

reg                    adres_bulundu_r ;

reg     [31:0]         okunan_veri_r;

reg                    obek_kirli_r ;

reg     [31:0]         kirli_obek_adresi_r;

// onbellek icin 

reg     [127:0]  kirli_buffer_r     ;
reg     [127:0]  kirli_buffer_ns    ;

reg     [127:0]  gecerli_buffer_r   ;
reg     [127:0]  gecerli_buffer_ns  ;


reg     [6:0]   sram_adres_r = 7'd0;

reg              sram_en_r = 1'b0;

reg              sram_wen_r = 1'b0;

reg     [148:0]  sram_obek_r = 149'd0;

wire    [148:0]  sram_obek_i;
sram_ornek sram(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .en_i(sram_en_r),
    .wen_i(sram_wen_r),
    .adres_i(sram_adres_r),
    .veri_i(sram_obek_r),
    
    .obek_o(sram_obek_i)
);

wire     [6:0]    onbellek_adres;
wire     [3:0]    secilen_byte;
wire     [20:0]   etiket;

assign      onbellek_adres =  adres_i[10:4];
assign      secilen_byte   =  adres_i[3:0];
assign      etiket         =  adres_i[31:11];
 
always @(*) begin

        durum_ns = durum_r;
        kirli_buffer_ns = kirli_buffer_r;
        gecerli_buffer_ns = gecerli_buffer_r;
        kirli_obek_adresi_r = 32'd0; 
        veri_obegi_r = 128'd0; 
        adres_bulundu_r = 1'b0;
        okunan_veri_r = 32'd0;
        obek_kirli_r = 1'b0;
        sram_adres_r = 7'd0;  
        sram_en_r = 1'b0;
        sram_wen_r = 1'b0;
        sram_obek_r = 149'd0;
        
       if(bellekten_oku_i == 1'b1 || bellege_yaz_i == 1'b1) begin
        case(durum_r)
        BOSTA : begin
            sram_adres_r = onbellek_adres;            
            sram_en_r = 1'b1;
            sram_wen_r = 1'b0;
            durum_ns = ONBELLEK_OKU;            
        end
        ONBELLEK_OKU:  begin    
            sram_adres_r = onbellek_adres;            
            sram_en_r = 1'b1;
            sram_wen_r = 1'b0;
            sram_obek_r = sram_obek_i;
            if(bellekten_oku_i) begin
                
                if(gecerli_buffer_r[onbellek_adres] == 1'b0) begin
                    obek_kirli_r = 1'b0;
                    adres_bulundu_r = 1'b0;
                    durum_ns = ANABELLEK;
                end                               
                else if(sram_obek_i[148:128] != etiket) begin
                     adres_bulundu_r = 0;
                     if(kirli_buffer_r[onbellek_adres] == 1) begin 
                        obek_kirli_r = 1'b1;
                        veri_obegi_r = sram_obek_i[127:0];
                        kirli_obek_adresi_r = {sram_obek_i[148:128] , onbellek_adres , 4'b0000};
                     end
                     else begin
                        obek_kirli_r = 1'b0;                       
                     end   
                     durum_ns = ANABELLEK;           
                end                     
                else if(sram_obek_i[148:128] == etiket)begin
                       case(buyruk_turu_i)
                            `MEM_LB  : begin
                                okunan_veri_r = {{24{sram_obek_i[secilen_byte * 8 + 7]}},sram_obek_i[(secilen_byte*8) +: 8]};
                             end                     
                            `MEM_LH  : begin 
                                okunan_veri_r = {{16{sram_obek_i[secilen_byte * 8 + 15]}},sram_obek_i[(secilen_byte * 8) +: 16]};
                             end
                            `MEM_LW  : begin  
                                okunan_veri_r = sram_obek_i[(secilen_byte * 8) +: 32];
                             end
                            `MEM_LBU :  begin 
                                okunan_veri_r = {{24{1'b0}},sram_obek_i[(secilen_byte * 8) +: 8]};
                             end                      
                            `MEM_LHU : begin 
                                okunan_veri_r = {{24{1'b0}},sram_obek_i[(secilen_byte * 8 ) +: 16]};  
                             end
                       endcase
                       durum_ns = BOSTA;
                       adres_bulundu_r = 1;
                end           
            end
        
            else if(bellege_yaz_i)begin
                
                if(gecerli_buffer_r[onbellek_adres] == 1'b0) begin
                
                    obek_kirli_r = 1'b0;
                    adres_bulundu_r = 1'b0;
                    durum_ns = ANABELLEK;                    
                end 
         
                else if(sram_obek_i[148:128] != etiket) begin
                     adres_bulundu_r = 0;
                     if(kirli_buffer_r[onbellek_adres] == 1) begin 
                        obek_kirli_r = 1;
                        veri_obegi_r = sram_obek_i[127:0];
                        kirli_obek_adresi_r = {sram_obek_i[148:128] , onbellek_adres , 4'b0000};
                     end
                     else begin
                        obek_kirli_r = 0;                       
                     end   
                     durum_ns = ANABELLEK;                      
                end
            
                else if(sram_obek_i[148:128] == etiket) begin
                    sram_wen_r = 1'b1;
                    sram_adres_r = onbellek_adres;
                    kirli_buffer_ns[onbellek_adres] = 1'b1;
                    sram_obek_r = sram_obek_i;
                    case(buyruk_turu_i)                   
                        `MEM_SB : sram_obek_r[(secilen_byte)*8 +: 8]  = veri_i[7:0]; 
                        `MEM_SH : sram_obek_r[(secilen_byte)*8 +: 16] = veri_i[15:0];
                        `MEM_SW : sram_obek_r[(secilen_byte)*8 +: 32] = veri_i[31:0];
                    endcase
                    sram_obek_r[148:128] = etiket;
                    adres_bulundu_r = 1;
                    durum_ns = BOSTA;
                end    
            end
        end    
        ANABELLEK: begin
            sram_adres_r = onbellek_adres; 
            sram_en_r = 1'b0;
            sram_wen_r = 1'b0;
            sram_obek_r = sram_obek_i;       
            if(anabellekten_obek_geldi_i) begin
                sram_en_r = 1'b1;
                sram_wen_r = 1'b1;
                if(bellekten_oku_i) begin
                    sram_obek_r[127:0] = denetleyici_obek_i;
                    kirli_buffer_ns[onbellek_adres] = 1'b0;  
                    sram_obek_r[148:128] = etiket; 
                    gecerli_buffer_ns[onbellek_adres] = 1'b1; 
                    durum_ns = ONBELLEK_YAZ;  
                end
                else if(bellege_yaz_i) begin
                    sram_obek_r[127:0] = denetleyici_obek_i;
                    sram_obek_r[148:128] = etiket;
                    case(buyruk_turu_i) 
                        `MEM_SB :  sram_obek_r[(secilen_byte*8)+:8]  = veri_i[7:0];                  
                        `MEM_SH :  sram_obek_r[(secilen_byte*8)+:16] = veri_i[15:0];                
                        `MEM_SW :  sram_obek_r[(secilen_byte*8)+:32] = veri_i[31:0];    
                    endcase
                    kirli_buffer_ns[onbellek_adres] = 1'b1; 
                    gecerli_buffer_ns[onbellek_adres] = 1'b1; 
                    durum_ns = ONBELLEK_YAZ;                 
                end
            end
        end
        ONBELLEK_YAZ : begin
            // bir önceki aþamada önbelleðe yazma yapýlýr ama bir çevrim beklemek gerek ayný anda yazma ve okuma yapýlamayacaðýndan bu sebepten bu durum yazýldý
            sram_en_r = 1'b0;
            sram_wen_r = 1'b0;
            durum_ns = BOSTA;         
        end    
    endcase
   end
end
always @(posedge clk_i) begin
    
    if(!rst_i) begin

         kirli_buffer_r <= 128'd0;
         gecerli_buffer_r <= 128'd0;                  
         durum_r <= 1'b0;
    end 
    else begin  
        durum_r <= durum_ns;
        kirli_buffer_r <= kirli_buffer_ns;
        gecerli_buffer_r <= gecerli_buffer_ns;
    end
end

assign        okunan_veri_o         =   okunan_veri_r;      
assign        adres_bulundu_o       =   adres_bulundu_r;               
assign        obek_kirli_o          =   obek_kirli_r;        
assign        veri_obegi_o          =   veri_obegi_r;                  
assign        kirli_obek_adresi_o   =   kirli_obek_adresi_r;

endmodule