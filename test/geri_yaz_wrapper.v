`timescale 1ns / 1ps

// en_flush_mret_instruction_o_w cozden cikiyor, bosta kaldi

module geri_yaz_wrapper(
        input bellekten_oku_i,

        input         yazmaca_yaz_i,
        input  [4:0]  hedef_yazmaci_i,
        output        yazmaca_yaz_o,
        output [4:0]  hedef_yazmaci_o,    
        input  [31:0] hedef_yazmac_verisi_i,   
        input         bellek_veri_hazir_i,
        input  [31:0] bellek_veri_i,
        input         gc_veri_gecerli_i,
        input  [31:0] gc_okunan_veri_i, 
        output [31:0] yazmac_veri_o     
    );
    
    assign yazmac_veri_o = gc_veri_gecerli_i ? gc_okunan_veri_i : (bellek_veri_hazir_i && bellekten_oku_i) ? bellek_veri_i :  hedef_yazmac_verisi_i;
    //assign yazmac_veri_o = hedef_yazmac_verisi_i;

    assign yazmaca_yaz_o = yazmaca_yaz_i;
    assign hedef_yazmaci_o = hedef_yazmaci_i;
    
    
endmodule
