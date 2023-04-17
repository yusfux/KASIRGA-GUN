`timescale 1ns / 1ps

module adres_duzenleyici(
   input        bellege_yaz_i,
   input        bellekten_oku_i,
   input  [2:0] bellek_adresi30_28_i,
   output       bellege_yaz_o,
   output       bellekten_oku_o,
   output       giris_cikis_aktif_o,
   output       timer_o
    
);
    
   assign bellege_yaz_o       = (bellek_adresi30_28_i == 3'd4) ? bellege_yaz_i : 1'b0;
   assign giris_cikis_aktif_o = (bellek_adresi30_28_i == 3'd2) ? (bellege_yaz_i || bellekten_oku_i) : 1'b0;
   assign bellekten_oku_o     = ( (bellek_adresi30_28_i == 3'd4) || (bellek_adresi30_28_i == 3'd3) ) ? bellekten_oku_i : 1'b0;
   assign timer_o             = bellekten_oku_i ? (bellek_adresi30_28_i == 3'd3) : 1'b0;
    
endmodule
