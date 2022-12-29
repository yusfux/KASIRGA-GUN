module buyruk_onbellegi_denetleyicisi(
    input          clk                    ,
    input          rst                    ,// active low reset
    input  [31:0]  adres_g                ,//anabellege iletilecek adres-psden alinir
    input          onbellek_veri_bulundu_g, 
    input          onbellek_bitti_g       ,//onbellekte islem tamamlandi
    input  [31:0]  onbellek_veri_g        ,
    input          anabellek_gecerli_obek_g,//** anabellekten gelen veri hazir
    input  [127:0] anabellek_obek_g       , //**
    output [127:0] onbellek_obek_c        , 
    output         onbellege_obegi_yaz_c  ,
    output [31:0]  anabellek_adres_c      , //anabellege verilen adres
    output         anabellek_istek_c      , // anabellekten veri(buyruk) obegi almak icin anabellege yapilan istek
    output [31:0]  veri_c                 ,  //on cozucuye iletilir
    output         veri_hazir_c              //denetleyici buyrugu hazirladi
);
    localparam ONBELLEK  = 1'b0;
    localparam ANABELLEK = 1'b1;

    reg durum          = ONBELLEK;//**bu sorun cikarir mi? rst gerekir mi?
    reg durum_next               ;
    reg veri_hazir_r             ;
    reg veri_hazir_ns            ;
    reg [31:0] veri_r            ;
    reg [31:0] veri_ns           ;
    reg anabellek_istek_r        ;
    reg anabellek_istek_ns       ;
    reg [31:0] anabellek_adres_r ;
    reg [31:0] anabellek_adres_ns;
    reg [127:0] onbellek_obek_r  ;
    reg [127:0] onbellek_obek_ns ;
    reg         onbellege_obegi_yaz_r;
    reg         onbellege_obegi_yaz_ns;   
    reg [1:0] veri_araligi; // 00 01 10 11
    
    assign anabellek_adres_c = anabellek_adres_r;
    assign anabellek_istek_c = anabellek_istek_r;
    assign veri_c            = veri_r           ;
    assign veri_hazir_c      = veri_hazir_r     ;
    assign onbellek_obek_c   = onbellek_obek_r  ;
    assign onbellege_obegi_yaz_c = onbellege_obegi_yaz_r;
    
    always @(posedge clk) begin
        if(rst)begin
        durum             <= durum_next        ;
        veri_hazir_r      <= veri_hazir_ns     ;
        veri_r            <= veri_ns           ;
        anabellek_istek_r <= anabellek_istek_ns;
        anabellek_adres_r <= anabellek_adres_ns; 
        onbellek_obek_r   <= onbellek_obek_ns  ;
        onbellege_obegi_yaz_r <= onbellege_obegi_yaz_ns;
        end
        else begin
        durum             <= 0              ;
        veri_hazir_r      <= 0              ;
        veri_r            <= 0              ;
        anabellek_istek_r <= 0              ;
        anabellek_adres_r     <= 0          ;
        onbellek_obek_r       <= 0          ;
        onbellege_obegi_yaz_r <= 0          ; 
        end
    
    end

    always @(*) begin
        durum_next         = durum            ;
        veri_hazir_ns      = 1'b0             ;
        anabellek_adres_ns = anabellek_adres_r;
        veri_ns            = veri_r           ;
        anabellek_istek_ns = anabellek_istek_r;
        onbellek_obek_ns   = onbellek_obek_r  ;
        onbellege_obegi_yaz_ns = 1'b0;
        case (durum)
            ONBELLEK : begin
                if(onbellek_bitti_g) begin
                    if(onbellek_veri_bulundu_g) begin
                        veri_ns            = onbellek_veri_g;
                        veri_hazir_ns      = 1'b1;
                        anabellek_istek_ns = 1'b0;
                        durum_next      = ONBELLEK;
                    end
                    else begin              
                        veri_araligi = adres_g[3:2];            
                        anabellek_adres_ns = {adres_g[31:4], 4'b0000};// anabellege istek sinyali ayr?ca eklenebilir
                        anabellek_istek_ns = 1'b1;// anabellek sadece bu sinyal 1 oldugundaa istenilen adrese bakar
                        durum_next      = ANABELLEK;
                    end

                end  
                  
            end
            ANABELLEK : begin
                if(anabellek_gecerli_obek_g) begin
                    if(veri_araligi == 2'b00)begin
                        veri_ns = anabellek_obek_g[31:0];
                    end
                    else if(veri_araligi == 2'b01)begin
                        veri_ns = anabellek_obek_g[63:32];
                    end
                    else if(veri_araligi == 2'b10)begin
                        veri_ns = anabellek_obek_g[95:64];
                    end
                    else if(veri_araligi == 2'b11)begin
                        veri_ns = anabellek_obek_g[127:96];
                    end
                    veri_hazir_ns       = 1'b1            ;
                    anabellek_istek_ns  = 1'b0            ;         
                    onbellek_obek_ns    = anabellek_obek_g;
                    onbellege_obegi_yaz_ns = 1'b1         ;
                    durum_next          = ONBELLEK        ;
                end
            end

        endcase
    end
    
endmodule