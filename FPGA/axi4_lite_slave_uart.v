`timescale 1ns / 1ps

module axi4_lite_slave_uart(
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
     
	 // Bunlarý anlamadým
     input              s_axi_bready_i,
     output             s_axi_bvalid_o,
     input   [3:0]      read_size_i,
     
     output tx_o,
     input rx_i
     
    );

wire r_done_w;
wire rx_en_w;
wire t_done_w;
wire tx_en_w;
wire [15:0]baud_div_w;
	
wire [7:0] tx_w;
wire [7:0] rx_w;
	
    axi_interface_uart axi_connection(
        .s_axi_aclk_i(s_axi_aclk_i),
	.s_axi_aresetn_i(s_axi_aresetn_i),
	.s_axi_araddr_i(s_axi_araddr_i),  
        .s_axi_arready_o(s_axi_arready_o),  
        .s_axi_arvalid_i(s_axi_arvalid_i), 
        .s_axi_rready_i(s_axi_rready_i),
        .s_axi_rvalid_o(s_axi_rvalid_o),
	.s_axi_rdata_o(s_axi_rdata_o),
	.s_axi_awaddr_i(s_axi_awaddr_i),
        .s_axi_awready_o(s_axi_awready_o),
        .s_axi_awvalid_i(s_axi_awvalid_i),
        .s_axi_wdata_i(s_axi_wdata_i),
        .s_axi_wready_o(s_axi_wready_o),
        .s_axi_wstrb_i(s_axi_wstrb_i),
        .s_axi_wvalid_i(s_axi_wvalid_i),
        .s_axi_bready_i(s_axi_bready_i),
        .s_axi_bvalid_o(s_axi_bvalid_o),
	.read_size_i(read_size_i),	
	.r_done_i(r_done_w),
	.t_done_i(t_done_w),
	.baud_div_o(baud_div_w),
	.tx_en_o(tx_en_w),
	.rx_en_o(rx_en_w),
	.tx_o(tx_w),
	.rx_i(rx_w)	
    );
    

    Uart uart_connection(
	.clk_i(s_axi_aclk_i),
        .rst_i(s_axi_aresetn_i),
        .r_done_o(r_done_w),
        .rx_en_i(rx_en_w),
        .t_done_o(t_done_w),
        .tx_en_i(tx_en_w),
        .baud_div_i(baud_div_w),
        .t_in_i(tx_w),
        .r_out_o(rx_w),
        .tx_o(tx_o),
        .rx_i(rx_i)     
	);
	
	
endmodule
