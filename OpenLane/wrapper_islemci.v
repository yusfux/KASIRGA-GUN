`timescale 1ns / 1ps

module wrapper_islemci (
        input clk   ,
        input resetn,

        input        iomem_ready,
        input [31:0] iomem_rdata,

        input spi_miso_i,
        input uart_rx_i ,

        output        iomem_valid,
        output [3:0]  iomem_wstrb,
        output [31:0] iomem_addr ,
        output [31:0] iomem_wdata,

        output spi_cs_o  ,
        output spi_sck_o ,
        output spi_mosi_o,
        output uart_tx_o ,
        output pwm0_o    ,
        output pwm1_o
    );

    // 
    wire        iomem_valid_w;
    wire [3:0]  iomem_wstrb_w;
    wire [31:0] iomem_addr_w;
    wire [31:0] iomem_wdata_w;

    wire spi_cs_w;
    wire spi_sck_w;
    wire spi_mosi_w;
    wire uart_tx_w;
    wire pwm0_w;
    wire pwm1_w;

    // getir <-> buyruk bellek
    wire [31:0] buyruk_adres_w;
    wire        bbellek_durdur_w;
    wire [31:0] buyruk_w;
    wire        buyruk_hazir_w;

    // bellek <-> veri bellek
    wire [31:0] vbellek_veri_w;
    wire        vbellek_veri_hazir_w;
    wire        vbellek_denetim_hazir_w;
    wire        vbellek_onbellekten_oku_w;
    wire        vbellek_onbellege_yaz_w;
    wire [31:0] vbellek_adres_w;
    wire [31:0] vbellek_veri_o_w;
    wire [2:0]  vbellek_buyruk_turu_w;

    // bellek <-> axi
    wire [31:0] gc_okunan_veri_w;
    wire        gc_veri_gecerli_w;
    wire        gc_stall_w;
    wire        giris_cikis_aktif_w;

    // buyruk bellek <-> anabellek 
    wire [31:0] bbellek_anabellek_adres_w;
    wire        bbellek_anabellek_istek_w;
    wire        bbellek_anabellek_oku_w;

    // veri bellek <-> anabellek
    wire         anabellek_yaz_w;
    wire         vbellek_anabellek_oku_w;
    wire         vbellek_anabellek_istek_w;
    wire [31:0]  vbellek_anabellek_adres_w;
    wire [127:0] anabellek_kirli_obek_w;

    // anabellek <-> veri & buyruk bellekleri
    wire         anabellek_musait_w;
    wire [127:0] okunan_veri_obegi_w;
    wire         bellek_asamasina_veri_hazir_w;
    wire         getir_asamasina_veri_hazir_w;

    wrapper_cekirdek cekirdek         (
        .clk_i(clk),
        .rst_i(resetn),

        .buyruk_i(buyruk_w),
        .buyruk_hazir_i(buyruk_hazir_w),
        .buyruk_adres_o(buyruk_adres_w),
        .bbellek_durdur_o(bbellek_durdur_w),

        .vbellek_veri_i(vbellek_veri_o_w),
        .vbellek_veri_hazir_i(vbellek_veri_hazir_w),
        .vbellek_denetim_hazir_i(vbellek_denetim_hazir_w),
        .vbellek_onbellekten_oku_o(vbellek_onbellekten_oku_w),
        .vbellek_onbellege_yaz_o(vbellek_onbellege_yaz_w),
        .vbellek_adres_o(vbellek_adres_w),
        .vbellek_veri_o(vbellek_veri_w),
        .vbellek_buyruk_turu_o(vbellek_buyruk_turu_w),

        .gc_okunan_veri_i(gc_okunan_veri_w),
        .gc_veri_gecerli_i(gc_veri_gecerli_w),
        .gc_stall_i(gc_stall_w),
        .giris_cikis_aktif_o(giris_cikis_aktif_w)
    );

    wrapper_bbellek buyruk_onbellek   (
        .clk_i(clk),
        .rst_i(resetn),

        .adres_i(buyruk_adres_w),
        .durdur_i(bbellek_durdur_w),
    
        .anabellek_musait_i(anabellek_musait_w),
        .anabellek_hazir_i(getir_asamasina_veri_hazir_w),
        .anabellek_obek_i(okunan_veri_obegi_w),
    
        .anabellek_adres_o(bbellek_anabellek_adres_w),
        .anabellek_istek_o(bbellek_anabellek_istek_w),
        .anabellek_oku_o(bbellek_anabellek_oku_w),
    
        .buyruk_o(buyruk_w),
        .buyruk_hazir_o(buyruk_hazir_w)
    );

    wrapper_vbellek veri_onbellek     (
        .clk_i(clk),
        .rst_i(resetn),

        .onbellekten_oku_i(vbellek_onbellekten_oku_w),
        .onbellege_yaz_i(vbellek_onbellege_yaz_w),
        .adres_i(vbellek_adres_w),
        .veri_i(vbellek_veri_w),
        .buyruk_turu_i(vbellek_buyruk_turu_w),

        .anabellek_musait_i(anabellek_musait_w),
        .anabellek_hazir_i(bellek_asamasina_veri_hazir_w),
        .anabellek_obek_i(okunan_veri_obegi_w),

        .anabellek_yaz_o(anabellek_yaz_w),
        .anabellek_oku_o(vbellek_anabellek_oku_w),
        .anabellek_istek_o(vbellek_anabellek_istek_w), 
        .anabellek_adres_o(vbellek_anabellek_adres_w),
        .anabellek_kirli_obek_o(anabellek_kirli_obek_w),
        
        .veri_o(vbellek_veri_o_w),
        .veri_hazir_o(vbellek_veri_hazir_w),
        .denetim_hazir_o(vbellek_denetim_hazir_w)
    );

    wrapper_abellek anabellek         (
        .clk_i(clk),
        .rst_i(resetn),

        .bbellek_adres_i(bbellek_anabellek_adres_w),
        .bbellek_istek_i(bbellek_anabellek_istek_w),
        .bbellek_oku_i(bbellek_anabellek_oku_w),

        .vbellek_yaz_i(anabellek_yaz_w),
        .vbellek_oku_i(vbellek_anabellek_oku_w),
        .vbellek_istek_i(vbellek_anabellek_istek_w),
        .vbellek_adres_i(vbellek_anabellek_adres_w),
        .yazilacak_veri_obegi_i(anabellek_kirli_obek_w),

        .iomem_ready_i(iomem_ready),
        .anabellekten_veri_i(iomem_rdata),

        .adres_o(iomem_addr_w),
        .yaz_veri_o(iomem_wdata_w),
        .iomem_valid_o(iomem_valid_w),
        .wr_strb_o(iomem_wstrb_w),
        
        .anabellek_musait_o(anabellek_musait_w),
        .okunan_veri_obegi_o(okunan_veri_obegi_w),
        .bellek_asamasina_veri_hazir_o(bellek_asamasina_veri_hazir_w),
        .getir_asamasina_veri_hazir_o(getir_asamasina_veri_hazir_w)
    );

    wrapper_axi axi                   (
        .axi_aclk_i(clk),
        .axi_aresetn_i(resetn),

        .rx_i(uart_rx_i),
        .giris_cikis_aktif_i(giris_cikis_aktif_w),
        .address_i(vbellek_adres_w),
        .buyruk_turu_i(vbellek_buyruk_turu_w),
        .data_i(vbellek_veri_w),

        .tx_o(uart_tx_w),
        .pwm1_o(pwm0_w),
        .pwm2_o(pwm1_w),
        .okunan_veri_o(gc_okunan_veri_w),
        .okunan_gecerli_o(gc_veri_gecerli_w),
        .stall_o(gc_stall_w)
    );

    /*
    wrapper_cbirimleri cevre_birimleri (

    );
    */

    assign iomem_valid = iomem_valid_w;
    assign iomem_wstrb = iomem_wstrb_w;
    assign iomem_addr  = iomem_addr_w;
    assign iomem_wdata = iomem_wdata_w;

    assign spi_cs_o   = spi_cs_w;
    assign spi_sck_o  = spi_sck_w;
    assign spi_mosi_o = spi_mosi_w;
    assign uart_tx_o  = uart_tx_w;
    assign pwm0_o     = pwm0_w;
    assign pwm1_o     = pwm1_w;

endmodule