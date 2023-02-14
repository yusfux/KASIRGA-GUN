`timescale 1ns / 1ps

module wrapper_bbellek (
        input               clk_i,
        input               rst_i,
        
        //getir asamasindan gelecek olanlar
        input     [31:0]    adres_i,
        input               durdur_i,
        
        // anabellek denetleyiciden gelecek sinyaller
        input               anabellek_musait_i,
        input               anabellek_hazir_i,        
        input   [127:0]     anabellek_obek_i,
        
        // anabellek denetleyiciye gidecek sinyaller
        output  [31:0]      anabellek_adres_o,
        output              anabellek_istek_o,
        output              anabellek_oku_o,
        
        // getir asamasina gidecek olanlar
        output  [31:0]      buyruk_o,
        output              buyruk_hazir_o
    );

    localparam  BOSTA = 2'b00;                  
    localparam  ONBELLEK_OKU = 2'b01;                                   
    localparam  ANABELLEK = 2'b10;
    localparam  ONBELLEK_YAZ = 2'b11;
                                    
    reg      [1:0]         durum_r;                                
    reg      [1:0]         durum_ns;
                        
    reg     [31:0]         buyruk_r;

    reg                    buyruk_hazir_r;

    reg                    adres_bulundu_r;
    reg     [31:0]         anabellek_adres_r;

    reg     [20:0]          etiket_yaz_ns;
    reg     [20:0]          etiket_yaz_r;

    reg     [6:0]           onbellek_yaz_dizin_ns;
    reg     [6:0]           onbellek_yaz_dizin_r;

    reg     [3:0]           secilen_byte_ns;
    reg     [3:0]           secilen_byte_r;

    reg     [31:0]          adres_r;
    reg     [31:0]          adres_ns;

    // onbellek icin 

    reg     [127:0]  gecerli_buffer_r;
    reg     [127:0]  gecerli_buffer_ns;

    reg     [6:0]    sram_satir_r;

    reg              sram_en_r;

    reg              sram_wen_r;

    reg     [148:0]  sram_obek_r;


    wire    [148:0]  sram_obek_i;

    sram_buyruk sram (
        
        .rst_i(rst_i),
        .clk_i(clk_i),
        .en_i(sram_en_r),
        .wen_i(sram_wen_r),
        .adres_i(sram_satir_r),
        .veri_i(sram_obek_r),
        
        .obek_o(sram_obek_i)
    );

    wire     [6:0]    onbellek_satir_w;
    wire     [20:0]   etiket_w;

    assign      onbellek_satir_w  =  adres_i[10:4];
    assign      etiket_w          =  adres_i[31:11];
    
    always @(*) begin

            durum_ns = durum_r;
            adres_ns = adres_r;
            gecerli_buffer_ns = gecerli_buffer_r;
            etiket_yaz_ns = etiket_yaz_r;
            onbellek_yaz_dizin_ns = onbellek_yaz_dizin_r;
            secilen_byte_ns = secilen_byte_r;
            
            buyruk_r = 32'd0;
            sram_satir_r = onbellek_satir_w;  
            sram_en_r = 1'b0;
            sram_wen_r = 1'b0;
            sram_obek_r = 149'd0;
            
            buyruk_hazir_r = 1'b0;
            anabellek_adres_r = 32'd0;
            adres_bulundu_r = 1'b0;
            
            case(durum_r)
            BOSTA : begin
                if(!durdur_i) begin
                    buyruk_hazir_r = 1'b0;
                    sram_satir_r = onbellek_satir_w;
                    sram_en_r = 1'b1;
                    sram_wen_r = 1'b0; 
                    durum_ns = ONBELLEK_OKU;
                    adres_bulundu_r = 1'b0;
                    secilen_byte_ns = adres_i[3:0];
                end
            end 
            ONBELLEK_OKU:  begin  
                
                if(!durdur_i) begin
                    sram_satir_r = onbellek_satir_w;
                    sram_en_r = 1'b0;
                    sram_wen_r = 1'b0;
                    sram_obek_r = sram_obek_i;
                        
                    if(gecerli_buffer_r[onbellek_satir_w] == 1'b0) begin
                        
                        buyruk_hazir_r = 1'b0;
                        if(anabellek_musait_i) begin
                            anabellek_adres_r  =  {adres_i[31:4], 4'b0000};
                            adres_ns = adres_i;
                            etiket_yaz_ns = adres_i[31:11];
                            onbellek_yaz_dizin_ns = adres_i[10:4];
                            durum_ns = ANABELLEK;                     
                        end   
                        
                        adres_bulundu_r = 1'b0;                            
                    end 
                                
                    else if(sram_obek_i[148:128] != etiket_w) begin
                                    
                        buyruk_hazir_r = 1'b0;
                        if(anabellek_musait_i) begin
                            anabellek_adres_r  =  {adres_i[31:4], 4'b0000};
                            etiket_yaz_ns = adres_i[31:11];
                            onbellek_yaz_dizin_ns = adres_i[10:4];
                            adres_ns = adres_i;
                            durum_ns = ANABELLEK;                     
                        end         
                        
                        adres_bulundu_r = 1'b0;                      
                    end   
                    else if(sram_obek_i[148:128] == etiket_w)begin
                        buyruk_hazir_r  =   1'b1;                       
                        buyruk_r = sram_obek_i[(secilen_byte_r * 8) +: 32];
                        durum_ns = BOSTA;
                        
                        adres_bulundu_r = 1'b1;
                    end           
                end
            end
            ANABELLEK: begin 
                        
                sram_en_r = 1'b0;
                sram_wen_r = 1'b0;
                anabellek_adres_r = {adres_i[31:4], 4'b0000};
                if(anabellek_hazir_i) begin
                    sram_en_r = 1'b1;
                    sram_wen_r = 1'b1; 
                    sram_obek_r[127:0] = anabellek_obek_i;
                    sram_obek_r[148:128] = etiket_yaz_r; 
                    sram_satir_r = onbellek_yaz_dizin_r;
                    gecerli_buffer_ns[onbellek_yaz_dizin_r] = 1'b1; 
                    
                    if(adres_i == adres_r) begin
                        buyruk_r  =  anabellek_obek_i[(secilen_byte_r * 8) +: 32];  
                        buyruk_hazir_r = 1'b1;                 
                    end
                    durum_ns = BOSTA; 
                end        
            end  
        endcase
    end
    always @(posedge clk_i) begin
        
        if(!rst_i) begin        
            gecerli_buffer_r <= 128'd0;                  
            durum_r <= 2'd0;
            adres_r <= 32'd0;
        end 
        else begin  
            durum_r <= durum_ns;
            adres_r <= adres_ns;
            gecerli_buffer_r <= gecerli_buffer_ns;
            etiket_yaz_r <= etiket_yaz_ns;
            onbellek_yaz_dizin_r <= onbellek_yaz_dizin_ns;
            secilen_byte_r <= secilen_byte_ns;
        end
    end

    assign anabellek_adres_o      =  anabellek_adres_r;
    assign anabellek_istek_o      =  !durdur_i && ((durum_r == ONBELLEK_OKU && durum_ns == ANABELLEK) || (durum_r == ANABELLEK && !anabellek_hazir_i));      
    assign anabellek_yaz_o        =  1'b0;                                                            
    assign anabellek_oku_o        =  1'b1;                                                                              
    assign buyruk_o               =  buyruk_r;                                                      
    assign buyruk_hazir_o         =  buyruk_hazir_r;  
            
endmodule