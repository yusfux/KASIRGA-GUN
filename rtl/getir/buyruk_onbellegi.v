`timescale 1ns / 1ps

module buyruk_onbellegi(
    input               clk_i,
    input               rst_i,
    
    input               deneteleyici_hazir_i,       //  denetleyici veri gönderiyor
    input     [31:0]    adres_i,                    //  bellek_adresi
    input     [127:0]   buyruk_obegi_i,             //  bellekten gelen öbek
    input               anabllekten_obek_geldi_i,   //  bellekten öbek gelme iþlemi tamamlandý
            
    output   reg [31:0]    buyruk_o,                   //  buyruk
    output   reg           adres_bulundu_o,            //  önbellekte adres bulundu
    output   reg           onbellek_hazir_o            //  önbellek veri göndermeye hazýr         
);
                                              
reg     [127:0]     onbellek        [255:0];  
reg     [19:0]      etiket_buffer   [255:0];  
reg                 gecerli_buffer  [255:0];  

wire     [7:0]       onbellek_adres;    
wire     [1:0]       secilen_byte;          
wire     [19:0]      etiket;            
   
assign  onbellek_adres      =    adres_i[11:4]; 
assign  secilen_byte        =    adres_i[3:2];
assign  etiket              =    adres_i[31:12];

always @(posedge clk_i) begin
    
        if (deneteleyici_hazir_i) begin 
                
                if(gecerli_buffer[onbellek_adres] == 1'b0) begin
                    adres_bulundu_o <= 1'b0;
                    etiket_buffer[onbellek_adres] <= etiket;
                    gecerli_buffer[onbellek_adres] <= 1'b1;
                    onbellek_hazir_o <= 1'b1;
                end        
        
                else if(etiket_buffer[onbellek_adres] != etiket) begin 
                    adres_bulundu_o <= 0;
                    etiket_buffer[onbellek_adres]  <=  etiket;
                    onbellek_hazir_o <= 1;
                end
        
                else if(anabllekten_obek_geldi_i) begin
                    onbellek[onbellek_adres] <= buyruk_obegi_i;
                    onbellek_hazir_o <= 1;
                end             
                
                else begin
                     buyruk_o  <=  onbellek [onbellek_adres][(secilen_byte << 5) +: 31]; 
                     onbellek_hazir_o <= 1;                                 
                end
       end        
            
end
endmodule
