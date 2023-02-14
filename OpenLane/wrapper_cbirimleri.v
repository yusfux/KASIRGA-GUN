`timescale 1ns / 1ps 

module wrapper_cbirimleri (

    );

    Uart uart_connection (
        .r_done_o(),
        .rx_en_i(),
        .t_done_o(),
        .tx_en_i(),
        .baud_div_i(),
        
        .clk_i(),
        .rst_i(),
        
        .t_in_i(),
        .r_out_o(),
        .tx_o(),
        .rx_i()     
	);

    pwm1 pwm_connection1 (
        .clk_i(),
        .rst_i(),
        .pwm1_mode_i(),
        .pwm1_period_i(),
	    .pwm1_threshold1_i(),
	    .pwm1_threshold2_i(),
	    .pwm1_step_i(),
	    .pwm1_o()
	); 
	
	pwm2 pwm_connection2 (
        .clk_i(),
        .rst_i(),
        .pwm2_mode_i(),
        .pwm2_period_i(),
	    .pwm2_threshold1_i(),
	    .pwm2_threshold2_i(),
	    .pwm2_step_i(),
	    .pwm2_o()
	);

endmodule