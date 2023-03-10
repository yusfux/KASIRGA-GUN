`timescale 1ns / 1ps

module wrapper_abellek (
        input         clk_i,
        input         rst_i,

        //buyruk onbellek denetleyicisinden gelecek sinyaller
        input [31:0]  bbellek_adres_i,            // -> anabellek_adres_o
        input         bbellek_istek_i,            // -> anabellek_istek_o
        input         bbellek_oku_i,              // -> anabellek_oku_o

        //veri onbellek denetleyicisnden gelecek sinyaller
        input         vbellek_yaz_i,
        input         vbellek_oku_i,
        input         vbellek_istek_i,
        input [31:0]  vbellek_adres_i,
        input [127:0] yazilacak_veri_obegi_i,

        //anabellekten gelecek sinyaller
        input         iomem_ready_i,
        input  [31:0] anabellekten_veri_i,
        
        input         timer_i,

        //anabellege gidecek sinyaller
        output [31:0] adres_o,
        output [31:0] yaz_veri_o,
        output        iomem_valid_o,
        output [3:0]  wr_strb_o,
        
        //onbellek denetleyicilere gidecek sinyaller
        output         anabellek_musait_o,
        output [127:0] okunan_veri_obegi_o,
        output         bellek_asamasina_veri_hazir_o,
        output         getir_asamasina_veri_hazir_o
    );

    localparam MUSAIT = 2'b00;
    localparam YAZ    = 2'b01;        
    localparam OKU    = 2'b10; //yeni islem alamaz

    reg [2:0]   veri_sayisi_r; //obekte 4 tane veri var o yuzden 2 bit
    reg [2:0]   veri_sayisi_ns;
    reg [1:0]   durum;
    reg [1:0]   durum_next;

    reg [127:0] okunan_veri_obegi_r;
    reg [127:0] okunan_veri_obegi_ns;
    reg [31:0]  adres_ns;
    reg [31:0]  adres_r;
    reg [31:0] yaz_veri_ns; // parca parca yaziyor
    reg [31:0] yaz_veri_r;
    reg [3:0]  wr_strb_ns;
    reg [31:0] wr_strb_r;
    reg        iomem_valid_r;
    reg        iomem_valid_ns;
    reg        anabellek_musait_r;
    reg        anabellek_musait_ns;
    
    localparam BELLEK = 1'b1;
    localparam GETIR  = 1'b0;
    reg        asama_r;  // 1 -> BELLEK, 0 -> GETIR 
    reg        asama_ns; 
    
    reg        bellek_asamasina_veri_hazir_r;
    reg        bellek_asamasina_veri_hazir_ns;
    reg        getir_asamasina_veri_hazir_r;
    reg        getir_asamasina_veri_hazir_ns;  
    
    always @* begin
        durum_next                     = durum;
        okunan_veri_obegi_ns           = okunan_veri_obegi_r;
        adres_ns                       = adres_r;
        veri_sayisi_ns                 = veri_sayisi_r;
        yaz_veri_ns                    = yaz_veri_r;
        iomem_valid_ns                 = iomem_valid_r;
        wr_strb_ns                     = wr_strb_r;
        anabellek_musait_ns            = anabellek_musait_r;
        asama_ns                       = asama_r;
        getir_asamasina_veri_hazir_ns  = 1'b0;
        bellek_asamasina_veri_hazir_ns = 1'b0;
        
            case(durum)
                MUSAIT: begin
                    iomem_valid_ns      = 1'b0;
                    anabellek_musait_ns = 1'b1;
                    if(vbellek_istek_i)begin
                        asama_ns = BELLEK;
                        if(vbellek_oku_i)begin
                            adres_ns            = vbellek_adres_i;
                            iomem_valid_ns      = 1;
                            wr_strb_ns          = 4'b0000;
                            anabellek_musait_ns = 1'b0;
                            durum_next          = OKU;
                        end
                        else if(vbellek_yaz_i)begin
                            adres_ns            = vbellek_adres_i;
                            wr_strb_ns          = 4'b1111;
                            yaz_veri_ns         = yazilacak_veri_obegi_i[31:0];
                            iomem_valid_ns      = 1;
                            anabellek_musait_ns = 1'b0;
                            durum_next          = YAZ;
                        end
                    end
                    else if(bbellek_istek_i)begin
                        asama_ns = GETIR;
                        if(bbellek_oku_i)begin
                            adres_ns            = bbellek_adres_i;
                            iomem_valid_ns      = 1;
                            wr_strb_ns          = 4'b0000;
                            anabellek_musait_ns = 1'b0;
                            durum_next          = OKU;
                        end
                    end
                    
                end
                YAZ: begin
                    if(iomem_ready_i) begin 
                         veri_sayisi_ns = veri_sayisi_r + 1;
                         wr_strb_ns     = 4'b1111;
                         iomem_valid_ns = 1'b1;
                         
                         if(veri_sayisi_r == 3'd0)begin
                            yaz_veri_ns = yazilacak_veri_obegi_i[63:32];
                            adres_ns    = adres_r + 4;
                         end
                         else if(veri_sayisi_r == 3'd1) begin
                            yaz_veri_ns = yazilacak_veri_obegi_i[95:64];
                            adres_ns    = adres_r + 4;
                         end
                         else if(veri_sayisi_r == 3'd2) begin
                            yaz_veri_ns = yazilacak_veri_obegi_i[127:96];
                            adres_ns    = adres_r + 4;
                         end
                         else if(veri_sayisi_r == 3'd3)begin
                            veri_sayisi_ns      = 0;
                            iomem_valid_ns      = 0; 
                            anabellek_musait_ns = 1'b1;
                            adres_ns            = 32'd0;
                            bellek_asamasina_veri_hazir_ns = 1'b1; 
                            durum_next          = MUSAIT;
                         end
                    end
                end
                OKU : begin
                    if(iomem_ready_i)begin
                         veri_sayisi_ns               = veri_sayisi_r + 1;
                         okunan_veri_obegi_ns         = okunan_veri_obegi_r >> 6'd32;
                         okunan_veri_obegi_ns[127:96] = anabellekten_veri_i;
                         if((veri_sayisi_r == 3'd3) || ((asama_r == BELLEK) && (adres_r == 32'h3000_0000 || adres_r == 32'h3000_0004)))begin
                            veri_sayisi_ns             = 0;
                            iomem_valid_ns             = 0;
                            anabellek_musait_ns        = 1'b1;
                            if(asama_r == BELLEK) begin
                               bellek_asamasina_veri_hazir_ns = 1'b1; 
                            end
                            else begin
                               getir_asamasina_veri_hazir_ns  = 1'b1; 
                            end
                            durum_next                 = MUSAIT;
                         end
                         else begin 
                         iomem_valid_ns = 1; 
                         adres_ns       = adres_r + 4'b0100;
                         wr_strb_ns     = 4'b0000;
                         end
                         
                    end
                end
            endcase
    end

    always @(posedge clk_i) begin
        if(!rst_i) begin
            durum                     <= MUSAIT;
            
            veri_sayisi_r             <= 3'd0  ;
            okunan_veri_obegi_r       <= 128'd0;
            adres_r                   <= 32'd0 ;
            yaz_veri_r                <= 32'd0 ;
            wr_strb_r                 <= 4'd0  ; 
            iomem_valid_r             <= 1'b0  ;
            anabellek_musait_r        <= 1'b0  ; //DEGISTIRME: bu sinyal 1 oldugunda rst durumunda buyruk onb denetleyiciden cikan anabellek istek sinyali 1 oluyor, rst bittiginde anabellek musait o 0 oluyor(ama 1 olmali) 
            asama_r                   <= 1'b0  ;
            getir_asamasina_veri_hazir_r  <= 1'b0;
            bellek_asamasina_veri_hazir_r <= 1'b0;
        end
        else  begin
            durum                         <= durum_next          ;
            anabellek_musait_r            <= anabellek_musait_ns ;
            okunan_veri_obegi_r           <= okunan_veri_obegi_ns;
            adres_r                       <= adres_ns            ;
            veri_sayisi_r                 <= veri_sayisi_ns      ;
            yaz_veri_r                    <= yaz_veri_ns         ;
            iomem_valid_r                 <= iomem_valid_ns      ;
            wr_strb_r                     <= wr_strb_ns          ;
            asama_r                       <= asama_ns            ;
            getir_asamasina_veri_hazir_r  <= getir_asamasina_veri_hazir_ns ;
            bellek_asamasina_veri_hazir_r <= bellek_asamasina_veri_hazir_ns;
        end
    
    end
    
    assign okunan_veri_obegi_o           = okunan_veri_obegi_r;
    assign adres_o                       = adres_r; 
    assign yaz_veri_o                    = yaz_veri_r;
    assign wr_strb_o                     = wr_strb_r;
    assign iomem_valid_o                 = iomem_valid_r;
    assign anabellek_musait_o            = anabellek_musait_r;
    assign bellek_asamasina_veri_hazir_o = bellek_asamasina_veri_hazir_r;
    assign getir_asamasina_veri_hazir_o  = getir_asamasina_veri_hazir_r;
    
endmodule