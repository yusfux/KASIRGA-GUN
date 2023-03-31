`timescale 1ns / 1 ps

module receiver #(parameter oversample=0)(
   input         rx_tick_i,
   input         rst_i,
   input         rx_i,
   output  [7:0] r_out_o,
   output        r_done_o,
   input         clk_i,
   input         rx_en_i
);

   reg r_done_o_r  ;
   assign r_done_o = r_done_o_r;
    
   localparam idle = 2'b00;
   localparam data = 2'b01;
   localparam stop = 2'b10;
    
   reg r_done_next ;
   reg [1:0]state  ;
   reg [1:0]next_state ;
   reg [7:0]tut ;
   reg [7:0]tut_next ;
   reg [7:0]next_r_out ;
   reg [4:0]sayac ;
   reg [4:0]next_sayac ;
   reg [2:0]bit_sayac ;
   reg [2:0]next_bit_sayac ;
    
   reg [7:0]uart_rdata ;
   assign r_out_o = uart_rdata;
    
   always @* begin
      next_r_out = uart_rdata;
      next_state = state;
      next_sayac = sayac;
      tut_next = tut;
      next_bit_sayac = bit_sayac;
      r_done_next = r_done_o;
          
      if(!rst_i) begin // rst_i == 0 ise resetlenecek
         next_r_out = 8'd0;
         next_sayac = 5'd0;
         tut_next = 8'd0;
         next_bit_sayac = 3'd0;
         next_state = 2'b00;
         r_done_next = 1'b0;
      end
      
      else if(rx_en_i)begin // yeni ekledim   
         case(state)   
            default : begin
               next_state = idle;
            end
           
            idle : begin
               r_done_next = 1'b0;
               if(rx_tick_i)begin
                  if(rx_i==0 && (sayac==oversample>>1)) begin
                     next_state = data;
                     next_sayac = 5'd0;   
                  end
                
                  else if(rx_i==0)begin
                     next_sayac = sayac+1'b1;
                  end
               end
            end
            
            data : begin
               if(rx_tick_i)begin        
                  if((sayac==oversample)) begin 
                     next_sayac = 0;
                     next_state = data;
                     tut_next = {rx_i,tut[7:1]}; 
                     next_sayac = 5'd0;         
                     next_bit_sayac = bit_sayac+1;
                     if(&bit_sayac) begin 
                        next_state = stop;
                        next_bit_sayac = 3'd0;
                     end
                  end        
                  else begin
                     next_sayac = sayac + 1'b1;
                  end      
               end
            end
            
            stop : begin
               if(rx_tick_i)begin
                  if((sayac==oversample)) begin
                     r_done_next =1;
                     next_r_out = tut;
                     next_state = idle;
                     next_sayac = 5'd0;
                  end     
                  else begin
                     next_sayac = sayac + 1'b1;
                  end
               end
            end
         endcase
      end
   end 
   
   always @(posedge clk_i) begin
      r_done_o_r <= r_done_next;
      state <= next_state;
      sayac <= next_sayac;
      tut <= tut_next;
      bit_sayac <= next_bit_sayac;
      uart_rdata <= next_r_out; 
   end
      
endmodule 

