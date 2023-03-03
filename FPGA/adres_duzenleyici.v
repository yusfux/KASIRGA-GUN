`timescale 1ns / 1ps

module adres_duzenleyici(
    input                   bellege_yaz_i,
    input                   bellekten_oku_i,
    input                   bellek_adresi30_i, //bellek_adresi[30]
    output                  bellege_yaz_o,
    output                  bellekten_oku_o,
    output                  giris_cikis_aktif_o
    
    );
    
    assign bellege_yaz_o = bellek_adresi30_i ? bellege_yaz_i : 1'b0;
    assign giris_cikis_aktif_o = !bellek_adresi30_i ? (bellege_yaz_i || bellekten_oku_i) : 1'b0;
    assign bellekten_oku_o = bellek_adresi30_i ? bellekten_oku_i : 1'b0;
    
endmodule
