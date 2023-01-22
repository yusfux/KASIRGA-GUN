`timescale 1ns / 1 ps

// 16 x oversample

module baud_rate_generator 
(
    input clk_i,
    input rst_i,
    output rx_tick_o,
    output tx_tick_o,
    input [15:0] baud_div_i  
    );
    
    reg rx_tick_o_r = 1'b0;
    reg tx_tick_o_r = 1'b0;
    
    assign rx_tick_o = rx_tick_o_r;
    assign tx_tick_o = tx_tick_o_r;
        
    wire [31:0] max_r_clock;
    wire [31:0] max_t_clock;
    assign max_r_clock = baud_div_i[15:4];
    assign max_t_clock = baud_div_i;
    
    reg [31:0] rx_counter = 32'd0;
    reg [31:0] tx_counter = 32'd0;
    

 always @(posedge clk_i) begin
 
        if(!rst_i) begin // rst_i == 0 ise resetlenecek
            rx_counter  <= 32'd0;
            rx_tick_o_r <= 1'b0;
            tx_counter  <= 32'd0;
            tx_tick_o_r <= 1'b0;
        end
        
        else begin
        
            // rx clock
            
            if (rx_counter == (max_r_clock-1'b1)) begin
                rx_counter  <= 32'd0;
                rx_tick_o_r <= 1'b1;
            end 
            else if (rx_counter > (max_r_clock-1'b1)) begin
                rx_counter  <= 32'd0;
                rx_tick_o_r <= 1'b0;
            end
            else begin
                rx_counter  <= rx_counter + 1'b1;
                rx_tick_o_r <= 1'b0;
            end
            
            // tx clock
            
            if (tx_counter == (max_t_clock-1'b1)) begin
                tx_counter  <= 32'd0;
                tx_tick_o_r <= 1'b1;
            end 
            else if (tx_counter > (max_t_clock-1'b1)) begin
                tx_counter  <= 32'd0;
                tx_tick_o_r <= 1'b0;
            end
            else begin
                tx_counter  <= tx_counter + 1'b1;
                tx_tick_o_r <= 1'b0;
            end
        end
    end
    
endmodule
