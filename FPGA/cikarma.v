`timescale 1ns / 1ps

module cikarma(
    input         blok_aktif_i,
    input  [31:0] sayi1_i,
    input  [31:0] sayi2_i,
    output [31:0] sonuc_o
    );
    
    reg [31:0] sonuc_r;
    assign sonuc_o = sonuc_r;
    
    always @* begin
      if(blok_aktif_i) begin
         sonuc_r = sayi1_i - sayi2_i;
      end
      else begin
         sonuc_r = 32'd0;
      end
    end
    
endmodule
