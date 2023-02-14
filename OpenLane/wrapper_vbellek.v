`timescale 1ns / 1ps

`include "operations.vh"

module wrapper_vbellek (
        input clk_i,
        input rst_i,
        
        //bellek asamasindan gelecek olan sinyaller
        input        onbellekten_oku_i, 
        input        onbellege_yaz_i,
        input [31:0] adres_i,
        input [31:0] veri_i,
        input [2:0]  buyruk_turu_i,
        
        // anabellekten denetleyiciden gelecek olan sinyaller
        input         anabellek_musait_i,
        input         anabellek_hazir_i,
        input [127:0] anabellek_obek_i,

        // anabellek denetleyiciye verilecek sinyaller
        output         anabellek_yaz_o,
        output         anabellek_oku_o,
        output         anabellek_istek_o, 
        output [31:0]  anabellek_adres_o,
        output [127:0] anabellek_kirli_obek_o,
        
        // bellek asamasina verilecekler sinyaller
        output [31:0] veri_o, 
        output        veri_hazir_o, 
        output        denetim_hazir_o            
    );

    localparam  BOSTA         = 3'd0;
    localparam  ONBELLEK_OKU  = 3'd1;
    localparam  ANABELLEK_YAZ = 3'd2;
    localparam  ANABELLEK_OKU = 3'd3;

    reg     [1:0]       durum_r;
    reg     [1:0]       durum_ns;

    reg     [31:0]      veri_r;

    reg                 veri_hazir_r ;

    reg     [31:0]      anabellek_adres_r; 

    reg     [127:0]     anabellek_kirli_obek_r;
    reg     [127:0]     anabellek_kirli_obek_ns;

    reg                 denetim_hazir_r;

    reg     [3:0]       secilen_byte_r;
    reg     [3:0]       secilen_byte_ns;

    reg     [127:0]     kirli_buffer_r;
    reg     [127:0]     kirli_buffer_ns;

    reg     [127:0]     gecerli_buffer_r;
    reg     [127:0]     gecerli_buffer_ns;

    // onbellek icin

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

    wire     [6:0]    onbellek_satir_numarasi_w;
    wire     [20:0]   etiket_w;

    assign      onbellek_satir_numarasi_w =  adres_i[10:4];
    assign      etiket_w         =  adres_i[31:11];
    
    always @(*) begin

            durum_ns = durum_r;
            secilen_byte_ns = secilen_byte_r;
            kirli_buffer_ns = kirli_buffer_r;
            gecerli_buffer_ns = gecerli_buffer_r;
            anabellek_kirli_obek_ns = anabellek_kirli_obek_r;
            
            anabellek_adres_r = 32'd0;
            veri_r = 32'd0;
            veri_hazir_r = 1'b0;   
            sram_adres_r = 7'd0;  
            sram_en_r = 1'b0;
            sram_wen_r = 1'b0;
            sram_obek_r = 149'd0;       
            denetim_hazir_r = 1'b0;
        
        if(onbellekten_oku_i == 1'b1 || onbellege_yaz_i == 1'b1) begin
            case(durum_r)
            
            BOSTA : begin
                sram_adres_r = onbellek_satir_numarasi_w;            
                sram_en_r = 1'b1;
                sram_wen_r = 1'b0;
                veri_hazir_r = 1'b0;
                denetim_hazir_r = 1'b0;
                durum_ns = ONBELLEK_OKU;  
                secilen_byte_ns = adres_i[3:0];          
            end
            
            ONBELLEK_OKU:  begin    

                sram_adres_r = onbellek_satir_numarasi_w;            
                sram_en_r = 1'b0;
                sram_wen_r = 1'b0;
                sram_obek_r = sram_obek_i;
    
                if(onbellekten_oku_i) begin
                    
                    if(gecerli_buffer_r[onbellek_satir_numarasi_w] == 1'b0) begin
                        veri_hazir_r = 1'b0;
                        denetim_hazir_r = 1'b0;
                        secilen_byte_ns = adres_i[3:0];
                        if(anabellek_musait_i) begin
                            durum_ns = ANABELLEK_OKU;    
                            anabellek_adres_r = {adres_i[31:4], 4'b0000};                                                       
                        end
                    end    
                                            
                    else if(sram_obek_i[148:128] != etiket_w) begin
                        veri_hazir_r = 1'b0;
                        denetim_hazir_r = 1'b0;
                        secilen_byte_ns = adres_i[3:0];
                        if(anabellek_musait_i) begin
                            if(kirli_buffer_r[onbellek_satir_numarasi_w] == 1) begin 
                                anabellek_kirli_obek_ns = sram_obek_i[127:0];
                                anabellek_adres_r = {sram_obek_i[148:128] , onbellek_satir_numarasi_w , 4'b0000};
                                durum_ns = ANABELLEK_YAZ;
                            end
                            else begin
                                anabellek_adres_r = {adres_i[31:4], 4'b0000};
                                durum_ns = ANABELLEK_OKU;                                                                                
                            end   
                        end                                
                    end    
                                    
                    else if(sram_obek_i[148:128] == etiket_w)begin
                        veri_hazir_r = 1'b1;
                        denetim_hazir_r = 1'b1;
                        case(buyruk_turu_i)
                                `MEM_LB  : begin
                                    veri_r = {{24{sram_obek_i[secilen_byte_r * 8 + 7]}},sram_obek_i[(secilen_byte_r*8) +: 8]};
                                end                     
                                `MEM_LH  : begin 
                                    veri_r = {{16{sram_obek_i[secilen_byte_r * 8 + 15]}},sram_obek_i[(secilen_byte_r * 8) +: 16]};
                                end
                                `MEM_LW  : begin  
                                    veri_r = sram_obek_i[(secilen_byte_r * 8) +: 32];
                                end
                                `MEM_LBU :  begin 
                                veri_r = {{24{1'b0}},sram_obek_i[(secilen_byte_r * 8) +: 8]};
                                end                      
                                `MEM_LHU : begin 
                                    veri_r = {{24{1'b0}},sram_obek_i[(secilen_byte_r * 8 ) +: 16]};  
                                end
                        endcase
                        durum_ns = BOSTA;  
                    end    
                        
                end
            
                else if(onbellege_yaz_i)begin
                    
                    if(gecerli_buffer_r[onbellek_satir_numarasi_w] == 1'b0) begin                              
                        veri_hazir_r = 1'b0;
                        denetim_hazir_r = 1'b0;
                        secilen_byte_ns = adres_i[3:0];
                        if(anabellek_musait_i) begin
                            durum_ns = ANABELLEK_OKU;    
                            anabellek_adres_r = {adres_i[31:4], 4'b0000};                                                       
                        end
                    end 
            
                    else if(sram_obek_i[148:128] != etiket_w) begin
                        veri_hazir_r = 1'b0;
                        denetim_hazir_r = 1'b0;
                        secilen_byte_ns = adres_i[3:0];
                        if(anabellek_musait_i) begin
                            if(kirli_buffer_r[onbellek_satir_numarasi_w] == 1) begin 
                                anabellek_kirli_obek_ns = sram_obek_i[127:0];
                                anabellek_adres_r = {sram_obek_i[148:128] , onbellek_satir_numarasi_w , 4'b0000};
                                durum_ns = ANABELLEK_YAZ;
                            end
                            else begin
                                anabellek_adres_r = {adres_i[31:4], 4'b0000};
                                durum_ns = ANABELLEK_OKU;                                                                                
                            end   
                        end                                
                    end
                
                    else if(sram_obek_i[148:128] == etiket_w) begin
                        
                        veri_hazir_r = 1'b1;
                        denetim_hazir_r = 1'b1;   
                        sram_en_r = 1'b1;
                        sram_wen_r = 1'b1;
                        sram_adres_r = onbellek_satir_numarasi_w;
                        kirli_buffer_ns[onbellek_satir_numarasi_w] = 1'b1;
                        
                        case(buyruk_turu_i)                   
                            `MEM_SB : sram_obek_r[(secilen_byte_r)*8 +: 8]  = veri_i[7:0]; 
                            `MEM_SH : sram_obek_r[(secilen_byte_r)*8 +: 16] = veri_i[15:0];
                            `MEM_SW : sram_obek_r[(secilen_byte_r)*8 +: 32] = veri_i[31:0];
                        endcase
                        
                        sram_obek_r[148:128] = etiket_w;
                        durum_ns = BOSTA;
                    end    
                end
            end   
            
            ANABELLEK_YAZ: begin
                if(anabellek_hazir_i) begin                  
                    anabellek_adres_r = {adres_i[31:4], 4'b0000};
                    veri_hazir_r = 1'b0;
                    denetim_hazir_r = 1'b0;  
                    durum_ns = ANABELLEK_OKU;
                end                  
                        
            end  
            ANABELLEK_OKU: begin
            
                sram_adres_r = onbellek_satir_numarasi_w; 
                sram_en_r = 1'b0;
                sram_wen_r = 1'b0;
                sram_obek_r = sram_obek_i;       
                if(anabellek_hazir_i) begin
                    sram_en_r = 1'b1;
                    sram_wen_r = 1'b1;
                    if(onbellekten_oku_i) begin
                    case(buyruk_turu_i)
                            `MEM_LB  : begin
                                veri_r  = {{24{anabellek_obek_i[secilen_byte_r * 8 + 7]}} , anabellek_obek_i[secilen_byte_r * 8 +: 8]};
                            end                     
                            `MEM_LH  : begin 
                                veri_r  = {{16{anabellek_obek_i[secilen_byte_r * 8 + 15]}} , anabellek_obek_i[secilen_byte_r*8 +: 16]};
                            end
                            `MEM_LW  : begin  
                                veri_r  = anabellek_obek_i[secilen_byte_r * 8 +: 32];
                            end
                            `MEM_LBU :  begin 
                                veri_r = { {24{1'b0}}, anabellek_obek_i[secilen_byte_r * 8 +: 8]};
                            end                      
                            `MEM_LHU : begin 
                                veri_r = { {16{1'b0}}, anabellek_obek_i[secilen_byte_r * 8 +: 16]}; 
                            end
                        endcase

                        sram_obek_r[127:0] = anabellek_obek_i;
                        sram_obek_r[148:128] = etiket_w;
                        kirli_buffer_ns[onbellek_satir_numarasi_w] = 1'b0;  
                        gecerli_buffer_ns[onbellek_satir_numarasi_w] = 1'b1; 
                        
                    end
                    
                    else if(onbellege_yaz_i) begin
                        sram_obek_r[127:0] = anabellek_obek_i;
                        case(buyruk_turu_i) 
                            `MEM_SB :  sram_obek_r[(secilen_byte_r*8)+:8]  = veri_i[7:0];                  
                            `MEM_SH :  sram_obek_r[(secilen_byte_r*8)+:16] = veri_i[15:0];                
                            `MEM_SW :  sram_obek_r[(secilen_byte_r*8)+:32] = veri_i;    
                        endcase                 
                        sram_obek_r[148:128] = etiket_w;
                        kirli_buffer_ns[onbellek_satir_numarasi_w] = 1'b1; 
                        gecerli_buffer_ns[onbellek_satir_numarasi_w] = 1'b1; 
                                        
                    end
                    veri_hazir_r = 1'b1;
                    denetim_hazir_r = 1'b1;                     
                    durum_ns = BOSTA;
                end          
            end
        endcase
    end
    end
    always @(posedge clk_i) begin
        
        if(!rst_i) begin

            kirli_buffer_r <= 128'd0;
            gecerli_buffer_r <= 128'd0;                  
            durum_r <= 1'b0;
            secilen_byte_r <= 4'd0;
            anabellek_kirli_obek_r <=128'd0;
        end 
        else begin  
            durum_r <= durum_ns;
            secilen_byte_r <= secilen_byte_ns;
            kirli_buffer_r <= kirli_buffer_ns;
            gecerli_buffer_r <= gecerli_buffer_ns;
            anabellek_kirli_obek_r <= anabellek_kirli_obek_ns;
        end
    end

    assign      veri_o  =   veri_r; 
    assign      veri_hazir_o  = veri_hazir_r; 

    assign      anabellek_istek_o = ((durum_r==ONBELLEK_OKU && durum_ns == ANABELLEK_YAZ) || (durum_r == ONBELLEK_OKU && durum_ns == ANABELLEK_OKU) || (durum_r==ANABELLEK_YAZ && anabellek_hazir_i==1'b1));
    assign      anabellek_yaz_o = (durum_ns == ANABELLEK_YAZ);        
    assign      anabellek_oku_o = (durum_ns == ANABELLEK_OKU);        
    assign      anabellek_adres_o = anabellek_adres_r;      
    assign      anabellek_kirli_obek_o = anabellek_kirli_obek_ns; 

    assign      denetim_hazir_o = denetim_hazir_r;

endmodule