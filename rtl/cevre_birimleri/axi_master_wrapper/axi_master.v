`timescale 1ns / 1ps
`include "operations.vh"
// her islem 2 cevrim sürüyor

module axi_master(
	 input              axi_aclk_i,
     input              axi_aresetn_i,
     
     //         READ SIGNALS 
	 // ar -> address read (address in)
	 // r  -> read (data out)
     output   [31:0]     axi_araddr_o,  
     input               axi_arready_i,  
     output              axi_arvalid_o, 
     
     output              axi_rready_o,
     input               axi_rvalid_i,
     
	 input [31:0]        axi_rdata_i, 
	 input               axi_rresp_i,
     
     //         WRITE SIGNALS
	 // aw -> address write (address in)
 	 // w  -> write (data in)
	 // b  -> response 
	 
     output   [31:0]     axi_awaddr_o,
     input               axi_awready_i,
     output              axi_awvalid_o,
     
     output   [31:0]     axi_wdata_o,
     input               axi_wready_i,
     output   [3:0]      axi_wstrb_o, // kullanmadim
     output              axi_wvalid_o,
     
     output              axi_bready_o,
     input               axi_bvalid_i, 
     input               axi_bresp_i,  

	 input 	  [31:0]     address_i,
	 input    [2:0]      buyruk_turu_i,
	 output   [31:0]     okunan_veri_o,
	 output              okunan_veri_gecerli_o,
	 input    [31:0]     data_i,
	 output   [3:0]      read_size_o
     

    );

// LB, LH, LW, SB, SH, SW
	
	
//	localparam LB = 3'b001;
//	localparam LH = 3'b010;
//	localparam LW = 3'b011;
//	localparam SB = 3'b100;
//	localparam SH = 3'b101;
//	localparam SW = 3'b110;
	
    assign okunan_veri_o = axi_rdata_i;
	
	reg  [31:0]  axi_araddr_r = 32'd0;
	assign axi_araddr_o = axi_araddr_r;
	
	reg          axi_arvalid_r = 1'b0; // hafiza
	reg 		 axi_arvalid_r_next = 1'b0;
	assign axi_arvalid_o = axi_arvalid_r_next;
	
	reg			 axi_rready_r = 1'b0;
	assign axi_rready_o = axi_rready_r;
	
	reg  [31:0]  axi_awaddr_r = 32'd0;
	assign axi_awaddr_o = axi_awaddr_r;
	
	reg		     axi_awvalid_r = 1'b0; // hafiza
	reg		     axi_awvalid_r_next = 1'b0;
	assign axi_awvalid_o = axi_awvalid_r_next;
	
	reg  [31:0]  axi_wdata_r = 32'd0;
	assign axi_wdata_o = axi_wdata_r;
	
	reg  [3:0]   axi_wstrb_r = 4'd0;
	assign axi_wstrb_o = axi_wstrb_r;
	
	reg   		 axi_wvalid_r = 1'b0; // hafiza
	reg   		 axi_wvalid_r_next = 1'b0;
	assign axi_wvalid_o = axi_wvalid_r_next;
	
	reg 		 axi_bready_r = 1'b0; // hafiza
	reg 		 axi_bready_r_next = 1'b0;
	assign axi_bready_o = axi_bready_r_next;

	reg  [3:0]   read_size_o_r = 4'd0;
	assign read_size_o = read_size_o_r;
	
	reg          okunan_veri_gecerli_o_r = 1'b0;
	assign       okunan_veri_gecerli_o = okunan_veri_gecerli_o_r;
	
	wire read_handshake;
	assign read_handshake = (axi_arvalid_r && axi_arready_i);
	
	wire write_address_handshake;
	assign write_address_handshake = (axi_awvalid_r && axi_awready_i); 
	
	wire write_data_handshake;
	assign write_data_handshake = (axi_wvalid_r && axi_wready_i);
	
	
	always @* begin
	axi_rready_r = 1'b1;
	axi_bready_r_next = 1'b1;
	axi_awvalid_r_next = axi_awvalid_r;
	axi_wvalid_r_next = axi_wvalid_r;
	axi_arvalid_r_next = axi_arvalid_r;
	
	if(read_handshake) begin
		axi_arvalid_r_next = 1'b0;
	end
	
	if(write_address_handshake && write_data_handshake) begin
		axi_awvalid_r_next = 1'b0;
		axi_wvalid_r_next = 1'b0;
	end
	
	if(axi_bready_r && axi_bvalid_i) begin
		// veri yazildi

		if(axi_bresp_i) begin // gecerli
		  
		end
		else begin // gecersiz
		  
		end
	end
	
	if(axi_rvalid_i) begin
	   okunan_veri_gecerli_o_r = 1'b1;
	end
	else begin
	   okunan_veri_gecerli_o_r = 1'b0;
	end
	
        case (buyruk_turu_i)
            `MEM_LB : begin
                axi_araddr_r = address_i;
                axi_arvalid_r_next = 1'b1;
                read_size_o_r = 4'b0001;
            end
            
            `MEM_LH : begin
                axi_araddr_r = address_i;
                axi_arvalid_r_next = 1'b1;
                read_size_o_r = 4'b0011;
            end
            
            `MEM_LW : begin
                axi_araddr_r = address_i;
                axi_arvalid_r_next = 1'b1;
                read_size_o_r = 4'b1111;
            end
            
            `MEM_SB : begin
                axi_awaddr_r = address_i;
                axi_awvalid_r_next = 1'b1;
                axi_wdata_r = data_i;
                axi_wvalid_r_next = 1'b1;
                axi_wstrb_r = 4'b0001;

            end
            
            `MEM_SH : begin
                axi_awaddr_r = address_i;
                axi_awvalid_r_next = 1'b1;
                axi_wdata_r = data_i;
                axi_wvalid_r_next = 1'b1;
                axi_wstrb_r = 4'b0011;
                
            end
            
            `MEM_SW : begin
                axi_awaddr_r = address_i;
                axi_awvalid_r_next = 1'b1;
                axi_wdata_r = data_i;
                axi_wvalid_r_next = 1'b1;
                axi_wstrb_r = 4'b1111;
            end
            
            default : begin
                axi_arvalid_r_next = 1'b0;
                axi_awvalid_r_next = 1'b0;
                axi_wvalid_r_next = 1'b0;
            end
        endcase
	end
	
	
	always @(posedge axi_aclk_i) begin
        if(axi_aresetn_i) begin
            axi_awvalid_r <= 1'b0;
            axi_bready_r <= 1'b0;
            axi_wvalid_r <= 1'b0;
            axi_arvalid_r <= 1'b0;
        end
        else begin
            axi_awvalid_r <= axi_awvalid_r_next;
            axi_bready_r <= axi_bready_r_next;
            axi_wvalid_r <= axi_wvalid_r_next;
            axi_arvalid_r <= axi_arvalid_r_next;
        end
	end
	
	
	
	
endmodule
