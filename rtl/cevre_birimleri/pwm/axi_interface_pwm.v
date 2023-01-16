`timescale 1ns / 1ps

module axi_interface_pwm(
     input              s_axi_aclk_i, 
     input              s_axi_aresetn_i,
     
     //         READ SIGNALS 
	 // ar -> address read (address in)
	 // r  -> read (data out)
     input   [31:0]     s_axi_araddr_i,  
     output             s_axi_arready_o,  
     input              s_axi_arvalid_i, 
     //input              s_axi_arprot_i, // kullanmadim
     
     input              s_axi_rready_i,
     output             s_axi_rvalid_o,
     
	 output [31:0]      s_axi_rdata_o, 
	 output             s_axi_rresp_o, // 1 gecerli, 0 gecersiz
     
     //         WRITE SIGNALS
	 // aw -> address write (address in)
 	 // w  -> write (data in)
	 // b  -> response 
	 
     input   [31:0]     s_axi_awaddr_i,
     output             s_axi_awready_o,
     input              s_axi_awvalid_i,
     
     //input              s_axi_awprot, // kullanmadim
     
     input   [31:0]     s_axi_wdata_i,
     output             s_axi_wready_o,
     input   [3:0]      s_axi_wstrb_i, // kullanmadim
     input              s_axi_wvalid_i,
     
     input              s_axi_bready_i,
     output             s_axi_bvalid_o,
     output             s_axi_bresp_o, // 1 gecerli, 0 gecersiz 
          
     input   [3:0]      read_size_i,
     // PWM

	 output  [1:0]      pwm1_mode_o, 
	 output  [31:0]     pwm1_period_o,
	 output  [31:0]     pwm1_threshold1_o, 
	 output  [31:0]     pwm1_threshold2_o,
	 output  [11:0]     pwm1_step_o,
	 input              pwm1_i,
	 	 
	 output  [1:0]      pwm2_mode_o, 
	 output  [31:0]     pwm2_period_o,
	 output  [31:0]     pwm2_threshold1_o, 
	 output  [31:0]     pwm2_threshold2_o,
	 output  [11:0]     pwm2_step_o,
	 input              pwm2_i
	 
	 
	 
    );
    
	// OUTPUTS
	reg s_axi_arready_o_r      = 1'b0;
	reg s_axi_rvalid_o_r       = 1'b0;
	reg [31:0] s_axi_rdata_o_r = 32'd0;
	reg s_axi_awready_o_r      = 1'b0;
	reg s_axi_wready_o_r       = 1'b0;
	reg s_axi_bvalid_o_r       = 1'b0;
	reg s_axi_bresp_o_r        = 1'b0;
	reg s_axi_rresp_o_r        = 1'b0;
	
	assign s_axi_arready_o = s_axi_arready_o_r;
	assign s_axi_rvalid_o  = s_axi_rvalid_o_r;
	assign s_axi_rdata_o   = s_axi_rdata_o_r;
	assign s_axi_awready_o = s_axi_awready_o_r;
	assign s_axi_wready_o  = s_axi_wready_o_r;
	assign s_axi_bvalid_o  = s_axi_bvalid_o_r;
	assign s_axi_bresp_o   = s_axi_bresp_o_r;
	assign s_axi_rresp_o   = s_axi_rresp_o_r;
	
	// ADDRESS
	parameter [31:0] PWM_BASE_ADDR = 32'h2002_0000;
	parameter [31:0] PWM_MASK_ADDR = 32'h0000_00ff;
	
	// REGISTERS
   reg [1:0] 	pwm_control_1  = 2'd0; 
   reg [31:0] 	pwm_period_1 = 32'd0;
   reg [31:0] 	pwm_threshold_1_1  = 32'd0;
   reg [31:0] 	pwm_threshold_1_2  = 32'd0;
   reg [11:0] 	pwm_step_1  = 12'd0;
   reg 		    pwm_output_1  = 1'd0;
   
   reg [1:0] 	pwm_control_2  = 2'd0; 
   reg [31:0] 	pwm_period_2 = 32'd0;
   reg [31:0] 	pwm_threshold_2_1  = 32'd0;
   reg [31:0] 	pwm_threshold_2_2  = 32'd0;
   reg [11:0] 	pwm_step_2  = 12'd0;
   reg 		    pwm_output_2  = 1'd0;
	
	// STATES
	localparam state_pwm_control_1 = 8'b0000_0000;
	localparam state_pwm_control_2 = 8'b0000_0100;
	localparam state_pwm_period_1  = 8'b0000_1000;
	localparam state_pwm_period_2  = 8'b0000_1100;	
	localparam state_pwm_threshold_1_1  = 8'b0001_0000;
	localparam state_pwm_threshold_1_2  = 8'b0001_0100;
	
	localparam state_pwm_threshold_2_1  = 8'b0001_1000;
	localparam state_pwm_threshold_2_2  = 8'b0001_1100;	
	localparam state_pwm_step_1   = 8'b0010_0000;
	localparam state_pwm_step_2   = 8'b0010_0100;
	localparam state_pwm_output_1  = 8'b0010_1000;
	localparam state_pwm_output_2  = 8'b0010_1100;

	// Next signals
	reg [1:0]  pwm_control_1_next   = 2'd0;
	reg [31:0] pwm_period_1_next    = 32'd0;
	reg [31:0] pwm_threshold_1_1_next = 32'd0;
	reg [31:0] pwm_threshold_1_2_next = 32'd0;
	reg [11:0] pwm_step_1_next	   = 12'd0;
	reg 	   pwm_output_1_next		= 1'b0;
    
    reg [1:0]  pwm_control_2_next   = 2'd0;
	reg [31:0] pwm_period_2_next    = 32'd0;
	reg [31:0] pwm_threshold_2_1_next = 32'd0;
	reg [31:0] pwm_threshold_2_2_next = 32'd0;
	reg [11:0] pwm_step_2_next	   = 12'd0;
	reg 	   pwm_output_2_next		= 1'b0;
	
	
	// Outputs
	assign pwm1_mode_o       = pwm_control_1;
    assign pwm1_period_o     = pwm_period_1;    
    assign pwm1_threshold1_o = pwm_threshold_1_1;
    assign pwm1_threshold2_o = pwm_threshold_1_2;
    assign pwm1_step_o       = pwm_step_1;  
    
    assign pwm2_mode_o       = pwm_control_2;
    assign pwm2_period_o     = pwm_period_2;    
    assign pwm2_threshold1_o = pwm_threshold_2_1;
    assign pwm2_threshold2_o = pwm_threshold_2_2;
    assign pwm2_step_o       = pwm_step_2;           
           
	reg s_axi_arready_o_next = 1'b0;
	reg [31:0] s_axi_rdata_o_next = 32'd0;
	reg s_axi_awready_o_next = 1'b0;
	reg s_axi_wready_o_next  = 1'b0;
	reg s_axi_bvalid_o_next  = 1'b0;
	reg s_axi_rvalid_o_next  = 1'b0;
	reg s_axi_bresp_o_r_next = 1'b0;
	reg s_axi_rresp_o_r_next = 1'b0;
	
	reg read_state  = 1'b0;
	reg read_state_next  = 1'b0;
	reg write_state = 1'b0;
	reg write_state_next = 1'b0;
	
	reg  [7:0]  s_axi_araddr_i_r;
	wire [7:0]	reg_addres_r;
	assign reg_addres_r = s_axi_araddr_i_r[7:0];
	
	reg  [7:0]  s_axi_awaddr_i_r;
	wire [7:0]	reg_addres_w;
	assign reg_addres_w = s_axi_awaddr_i_r[7:0];
	
	// AXI HANDHSHAKE
	wire write_en;
	assign write_en = ((reg_addres_w!= state_pwm_output_1)||(reg_addres_w!= state_pwm_output_2) ); 
	wire r_adress_check;
	wire w_adress_check;
	assign r_adress_check = s_axi_arvalid_i & ((s_axi_araddr_i & ~PWM_MASK_ADDR) == PWM_BASE_ADDR); 
	assign w_adress_check = s_axi_awvalid_i &   s_axi_wvalid_i &  ((s_axi_awaddr_i & ~PWM_MASK_ADDR) == PWM_BASE_ADDR) & write_en;
    
    reg [3:0] read_size_i_r = 4'd0;
    wire read_word;
    wire read_half;
    wire read_byte;
   
    assign read_word = read_size_i_r[3];
    assign read_half = read_size_i_r[1];
    assign read_byte = read_size_i_r[0];
    
    reg [3:0] s_axi_wstrb_i_r = 4'd0;
    wire write_word;
    wire write_half;
    wire write_byte;
    
    assign write_word = s_axi_wstrb_i_r[3];
    assign write_half = s_axi_wstrb_i_r[1];
    assign write_byte = s_axi_wstrb_i_r[0];
    
    
    
	always @* begin
	
      s_axi_arready_o_next 		= s_axi_arready_o_r;
      s_axi_rdata_o_next 		= s_axi_rdata_o_r;
      s_axi_awready_o_next 		= s_axi_awready_o_r;
      s_axi_wready_o_next 		= s_axi_wready_o_r;
      s_axi_bvalid_o_next 		= 1'b0;
      s_axi_rvalid_o_next 		= 1'b0;
      read_state_next 			= 1'b0;
      write_state_next 			= 1'b0;
      pwm_control_1_next 		= pwm_control_1;
	  pwm_period_1_next 		= pwm_period_1;
	  pwm_threshold_1_1_next 	= pwm_threshold_1_1;
	  pwm_threshold_1_2_next 	= pwm_threshold_1_2;
	  pwm_step_1_next 			= pwm_step_1;
      s_axi_bresp_o_r_next 		= 1'b0;
      s_axi_rresp_o_r_next 		= 1'b0;
      pwm_output_1_next         = pwm1_i;
      
      pwm_control_2_next 		= pwm_control_2;
	  pwm_period_2_next 		= pwm_period_2;
	  pwm_threshold_2_1_next 	= pwm_threshold_2_1;
	  pwm_threshold_2_2_next 	= pwm_threshold_2_2;
	  pwm_step_2_next 			= pwm_step_2;
      pwm_output_2_next         = pwm2_i;
      
		if(read_state && s_axi_rready_i) begin
         s_axi_arready_o_next = 1'b0;
         read_state_next = 1'b0;
         s_axi_rresp_o_r_next = 1'b1;
		  
				case(reg_addres_r)
					state_pwm_control_1 : begin
						s_axi_rvalid_o_next     = 1'b1;
						s_axi_rdata_o_next[1:0] = pwm_control_1;
					end
                    
                    state_pwm_control_2 : begin
						s_axi_rvalid_o_next     = 1'b1;
						s_axi_rdata_o_next[1:0] = pwm_control_2;
					end
                
					state_pwm_period_1 : begin
						s_axi_rvalid_o_next 	= 1'b1;
						s_axi_rdata_o_next[7:0] = pwm_period_1[7:0]; // read_byte kesin
						
						if(read_word) begin
						  s_axi_rdata_o_next[31:8] 	= pwm_period_1[31:8];
						end
						else if(read_half) begin
						  s_axi_rdata_o_next[15:8] 	= pwm_period_1[15:8];
						end
					end
					
					state_pwm_period_2 : begin
						s_axi_rvalid_o_next 	= 1'b1;
						s_axi_rdata_o_next[7:0] = pwm_period_2[7:0]; // read_byte kesin
						
						if(read_word) begin
						  s_axi_rdata_o_next[31:8] 	= pwm_period_2[31:8];
						end
						else if(read_half) begin
						  s_axi_rdata_o_next[15:8] 	= pwm_period_2[15:8];
						end
					end
					
					state_pwm_threshold_1_1 : begin
						s_axi_rvalid_o_next 	= 1'b1;
						s_axi_rdata_o_next[7:0] = pwm_threshold_1_1[7:0]; // read_byte kesin
						
						if(read_word) begin
						  s_axi_rdata_o_next[31:8] 	= pwm_threshold_1_1[31:8];
						end
						else if(read_half) begin
						  s_axi_rdata_o_next[15:8] 	= pwm_threshold_1_1[15:8];
						end
					end
					
					state_pwm_threshold_2_1 : begin
						s_axi_rvalid_o_next 	= 1'b1;
						s_axi_rdata_o_next[7:0] = pwm_threshold_2_1[7:0]; // read_byte kesin
						
						if(read_word) begin
						  s_axi_rdata_o_next[31:8] 	= pwm_threshold_2_1[31:8];
						end
						else if(read_half) begin
						  s_axi_rdata_o_next[15:8] 	= pwm_threshold_2_1[15:8];
						end
					end
					 
					state_pwm_threshold_1_2 : begin
						s_axi_rvalid_o_next	= 1'b1;
						s_axi_rdata_o_next[7:0] = pwm_threshold_1_2[7:0]; // read_byte kesin
						
						if(read_word) begin
						  s_axi_rdata_o_next[31:8] 	= pwm_threshold_1_2[31:8];
						end
						else if(read_half) begin
						  s_axi_rdata_o_next[15:8] 	= pwm_threshold_1_2[15:8];
						end
					end
					
					state_pwm_threshold_2_2 : begin
						s_axi_rvalid_o_next	= 1'b1;
						s_axi_rdata_o_next[7:0] = pwm_threshold_2_2[7:0]; // read_byte kesin
						
						if(read_word) begin
						  s_axi_rdata_o_next[31:8] 	= pwm_threshold_2_2[31:8];
						end
						else if(read_half) begin
						  s_axi_rdata_o_next[15:8] 	= pwm_threshold_2_2[15:8];
						end
					end
					
					state_pwm_step_1 : begin
						s_axi_rvalid_o_next 	 = 1'b1;
						if(read_word || read_half) begin
						  s_axi_rdata_o_next[11:0] = pwm_step_1;
						end
						else begin // read_byte
						  s_axi_rdata_o_next[7:0] = pwm_step_1;
						end
						
					end
					
					state_pwm_step_2 : begin
						s_axi_rvalid_o_next 	 = 1'b1;
						if(read_word || read_half) begin
						  s_axi_rdata_o_next[11:0] = pwm_step_2;
						end
						else begin // read_byte
						  s_axi_rdata_o_next[7:0] = pwm_step_2;
						end
						
					end
					
					state_pwm_output_1 : begin
						s_axi_rvalid_o_next 	 = 1'b1;
						s_axi_rdata_o_next[0] 	 = pwm_output_1;
					end
					
					state_pwm_output_2 : begin
						s_axi_rvalid_o_next 	 = 1'b1;
						s_axi_rdata_o_next[0] 	 = pwm_output_2;
					end
					
					default : begin
						s_axi_rvalid_o_next = 1'b0;
					end
						
            endcase
      end
      else if(r_adress_check) begin
         s_axi_arready_o_next = 1'b1;
         read_state_next = 1'b1;
      end
        
      if(write_state && s_axi_bready_i)begin
        
         write_state_next     = 1'b0;
         s_axi_awready_o_next = 1'b0; 
         s_axi_wready_o_next  = 1'b0;	  
        
         case(reg_addres_w)
				state_pwm_control_1 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_control_1_next = s_axi_wdata_i[1:0];
				end
				
				state_pwm_control_2 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_control_2_next = s_axi_wdata_i[1:0];
				end
              
				state_pwm_period_1 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_period_1_next[7:0] = s_axi_wdata_i[7:0];
					if(write_word) begin
	                   pwm_period_1_next[31:8]  = s_axi_wdata_i[31:8];
					end
					else if(write_half) begin
					   pwm_period_1_next[15:8]  = s_axi_wdata_i[15:8];
					end
				end
				
				state_pwm_period_2 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_period_2_next[7:0] = s_axi_wdata_i[7:0];
					if(write_word) begin
	                   pwm_period_2_next[31:8]  = s_axi_wdata_i[31:8];
					end
					else if(write_half) begin
					   pwm_period_2_next[15:8]  = s_axi_wdata_i[15:8];
					end
				end
						
				state_pwm_threshold_1_1 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_threshold_1_1_next[7:0] = s_axi_wdata_i[7:0];
					if(write_word) begin
	                   pwm_threshold_1_1_next[31:8]  = s_axi_wdata_i[31:8];
					end
					else if(write_half) begin
					   pwm_threshold_1_1_next[15:8]  = s_axi_wdata_i[15:8];
					end
				end
				
				state_pwm_threshold_2_1 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_threshold_2_1_next[7:0] = s_axi_wdata_i[7:0];
					if(write_word) begin
	                   pwm_threshold_2_1_next[31:8]  = s_axi_wdata_i[31:8];
					end
					else if(write_half) begin
					   pwm_threshold_2_1_next[15:8]  = s_axi_wdata_i[15:8];
					end
				end
					 
				state_pwm_threshold_1_2 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_threshold_1_2_next[7:0] = s_axi_wdata_i[7:0];
					if(write_word) begin
	                   pwm_threshold_1_2_next[31:8]  = s_axi_wdata_i[31:8];
					end
					else if(write_half) begin
					   pwm_threshold_1_2_next[15:8]  = s_axi_wdata_i[15:8];
					end
				end
						
			    state_pwm_threshold_2_2 : begin
					s_axi_bvalid_o_next = 1'b1;
					pwm_threshold_2_2_next[7:0] = s_axi_wdata_i[7:0];
					if(write_word) begin
	                   pwm_threshold_2_2_next[31:8]  = s_axi_wdata_i[31:8];
					end
					else if(write_half) begin
					   pwm_threshold_2_2_next[15:8]  = s_axi_wdata_i[15:8];
					end
				end
				
				state_pwm_step_1 : begin
					s_axi_bvalid_o_next = 1'b1;
					if(write_word || write_half) begin
					   pwm_step_1_next = s_axi_wdata_i[11:0];
					end
					else begin // write_byte
					   pwm_step_1_next = s_axi_wdata_i[7:0];
					end
					
				end
				
				state_pwm_step_2 : begin
					s_axi_bvalid_o_next = 1'b1;
					if(write_word || write_half) begin
					   pwm_step_2_next = s_axi_wdata_i[11:0];
					end
					else begin // write_byte
					   pwm_step_2_next = s_axi_wdata_i[7:0];
					end
					
				end
					
					//state_pwm_output_1 : begin
						// buradan emin degilim
					//end
			    
				default : begin
					s_axi_bvalid_o_next = 1'b0;
				end
							
         endcase
      end
      else if(w_adress_check) begin
         s_axi_awready_o_next = 1'b1; 
         s_axi_wready_o_next  = 1'b1;
         write_state_next = 1'b1;
      end
        
    end
	
	always @(posedge s_axi_aclk_i) begin
	   if(s_axi_aresetn_i)begin
	      s_axi_arready_o_r <= 1'b0;        
	      s_axi_rdata_o_r   <= 32'd0;          
	      s_axi_awready_o_r <= 32'd0;        
	      s_axi_wready_o_r  <= 1'b0;         
	      s_axi_bvalid_o_r  <= 1'b0;         
	      s_axi_rvalid_o_r  <= 1'b0;         
	      s_axi_bresp_o_r   <= 1'b0; 
		  s_axi_rresp_o_r   <= 1'b0;
			 
	      read_state  <= 1'b0;                    
	      write_state <= 1'b0;                  
          pwm_control_1 	<= 2'd0;
		  pwm_period_1 		<= 32'd0;
		  pwm_threshold_1_1 <= 32'd0;
		  pwm_threshold_1_2 <= 32'd0;
		  pwm_step_1 		<= 12'd0;                
          pwm_output_1      <= 1'b0;    
          s_axi_araddr_i_r  <= 8'd0;
		  s_axi_awaddr_i_r  <= 8'd0;
	      s_axi_wstrb_i_r   <= 4'd0;
		  read_size_i_r     <= 4'd0;                                                   
	                                                                 
	   end    
	    
	   else begin
         s_axi_arready_o_r  <= s_axi_arready_o_next;
         s_axi_rdata_o_r    <= s_axi_rdata_o_next;
         s_axi_awready_o_r  <= s_axi_awready_o_next;
         s_axi_wready_o_r   <= s_axi_wready_o_next;
            
         s_axi_rvalid_o_r   <= s_axi_rvalid_o_next;
            
         s_axi_rresp_o_r    <= s_axi_rresp_o_r_next; 
  
         read_state 		<= read_state_next;
         write_state 		<= write_state_next;
				
         s_axi_bvalid_o_r 	<= s_axi_bvalid_o_next;
         s_axi_bresp_o_r    <= s_axi_bresp_o_r_next;

         pwm_control_1 		<= pwm_control_1_next;
		 pwm_period_1 		<= pwm_period_1_next;
		 pwm_threshold_1_1  <= pwm_threshold_1_1_next;
		 pwm_threshold_1_2  <= pwm_threshold_1_2_next;
		 pwm_step_1 		<= pwm_step_1_next;
		 pwm_output_1       <= pwm_output_1_next;
		 s_axi_araddr_i_r   <= s_axi_araddr_i[7:0];
		 s_axi_awaddr_i_r   <= s_axi_awaddr_i[7:0];            
		 s_axi_wstrb_i_r    <= s_axi_wstrb_i;
		 read_size_i_r      <= read_size_i;
               
      end
	end

	// PWM 2 ICIN
	always @(posedge s_axi_aclk_i) begin
	   if(s_axi_aresetn_i)begin              
          pwm_control_2 	<= 2'd0;
		  pwm_period_2 		<= 32'd0;
		  pwm_threshold_2_1 <= 32'd0;
		  pwm_threshold_2_2 <= 32'd0;
		  pwm_step_2 		<= 12'd0;                
          pwm_output_2      <= 1'b0;                                                                                                               
	   end    
	    
	   else begin
         pwm_control_2 		<= pwm_control_2_next;
		 pwm_period_2 		<= pwm_period_2_next;
		 pwm_threshold_2_1  <= pwm_threshold_2_1_next;
		 pwm_threshold_2_2  <= pwm_threshold_2_2_next;
		 pwm_step_2 		<= pwm_step_2_next;
		 pwm_output_2       <= pwm_output_2_next;      
      end
    end
	

endmodule