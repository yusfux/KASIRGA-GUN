
`timescale 1ns / 1 ps


module transmitter(
    input clk_i,
	input tx_tick_i,
	input rst_i,
	input [7:0]t_in_i,
	input tx_en_i,
	output  tx_o,
	output t_done_o
);
    
    reg t_done_o_r = 1'b0;
    reg tx_o_r = 1'b1;
    assign tx_o = tx_o_r;
    assign t_done_o = t_done_o_r;
    
    reg next_tx = 1'b1;
	reg [2:0]bit_index = 3'b0;
	reg [2:0]next_bit_index = 3'b0;
	reg t_done_next  = 1'b0;
	
	localparam idle     = 2'b00;
	localparam start    = 2'b01;
	localparam data     = 2'b10;
	localparam stop     = 2'b11;
	
	reg [1:0]state      = 2'b00;
	reg [1:0]next_state = 2'b00;
	
	reg [7:0]uart_wdata = 8'd0;
	reg [7:0]wdata_next = 8'd0;
	
	
	always @* begin
	
        t_done_next = t_done_o;
        next_state = state;
        next_bit_index = bit_index;
        next_tx = tx_o;
        wdata_next = uart_wdata;
        
        if(!rst_i)begin // rst_i == 0 ise resetlenecek
           t_done_next = 1'b0;
           next_state = 2'b00;
           next_bit_index = 3'b0;
           next_tx = 1'b1;
           wdata_next = 8'd0; 
        end
        
        else begin
        
            case(state)
                default : begin
                    next_state = idle;
                end
                
                idle : begin 
                t_done_next = 1'b0;
                    if(tx_tick_i)begin
                    wdata_next = t_in_i; 
                        if(tx_en_i) begin
                            next_state = start;
                            next_tx = 1'b0; 
                        end
                        else begin
                             next_tx = 1'b1; 
                        end
                    end
                end
                    
                start : begin
                    if(tx_tick_i)begin
                        next_tx = uart_wdata[bit_index];
                        next_bit_index = bit_index + 1'b1;
                        next_state = data;
                    end
                end
                
                    
                data : begin
                    if(tx_tick_i)begin
                        next_tx = uart_wdata[bit_index]; 
                            if(&bit_index) begin
                                next_state = stop; 
                                next_bit_index = 3'd0; 
                            end
                            
                            else begin
                                next_bit_index = bit_index + 1'b1;
                            end
                    end
                end
                    
                stop : begin 
                    if(tx_tick_i)begin
                        next_tx     = 1'b1; 
                        wdata_next  = 8'd0;
                        next_state  = idle;
                        t_done_next = 1'b1;
                    end
                end
                        
            endcase 
        
        end
        
	end
	
	always @(posedge clk_i) begin
        uart_wdata <= wdata_next;
        t_done_o_r <= t_done_next;
        state <= next_state;
        bit_index <= next_bit_index;
        tx_o_r <= next_tx;	
	end


endmodule 