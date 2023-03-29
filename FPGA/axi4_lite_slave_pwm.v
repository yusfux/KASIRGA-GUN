`timescale 1ns / 1ps

module axi4_lite_slave_pwm(
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
     
     input              s_axi_bready_i,
     output             s_axi_bvalid_o,
 
     output             pwm1_o,
     output             pwm2_o,
     input   [3:0]      read_size_i
    );
    
  // PWM
   wire  [1:0]  pwm1_mode_w;
   wire  [31:0] pwm1_period_w;
   wire  [31:0] pwm1_threshold1_w;
   wire  [31:0] pwm1_threshold2_w;
   wire  [11:0] pwm1_step_w;
   
   wire  [1:0]  pwm2_mode_w;
   wire  [31:0] pwm2_period_w;
   wire  [31:0] pwm2_threshold1_w;
   wire  [31:0] pwm2_threshold2_w;
   wire  [11:0] pwm2_step_w;
   
   wire  pwm1_w;
   wire  pwm2_w;

   assign pwm1_o = pwm1_w;
   assign pwm2_o = pwm2_w;
    
     axi_interface_pwm axi_connection(
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
 
        .pwm1_mode_o(pwm1_mode_w),
        .pwm1_period_o(pwm1_period_w),
        .pwm1_threshold1_o(pwm1_threshold1_w),
        .pwm1_threshold2_o(pwm1_threshold2_w),
        .pwm1_step_o(pwm1_step_w),
        .pwm1_i(pwm1_w),
	    
        .pwm2_mode_o(pwm2_mode_w),
        .pwm2_period_o(pwm2_period_w),
        .pwm2_threshold1_o(pwm2_threshold1_w),
        .pwm2_threshold2_o(pwm2_threshold2_w),
        .pwm2_step_o(pwm2_step_w),
        .pwm2_i(pwm2_w)
    );
    
    pwm1 pwm_connection1(
        .clk_i(s_axi_aclk_i),
        .rst_i(s_axi_aresetn_i),
        .pwm1_mode_i(pwm1_mode_w),
        .pwm1_period_i(pwm1_period_w),
        .pwm1_threshold1_i(pwm1_threshold1_w),
        .pwm1_threshold2_i(pwm1_threshold2_w),
        .pwm1_step_i(pwm1_step_w),
        .pwm1_o(pwm1_w)
	); 
	
	pwm2 pwm_connection2(
        .clk_i(s_axi_aclk_i),
        .rst_i(s_axi_aresetn_i),
        .pwm2_mode_i(pwm2_mode_w),
        .pwm2_period_i(pwm2_period_w),
        .pwm2_threshold1_i(pwm2_threshold1_w),
        .pwm2_threshold2_i(pwm2_threshold2_w),
        .pwm2_step_i(pwm2_step_w),
        .pwm2_o(pwm2_w)
	);
	
	
endmodule
