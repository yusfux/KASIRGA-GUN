`timescale 1ns / 1ps

module wrapper_bellek (
        input clk_i,
        input rst_i,

        // yurutten gelen sinyaller
        input [31:0] hedef_yazmac_verisi_i,
        input        yazmaca_yaz_i,
        input [4:0]  hedef_yazmaci_i,

        input [31:0] bellek_adresi_i,
        input [31:0] bellek_veri_i,
        input [2:0]  load_save_buyrugu_i,
        input        bellekten_oku_i,
        input        bellege_yaz_i,

        // giris cikistan gelen sinyaller
        input [31:0] gc_okunan_veri_i,
        input        gc_veri_gecerli_i,
        input        gc_stall_i,

        // bellek asamasindan gelen sinyaller
        input [31:0] vbellek_veri_i,
        input        vbellek_veri_hazir_i,
        input        vbellek_denetim_hazir_i,

        // bellek asamasina gidecek sinyaller
        output        vbellek_onbellekten_oku_o,
        output        vbellek_onbellege_yaz_o,
        output [31:0] vbellek_adres_o,
        output [31:0] vbellek_veri_o,
        output [2:0]  vbellek_buyruk_turu_o,

        // geri yaz asmasina gidecek sinyaller
        output [31:0] hedef_yazmac_verisi_o,
        output        yazmaca_yaz_o,
        output        bellekten_oku_o,
        output [4:0]  hedef_yazmaci_o,
        output        bellek_veri_hazir_o,
        output [31:0] bellek_veri_o,
        output [31:0] gc_okunan_veri_o,
        output        gc_veri_gecerli_o,


        // giris_cikisa gidecek sinyaller
        output giris_cikis_aktif_o,

        // boru hatti denetleyiciye verilecek sinyaller
        output timer_o,
        output durdur_o,

        output [4:0]  hedef_yazmaci_vy,
        output [31:0] hedef_yazmac_verisi_vy,
        output        yazmaca_yaz_vy

    );
    
    wire            bellege_yaz_w;
    wire            bellekten_oku_w;
    wire            giris_cikis_aktif_w;

    reg             bellek_veri_hazir_r;
	reg     [31:0]	bellek_veri_r;
    reg             bellekten_oku_r;

    
    wire            timer_w;
    assign          timer_o = timer_w;

   adres_duzenleyici adres_duz(
         .bellege_yaz_i(bellege_yaz_i),
         .bellekten_oku_i(bellekten_oku_i),
         .bellek_adresi30_28_i(bellek_adresi_i[30:28]), //bellek_adresi[30]
         .bellege_yaz_o(bellege_yaz_w),
         .bellekten_oku_o(bellekten_oku_w),
         .giris_cikis_aktif_o(giris_cikis_aktif_w),
         .timer_o(timer_w)
    );
    
    reg        yazmaca_yaz_r;
    reg [4:0]  hedef_yazmaci_r;
    reg [31:0] hedef_yazmac_verisi_r;

    always @(posedge clk_i) begin
        if(!rst_i) begin
            yazmaca_yaz_r         <= 1'b0;
            hedef_yazmaci_r       <= 5'd0;
            hedef_yazmac_verisi_r <= 32'd0;
        end
        else begin
		    if((!vbellek_denetim_hazir_i && (bellekten_oku_i || bellege_yaz_i) && !giris_cikis_aktif_w) || gc_stall_i)begin
                yazmaca_yaz_r         <= 1'b0;
            end
            else begin
                yazmaca_yaz_r         <= yazmaca_yaz_i;
                hedef_yazmaci_r       <= hedef_yazmaci_i;
                hedef_yazmac_verisi_r <= hedef_yazmac_verisi_i;     
                bellekten_oku_r       <= bellekten_oku_i;  
                bellek_veri_hazir_r   <= vbellek_veri_hazir_i;
                bellek_veri_r         <= vbellek_veri_i;
            end
        end
    end
    
    
    //giris cikisa gidecek sinyaller
    assign giris_cikis_aktif_o = giris_cikis_aktif_w;

    //veri bellek denetleyiciye gidecek sinyaller
    assign vbellek_onbellekten_oku_o = bellekten_oku_w;
    assign vbellek_onbellege_yaz_o   = bellege_yaz_w;
    assign vbellek_adres_o           = bellek_adresi_i;
    assign vbellek_buyruk_turu_o     = load_save_buyrugu_i;
    assign vbellek_veri_o            = bellek_veri_i;

    //geriyaz asamasina gidecek sinyaller
    assign yazmaca_yaz_o          = yazmaca_yaz_r;
    assign hedef_yazmaci_o        = hedef_yazmaci_r;
    assign hedef_yazmac_verisi_o  = hedef_yazmac_verisi_r;
    assign bellekten_oku_o        = bellekten_oku_r;
    assign bellek_veri_hazir_o    = bellek_veri_hazir_r;
    assign bellek_veri_o          = bellek_veri_r;	

    assign gc_okunan_veri_o       = gc_okunan_veri_i;
    assign gc_veri_gecerli_o      = gc_veri_gecerli_i;
    
	assign durdur_o = (~vbellek_denetim_hazir_i && (bellekten_oku_w || bellege_yaz_w)) || gc_stall_i;

    //------------------------------------------------------
    //------------------------------------------------------
    //------------------------------------------------------
    assign hedef_yazmaci_vy       = hedef_yazmaci_i;
    assign hedef_yazmac_verisi_vy = (vbellek_veri_hazir_i && bellekten_oku_w) ? vbellek_veri_i :  hedef_yazmac_verisi_i;
    assign yazmaca_yaz_vy         = !giris_cikis_aktif_w && yazmaca_yaz_i;

endmodule
