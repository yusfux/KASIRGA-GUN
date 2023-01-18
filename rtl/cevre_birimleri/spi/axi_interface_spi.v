`timescale 1ns / 1ps

module axi_interface_spi(
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
	 output             s_axi_rresp_o, // 1 gecerli, 0 gecersiz
     
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
     output             s_axi_bresp_o, // 1 gecerli, 0 gecersiz      
	 
	 input   [3:0]      read_size_i, 
	 output             stall_o,
	  
	  // SPI ICIN CIKISLAR
	 output  [4:0]		adres_bit_o, // adresin en anlamsiz 5 biti
	 output  			islem_o, // 0 ise oku, 1 ise yaz
	 output 			islem_gecerli_o, // 1 ise islem_o'dan gelen deger gecerli
	 output  [1:0]	    read_type_o, // 00 ise 1 byte, 01 ise 2 byte, 10 ise 4 byte oku
	 output  [1:0]	    write_type_o,// 00 ise 1 byte, 01 ise 2 byte, 10 ise 4 byte yaz
	  
	  
	  // SPI'DAN GELEN GIRISLER
	  input 			islem_bitti_i,
	  input 			stall_i
	 
    );
	 
	// SPI cikislarinin atamalari 116. satirda
	
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
	assign stall_o		   = stall_i;
	
	// ADDRESS
	parameter [31:0] SPI_BASE_ADDR = 32'h2001_0000;
	parameter [31:0] SPI_MASK_ADDR = 32'h0000_00ff;
           
	reg s_axi_arready_o_next = 1'b0;
	reg [31:0] s_axi_rdata_o_next = 32'd0;
	reg s_axi_awready_o_next = 1'b0;
	reg s_axi_wready_o_next  = 1'b0;
	reg s_axi_bvalid_o_next  = 1'b0;
	reg s_axi_rvalid_o_next  = 1'b0;
	reg s_axi_bresp_o_r_next = 1'b0;
	reg s_axi_rresp_o_r_next = 1'b0;
	
	wire [4:0]	reg_addres_r;
	assign reg_addres_r = s_axi_araddr_i[4:0];
	
	wire [4:0]	reg_addres_w;
	assign reg_addres_w = s_axi_awaddr_i[4:0];
	
	// AXI HANDHSHAKE
	wire write_en;
	assign write_en = !(reg_addres_w[2]^reg_addres_w[3]); 
	wire read_en;
	assign read_en = (reg_addres_w!=5'b01100); 
	wire r_adress_check;
	wire w_adress_check;
	assign r_adress_check = s_axi_arvalid_i & ((s_axi_araddr_i & ~SPI_MASK_ADDR) == SPI_BASE_ADDR) & read_en; 
	assign w_adress_check = s_axi_awvalid_i &   s_axi_wvalid_i &  ((s_axi_awaddr_i & ~SPI_MASK_ADDR) == SPI_BASE_ADDR) & write_en;
    
    
    // SPI OUTPUTS ///////////////////////////////////////////////
    assign 	 adres_bit_o     	 = r_adress_check ? reg_addres_r : w_adress_check ? reg_addres_w : 5'd0;
	assign   islem_o         	 = r_adress_check;
	assign   islem_gecerli_o 	 = r_adress_check | w_adress_check;
	
	assign   read_type_o[1]  	 = read_size_i[3]; 
	assign   read_type_o[0]  	 = read_size_i[1]; 
	
	assign   write_type_o[1]     = s_axi_wstrb_i[3];
	assign   write_type_o[0]     = s_axi_wstrb_i[1];
	//////////////////////////////////////////////////////////////
	always @* begin
	
      s_axi_arready_o_next 	    = 1'b1;
      s_axi_rdata_o_next 		= s_axi_rdata_o_r;
      s_axi_awready_o_next 	    = 1'b1;
      s_axi_wready_o_next 		= 1'b1;
      s_axi_bvalid_o_next 		= 1'b0;
      s_axi_rvalid_o_next 		= 1'b0;
      s_axi_bresp_o_r_next 	    = 1'b0;
      s_axi_rresp_o_r_next 	    = 1'b0;
      
		if(r_adress_check && s_axi_rready_i) begin
		
			if(islem_bitti_i) begin
				s_axi_rvalid_o_next = 1'b1;
			end
			else begin
				// islem yapilamadi, temsili ekledim, stall ya da exception
			end
			
      end

      if(w_adress_check && s_axi_bready_i)begin
        

			if(islem_bitti_i) begin
				s_axi_bvalid_o_next = 1'b1;
			end
			else begin
				// islem yapilamadi, temsili ekledim, stall ya da exception
			end
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
	   end    
	    
	   else begin
          s_axi_arready_o_r  <= s_axi_arready_o_next;
          s_axi_rdata_o_r    <= s_axi_rdata_o_next;
          s_axi_awready_o_r  <= s_axi_awready_o_next;
          s_axi_wready_o_r   <= s_axi_wready_o_next;
		  s_axi_bvalid_o_r 	 <= s_axi_bvalid_o_next;			
          s_axi_rvalid_o_r   <= s_axi_rvalid_o_next; 
          s_axi_bresp_o_r    <= s_axi_bresp_o_r_next;
		  s_axi_rresp_o_r    <= s_axi_rresp_o_r_next; 	
      end
	end
	

endmodule