`timescale 1ns / 1ps

module axi4_lite_slave_spi(
     input              s_axi_aclk_i, 
     input              s_axi_aresetn_i,
     
     //         READ SIGNALS 
	 // ar -> address read (address in)
	 // r  -> read (data out)
     input   [31:0]     s_axi_araddr_i,  
     output             s_axi_arready_o,  
     input              s_axi_arvalid_i, 
     
     input              s_axi_rready_i,
     output             s_axi_rvalid_o,
     
	  output  [31:0]     s_axi_rdata_o,
	 //output             s_axi_rresp_o, 
     
     //         WRITE SIGNALS
	 // aw -> address write (address in)
 	 // w  -> write (data in)
	 // b  -> response 
	 
     input   [31:0]     s_axi_awaddr_i,
     output             s_axi_awready_o,
     input              s_axi_awvalid_i,
     
     input   [31:0]     s_axi_wdata_i,
     output             s_axi_wready_o,
     input   [3:0]      s_axi_wstrb_i,
     input              s_axi_wvalid_i,
     
     input              s_axi_bready_i,
     output             s_axi_bvalid_o,
     

     input   [3:0]      read_size_i,
     
     output             cs_o,
     output             sck_o,
     output             spi_mosi_o,
     input              spi_miso_i
    );
    
   wire [4:0] adres_bit_w;
   wire       islem_w;
   wire       islem_gecerli_w; 
   wire [1:0] read_type_w;
   wire [1:0] write_type_w;
   wire       islem_bitti_w;
    
    axi_interface_spi spi_connection(
      .s_axi_aclk_i(s_axi_aclk_i),
	   .s_axi_aresetn_i(s_axi_aresetn_i),
      .s_axi_araddr_i(s_axi_araddr_i),  
      .s_axi_arready_o(s_axi_arready_o),  
      .s_axi_arvalid_i(s_axi_arvalid_i), 
      .s_axi_rready_i(s_axi_rready_i),
      .s_axi_rvalid_o(s_axi_rvalid_o),
	   .s_axi_awaddr_i(s_axi_awaddr_i),
      .s_axi_awready_o(s_axi_awready_o),
      .s_axi_awvalid_i(s_axi_awvalid_i),
      .s_axi_wready_o(s_axi_wready_o),
      .s_axi_wstrb_i(s_axi_wstrb_i),
      .s_axi_wvalid_i(s_axi_wvalid_i),
      .s_axi_bready_i(s_axi_bready_i),
      .s_axi_bvalid_o(s_axi_bvalid_o),
	   .read_size_i(read_size_i),  
	 	.adres_bit_o(adres_bit_w), 
	   .islem_o(islem_w), 
	 	.islem_gecerli_o(islem_gecerli_w), 
	   .read_type_o(read_type_w), 
	   .write_type_o(write_type_w),
	   .islem_bitti_i(islem_bitti_w)
    );  
    
    
    spi spi(
      .clk_i(axi_aclk_i),
      .rst_i(axi_aresetn_i),
      .adres_bit_i(adres_bit_w),
      .islem_i(islem_w),
      .islem_gecerli_i(islem_gecerli_w),
      .read_type_i(read_type_w),
      .write_type_i(write_type_w),
      .veri_i(s_axi_wdata_i),
      .islem_bitti_o(islem_bitti_w),
      .veri_o(s_axi_rdata_o),
      .cs_o(cs_o),
      .sck_o(sck_o),
      .spi_mosi_o(spi_mosi_o),
      .spi_miso_i(spi_miso_i)
    );
    
    
endmodule
