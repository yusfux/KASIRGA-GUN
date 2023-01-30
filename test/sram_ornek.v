`timescale 1ns / 1ps

module sram_ornek(
    
    input                   clk_i, 
    input                   rst_i,  
    
    input                   en_i,
    input                   wen_i,
    input       [6:0]       adres_i,
    input       [148:0]     veri_i,
    
    output      reg [148:0]     obek_o
);
 
reg      [148:0]     onbellek [20:0];
integer i;
always @(posedge clk_i) begin
    
    if(rst_i == 0) begin
         for(i=0 ; i<=20 ; i = i+1) begin
            onbellek[i] <= 149'd0;
         end
    end  
    else if(en_i == 1'b1) begin
        if(wen_i == 1'b1) begin
            onbellek[adres_i] <= veri_i;
            obek_o <= veri_i;
        end
        else begin
            obek_o <= onbellek[adres_i];
        end
    end
end
endmodule