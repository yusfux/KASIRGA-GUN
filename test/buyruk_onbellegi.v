`timescale 1ns / 1ps

`include "operations.vh"

module buyruk_onbellegi(
    input               clk_i,
    input               rst_i,
    
    input               durdur_i,
    
    input     [31:0]    adres_i,                    //  bellek_adresi
    
    input     [127:0]   buyruk_obek_i,              //  bellekten gelen ?bek
    input               anabellekten_obek_geldi_i,  //  anabellekten obek gelme islemi tamamlandi
    input     [31:0]    onbellek_yaz_adres_i,    

    output    [31:0]    buyruk_o,                   //  buyruk
    output              adres_bulundu_o             //  anbellekte adres bulundu          
);

localparam  BOSTA = 2'b00;                  
localparam  ONBELLEK_OKU = 2'b01;                                   
localparam  ANABELLEK = 2'b10;
localparam  ONBELLEK_YAZ = 2'b11;
                                   
reg      [1:0]         durum_r;                                
reg      [1:0]         durum_ns;

reg                    adres_bulundu_r;

reg     [31:0]         buyruk_r;

wire     [7:0]      onbellek_yaz_dizin_w;
wire     [19:0]     etiket_yaz_w;

assign  onbellek_yaz_dizin_w     =    onbellek_yaz_adres_i[11:4]; 
assign  etiket_yaz_w             =    onbellek_yaz_adres_i[31:12];

// onbellek icin 

reg     [127:0]  gecerli_buffer_r;
reg     [127:0]  gecerli_buffer_ns;

reg     [6:0]    sram_adres_r;

reg              sram_en_r;

reg              sram_wen_r;

reg     [148:0]  sram_obek_r;

wire    [148:0]  sram_obek_i;
sram_buyruk sram(
    
    .rst_i(rst_i),
    .clk_i(clk_i),
    .en_i(sram_en_r),
    .wen_i(sram_wen_r),
    .adres_i(sram_adres_r),
    .veri_i(sram_obek_r),
    
    .obek_o(sram_obek_i)
);

wire     [6:0]    onbellek_adres_w;
wire     [3:0]    secilen_byte_w;
wire     [20:0]   etiket_w;

assign      onbellek_adres_w =  adres_i[10:4];
assign      secilen_byte_w   =  adres_i[3:0];
assign      etiket_w         =  adres_i[31:11];

wire     [127:0]  sram_obek_w;   
assign      sram_obek_w = sram_obek_i[127:0];

 
always @(*) begin

        durum_ns = durum_r;
        gecerli_buffer_ns = gecerli_buffer_r;
        adres_bulundu_r = 1'b0;
        buyruk_r = 32'd0;
        sram_adres_r = onbellek_adres_w;  
        sram_en_r = 1'b0;
        sram_wen_r = 1'b0;
        sram_obek_r = 149'd0;
        
        case(durum_r)
        BOSTA : begin
            if(!durdur_i) begin
                sram_adres_r = onbellek_adres_w;
                sram_en_r = 1'b1;
                sram_wen_r = 1'b0; 
                durum_ns = ONBELLEK_OKU;
            end
        end 
        ONBELLEK_OKU:  begin    
            if(!durdur_i) begin
                sram_adres_r = onbellek_adres_w;
                sram_en_r = 1'b0;
                sram_wen_r = 1'b0;
                sram_obek_r = sram_obek_i;
                    
                if(gecerli_buffer_r[onbellek_adres_w] == 1'b0) begin
           
                    adres_bulundu_r = 1'b0;
                    durum_ns = ANABELLEK;
                end 
                               
                else if(sram_obek_i[148:128] != etiket_w) begin
            
                     adres_bulundu_r = 0;
                     durum_ns = ANABELLEK;           
                end   
                    
                else if(sram_obek_i[148:128] == etiket_w)begin
                        
                        buyruk_r = sram_obek_w[(secilen_byte_w * 8) +: 32];
                        durum_ns = BOSTA;
                        adres_bulundu_r = 1;
                end           
            end
        end
        ANABELLEK: begin         
            sram_en_r = 1'b0;
            sram_wen_r = 1'b0;
            if(anabellekten_obek_geldi_i) begin
                sram_en_r = 1'b1;
                sram_wen_r = 1'b1; 
                sram_obek_r[127:0] = buyruk_obek_i;
                sram_obek_r[148:128] = etiket_yaz_w; 
                sram_adres_r = onbellek_yaz_dizin_w;
                gecerli_buffer_ns[onbellek_yaz_dizin_w] = 1'b1; 
                durum_ns = ONBELLEK_YAZ;  
            end        
        end  
        ONBELLEK_YAZ : begin
            // bir önceki aşamada önbelleğe yazma yapılır ama bir çevrim beklemek gerek aynı anda yazma ve okuma yapılamayacağından bu sebepten bu durum yazıldı
            if(!durdur_i) begin
                sram_en_r = 1'b0;
                sram_wen_r = 1'b0;
                durum_ns = BOSTA;  
            end       
        end              
    endcase
end
always @(posedge clk_i) begin
    
    if(!rst_i) begin        
         gecerli_buffer_r <= 128'd0;                  
         durum_r <= 1'b0;
    end 
    else begin  
        durum_r <= durum_ns;
        gecerli_buffer_r <= gecerli_buffer_ns;
    end
end

assign        buyruk_o       =   buyruk_r;      
assign        adres_bulundu_o       =   adres_bulundu_r;               
           
endmodule