`timescale 1ns / 1ps

module pipelined_multiplication(
    input  [15:0]sayi1_i,
    input  [15:0]sayi2_i,
    output [31:0]sonuc_o
    );
    
    reg [31:0] sonuc_r;
    
    always @* begin
        sonuc_r = sayi1_i * sayi2_i;
    end
    
    
    assign sonuc_o = sonuc_r;
endmodule
