`timescale 1ns / 1ps 

module wrapper_axi (
        input        axi_aclk_i,
        input        axi_aresetn_i,

        input        rx_i,
        input        giris_cikis_aktif_i,
        input [31:0] address_i,     // vbellek_adres_o
        input [2:0]  buyruk_turu_i, //vbellek_buyruk_turu_o
        input [31:0] data_i,        //vbellek_veri_o

        output        tx_o,
        output        pwm1_o,
        output        pwm2_o,
        output [31:0] okunan_veri_o,    //gc_okunan_veri_i
        output        okunan_gecerli_o,
        output        stall_o,
    );

    wire [31:0] axi_araddr_w; 
    wire        axi_arready_w;  
    wire        axi_arvalid_w;
    wire        axi_rready_w;
    wire        axi_rvalid_w;
	wire [31:0] axi_rdata_w; 
    wire [31:0] axi_awaddr_w;
    wire        axi_awready_w;
    wire        axi_awvalid_w;
    wire [31:0] axi_wdata_w;
    wire        axi_wready_w;
    wire [3:0]  axi_wstrb_w;
    wire        axi_wvalid_w;
    wire        axi_bready_w;
    wire        axi_bvalid_w; 
    wire [3:0]  read_size_w;
    
    wire        s_axi_arready_o_uart;
	wire        s_axi_rvalid_o_uart;
	wire [31:0] s_axi_rdata_o_uart;
	wire        s_axi_rresp_o_uart;
	wire        s_axi_awready_o_uart;
	wire        s_axi_wready_o_uart;
	wire        s_axi_bvalid_o_uart;
	wire        s_axi_bresp_o_uart;
	
    wire        s_axi_arready_o_pwm;
    wire        s_axi_rvalid_o_pwm;
    wire [31:0] s_axi_rdata_o_pwm;
    wire        s_axi_rresp_o_pwm;
    wire        s_axi_awready_o_pwm;
    wire        s_axi_wready_o_pwm;
    wire        s_axi_bvalid_o_pwm;
    wire        s_axi_bresp_o_pwm;
     
     assign axi_arready_w    = s_axi_arready_o_uart ||  s_axi_arready_o_pwm;
     assign axi_rvalid_w     = s_axi_rvalid_o_uart  ^   s_axi_rvalid_o_pwm;
     assign axi_rdata_w      = s_axi_rvalid_o_uart  ?   s_axi_rdata_o_uart : s_axi_rvalid_o_pwm ? s_axi_rdata_o_pwm : 32'd0;
     assign axi_awready_w    = s_axi_awready_o_uart ||  s_axi_awready_o_pwm;
     assign axi_wready_w     = s_axi_wready_o_uart  ||  s_axi_wready_o_pwm;
     assign axi_bvalid_w     = s_axi_bvalid_o_uart  ^   s_axi_bvalid_o_pwm;
     
    
     axi_master axi_m(
        .axi_aclk_i(axi_aclk_i),
        .axi_aresetn_i(axi_aresetn_i),
        .axi_araddr_o(axi_araddr_w), 
        .axi_arready_i(axi_arready_w),
        .axi_arvalid_o(axi_arvalid_w),
        .axi_rready_o(axi_rready_w), 
        .axi_rvalid_i(axi_rvalid_w),
        .axi_rdata_i(axi_rdata_w),
        .axi_awaddr_o(axi_awaddr_w),
        .axi_awready_i(axi_awready_w),
        .axi_awvalid_o(axi_awvalid_w),
        .axi_wdata_o(axi_wdata_w),
        .axi_wready_i(axi_wready_w),
        .axi_wstrb_o(axi_wstrb_w),
        .axi_wvalid_o(axi_wvalid_w),
        .axi_bready_o(axi_bready_w),
        .axi_bvalid_i(axi_bvalid_w),
        
        .address_i(address_i),
	    .buyruk_turu_i(buyruk_turu_i),
	    .okunan_veri_o(okunan_veri_o),
	    .data_i(data_i),
	    .read_size_o(read_size_w),
	    .okunan_veri_gecerli_o(okunan_gecerli_o),
	     
	    .giris_cikis_aktif_i(giris_cikis_aktif_i)
    );
    
    
    axi4_lite_slave_uart axi_s_uart(
        .s_axi_aclk_i(axi_aclk_i), 
        .s_axi_aresetn_i(axi_aresetn_i),
        .s_axi_araddr_i(axi_araddr_w),  
        .s_axi_arready_o(s_axi_arready_o_uart),  
        .s_axi_arvalid_i(axi_arvalid_w), 
        .s_axi_rready_i(axi_rready_w),
        .s_axi_rvalid_o(s_axi_rvalid_o_uart),
        .s_axi_rdata_o(s_axi_rdata_o_uart), 
        .s_axi_awaddr_i(axi_awaddr_w),
        .s_axi_awready_o(s_axi_awready_o_uart),
        .s_axi_awvalid_i(axi_awvalid_w),
        .s_axi_wdata_i(axi_wdata_w),
        .s_axi_wready_o(s_axi_wready_o_uart),
        .s_axi_wstrb_i(axi_wstrb_w),
        .s_axi_wvalid_i(axi_wvalid_w),
        .s_axi_bready_i(axi_bready_w),
        .s_axi_bvalid_o(s_axi_bvalid_o_uart),
        .read_size_i(read_size_w),
         
        .tx_o(tx_o),
        .rx_i(rx_i),
        .stall_o(stall_o)
    );    
    
    
     axi4_lite_slave_pwm axi_s_pwm(
        .s_axi_aclk_i(axi_aclk_i), 
        .s_axi_aresetn_i(axi_aresetn_i),
        .s_axi_araddr_i(axi_araddr_w),  
        .s_axi_arready_o(s_axi_arready_o_pwm),  
        .s_axi_arvalid_i(axi_arvalid_w), 
        .s_axi_rready_i(axi_rready_w),
        .s_axi_rvalid_o(s_axi_rvalid_o_pwm),
        .s_axi_rdata_o(s_axi_rdata_o_pwm), 
        .s_axi_awaddr_i(axi_awaddr_w),
        .s_axi_awready_o(s_axi_awready_o_pwm),
        .s_axi_awvalid_i(axi_awvalid_w),
        .s_axi_wdata_i(axi_wdata_w),
        .s_axi_wready_o(s_axi_wready_o_pwm),
        .s_axi_wstrb_i(axi_wstrb_w),
        .s_axi_wvalid_i(axi_wvalid_w),
        .s_axi_bready_i(axi_bready_w),
        .s_axi_bvalid_o(s_axi_bvalid_o_pwm),
        .read_size_i(read_size_w),
               
        .pwm1_o(pwm1_o),
        .pwm2_o(pwm2_o)
    );    
    
endmodule
