`timescale 1ns / 1ps

module adres_duzenleyici(
    input                   bellege_yaz_i,
    input                   bellekten_oku_i,
    input     [2:0]         bellek_adresi30_28_i, //bellek_adresi[30:28]
    output                  bellege_yaz_o,
    output                  bellekten_oku_o,
    output                  giris_cikis_aktif_o
    
    );
    
    assign bellege_yaz_o = (bellek_adresi30_28_i == 3'd4) ? bellege_yaz_i : 1'b0;
    assign giris_cikis_aktif_o = (bellek_adresi30_28_i == 2'd2) ? (bellege_yaz_i || bellekten_oku_i) : 1'b0;
    assign bellekten_oku_o = (bellek_adresi30_28_i == 3'd4) ? bellekten_oku_i : 1'b0;
    
endmodule
