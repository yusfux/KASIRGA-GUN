`timescale 1ns / 1 ps

// receiver yeni taktikle 20 milyon baud'a kadar doðru haberleþiyor.

module baud_rate_generator
(
   input         clk_i,
   input         rst_i,
   output        tx_tick_o,
   input  [15:0] baud_div_i 
);
    
   reg tx_tick_o_r ;
  
   assign tx_tick_o = tx_tick_o_r;
       
   wire [15:0] max_t_clock;
   assign max_t_clock = baud_div_i;
   
   reg [15:0] tx_counter ;

   always @(posedge clk_i) begin
 
      if(!rst_i) begin // rst_i == 0 ise resetlenecek
         tx_counter  <= 32'd0;
         tx_tick_o_r <= 1'b0;
      end
      
      else begin 
    
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
