module buyruk_onbellegi_denetleyicisi(
    input clk                           ,
    input rst                           ,// active high reset
    input [31:0] adres_g                ,      //anabellege iletilecek adres-psden alinir
    input        onbellek_veri_bulundu_g, 
    input        onbellek_bitti_g       ,      //onbellekte islem tamamlandi
    input [31:0] onbellek_veri_g        ,
    input        anabellek_hazir_g      ,     // anabellek verisi hazir
    input [31:0] anabellek_veri_g       ,
    output[31:0] anabellek_adres_c      , //anabellege verilen adres
    output       anabellek_istek_c      ,
    output[31:0] veri_c                 ,  //on cozucuye iletilir
    output       veri_hazir_c
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
    
    assign anabellek_adres_c = anabellek_adres_r;
    assign anabellek_istek_c = anabellek_istek_r;
    assign veri_c            = veri_r           ;
    assign veri_hazir_c      = veri_hazir_r     ;
    
    always @(posedge clk) begin
        if(rst)begin
        durum             <= 1'b0;
        veri_hazir_r      <= 1'b0;
        veri_r            <= 1'b0;
        anabellek_istek_r <= 1'b0;
        anabellek_adres_r <= 1'b0;
        end
        else begin
        durum             <= durum_next        ;
        veri_hazir_r      <= veri_hazir_ns     ;
        veri_r            <= veri_ns           ;
        anabellek_istek_r <= anabellek_istek_ns;
        anabellek_adres_r <= anabellek_adres_ns; 
        end
    
    end

    always @(*) begin
        durum_next = durum;
        veri_hazir_ns = 1'b0;
        anabellek_adres_ns = anabellek_adres_r;
        veri_ns            = veri_r;
        anabellek_istek_ns = anabellek_istek_r;
        
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
                        anabellek_adres_ns = adres_g;// anabellege istek sinyali ayr?ca eklenebilir
                        anabellek_istek_ns = 1'b1;// anabellek sadece bu sinyal 1 oldugundaa istenilen adrese bakar
                        durum_next      = ANABELLEK;
                    end

                end  
                  
            end
            ANABELLEK : begin
                if(anabellek_hazir_g) begin
                    veri_ns             = anabellek_veri_g;
                    veri_hazir_ns       = 1'b1            ;
                    anabellek_istek_ns  = 1'b0            ;         
                    durum_next          = ONBELLEK        ;
                end
            end

        endcase
    end
    
endmodule