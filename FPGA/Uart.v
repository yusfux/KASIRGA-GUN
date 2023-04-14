`timescale 1ns / 1ps

module Uart(
   input          rst_i,
   input          clk_i,
   output [7:0]   r_out_o,
   input  [7:0]   t_in_i,
   output         r_done_o,
   output         t_done_o,
   input          rx_en_i,
   input          tx_en_i,
   input          rx_i,
   output         tx_o,
   input  [15:0 ] baud_div_i
    );
    
    wire tx_tick_w;
       
    baud_rate_generator brg (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .tx_tick_o(tx_tick_w),
        .baud_div_i(baud_div_i) // baud_div
    );
    
    /*
      ! receiver dtr'den sonra oversample yerine baska bir teknik
      kullanilarak 20 milyon baud'a kadar dogru calisacak sekilde ayarlandi
    */
    
    receiver uart_receiver (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rx_i(rx_i),
        .rx_en_i(rx_en_i), // rx_en
        .r_out_o(r_out_o),
        .r_done_o(r_done_o),
        .baud_div_i(baud_div_i) // baud_div
    );
    
    
    transmitter uart_transmitter(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .tx_o(tx_o),
        .tx_tick_i(tx_tick_w),
        .tx_en_i(tx_en_i), // tx_en
        .t_in_i(t_in_i),
        .t_done_o(t_done_o)
    );
    
    
    
endmodule
