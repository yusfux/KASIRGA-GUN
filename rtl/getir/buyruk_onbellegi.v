`timescale 1ns / 1ps

module buyruk_onbellegi(
    input               clk_i,
    input               rst_i,
    
    input     [31:0]    adres_i,                    //  bellek_adresi
    input     [127:0]   buyruk_obegi_i,             //  bellekten gelen öbek
    input               anabellekten_obek_geldi_i,   //  bellekten öbek gelme i?lemi tamamland?
        
    output    [31:0]    buyruk_o,                   //  buyruk
    output              adres_bulundu_o            //  önbellekte adres bulundu          
);
 
reg     [31:0]      buyruk_r = 32'd0;         
reg                 adres_bulundu_r = 1'b0;  
                                              
reg     [127:0]     onbellek        [127:0];  
reg     [19:0]      etiket_buffer   [127:0];  
reg                 gecerli_buffer  [127:0];  

wire     [7:0]      onbellek_adres;    
wire     [1:0]      secilen_byte;          
wire     [19:0]     etiket;            

integer i;

assign  onbellek_adres      =    adres_i[11:4]; 
assign  secilen_byte        =    adres_i[3:2];
assign  etiket              =    adres_i[31:12];

always @(posedge clk_i) begin
    if(!rst_i)begin
        buyruk_r <= 32'd0;      
        adres_bulundu_r <= 1'b0;
                           
        for(i=0 ; i<=127 ; i= i+1) begin
            onbellek[i] = 128'b0;
            etiket_buffer[i] = 20'b0;
            gecerli_buffer[i] = 1'b0;
        end                                      
    end
    else begin
         
        if(gecerli_buffer[onbellek_adres] == 1'b0) begin
            adres_bulundu_r <= 1'b0;
            etiket_buffer[onbellek_adres] <= etiket;
            gecerli_buffer[onbellek_adres] <= 1'b1;
        end        

        else if(etiket_buffer[onbellek_adres] != etiket) begin 
            adres_bulundu_r <= 0;
            etiket_buffer[onbellek_adres]  <=  etiket;
        end

        else if(anabellekten_obek_geldi_i) begin
            onbellek[onbellek_adres] <= buyruk_obegi_i;
        end             
        
        else begin
            case(secilen_byte) 
                2'd0: begin
                     buyruk_r  <=  onbellek [onbellek_adres][31 : 0];         
                end
                2'd1 : begin
                     buyruk_r  <=  onbellek [onbellek_adres][63 : 32]; 
                end 
                2'd2 : begin
                    buyruk_r  <=  onbellek [onbellek_adres][95 : 64];
                end 
                2'd3 : begin
                    buyruk_r  <=  onbellek [onbellek_adres][127 : 96];
                end  
            endcase
            adres_bulundu_r  <= 1;
        end
    end
end        
          
assign   buyruk_o = buyruk_r;         
assign   adres_bulundu_o = adres_bulundu_r;  

endmodule