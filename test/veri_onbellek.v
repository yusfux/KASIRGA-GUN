`timescale 1ns / 1ps

`include "operations.vh"

module veri_onbellek(
    
    input                   clk_i,
    input                   rst_i,
    
    input       [127:0]     veri_obegi_i,
    input       [31:0]      adres_i,
    input       [31:0]      veri_i,
    input                   bellekten_oku_i, 
    input                   bellege_yaz_i,
    input                   anabellekten_obek_geldi_i,
    input       [2:0]       buyruk_turu_i,
        
    output      [127:0]     veri_obegi_o ,
    output      [31:0]      okunan_veri_o,
    output      [31:0]      kirli_obek_adresi_o,
    output                  adres_bulundu_o,
    output                  obek_kirli_o 
    
);

reg     [127:0]        veri_obegi_r = 128'd0;

reg                    adres_bulundu_r = 1'b0;

reg     [31:0]         okunan_veri_r = 32'd0;

reg                    obek_kirli_r = 1'd0;

reg     [31:0]         kirli_obek_adresi_r = 32'd0;

// onbellek icin 
reg     [127:0]  onbellek        [20:0]; // boyutu degistir
reg     [19:0]   etiket_buffer   [20:0];
reg              kirli_buffer    [20:0];
reg              gecerli_buffer  [20:0];

integer i;
initial begin
    for(i=0 ; i<=20 ; i=i+1) begin
        onbellek[i] = 128'd0;
        etiket_buffer[i] = 20'd0;
        kirli_buffer[i] = 1'b0;
        gecerli_buffer[i] = 1'b0;        
    end
end

wire     [7:0]    onbellek_adres;
wire     [3:0]    secilen_byte;
wire     [19:0]   etiket;

assign      onbellek_adres =  adres_i[11:4];
assign      secilen_byte   =  adres_i[3:0];
assign      etiket         =  adres_i[31:12];

// function 
always @(posedge clk_i) begin
    
    if(rst_i != 1'b1) begin
         for(i=0 ; i<=20 ; i=i+1) begin                                
             onbellek[i] <= 128'd0;         
             etiket_buffer[i] <= 20'd0;     
             kirli_buffer[i]  <= 1'b0;        
             gecerli_buffer[i] <= 1'b0;        
         end                         
         veri_obegi_r <=128'd0;           
         adres_bulundu_r <= 1'b0;          
         okunan_veri_r  <= 32'd0;           
         obek_kirli_r  <= 1'd0;                                           
         kirli_obek_adresi_r <= 32'd0;                
    end 
    else begin        
        if(bellekten_oku_i) begin
            
            if(gecerli_buffer[onbellek_adres] == 1'b0) begin
                
                obek_kirli_r <= 1'b0;
                adres_bulundu_r <= 1'b0;
                etiket_buffer[onbellek_adres] <= etiket; // obek geldiginde ilk else if e girmemeli
                gecerli_buffer[onbellek_adres] <= 1'b1; // s?radaki sefer geldiginde buraya girmemeli   
            end 
            
            else if(etiket_buffer[onbellek_adres] != etiket) begin
                 
                 adres_bulundu_r <= 0;
                 if(kirli_buffer[onbellek_adres] == 1) begin 
                    obek_kirli_r <= 1;
                    veri_obegi_r <= onbellek[onbellek_adres];
                    kirli_obek_adresi_r <= {etiket_buffer[onbellek_adres] , onbellek_adres ,4'b0000};
                    etiket_buffer[onbellek_adres] <= etiket; 
                 end
                 else begin
                    obek_kirli_r <= 1'b0;                       
                    etiket_buffer[onbellek_adres] <= etiket; 
                 end   
            end
            
            else if(anabellekten_obek_geldi_i) begin
                    
                   onbellek[onbellek_adres] <= veri_obegi_i;
                   kirli_buffer[onbellek_adres] <= 1'b0;  
            end
    
            else begin
                   case(buyruk_turu_i)
                        `MEM_LB  : begin
                            okunan_veri_r <= {{24{onbellek[onbellek_adres][secilen_byte * 8 + 8]}},onbellek[onbellek_adres][(secilen_byte*8) +: 7]};
                         end                     
                        `MEM_LH  : begin 
                            okunan_veri_r <= {{16{onbellek[onbellek_adres][secilen_byte * 8 +16]}},onbellek[onbellek_adres][(secilen_byte * 8) +:15]};
                         end
                        `MEM_LW  : begin  
                            okunan_veri_r <= onbellek[onbellek_adres][(secilen_byte * 8) +: 32];
                         end
                        `MEM_LBU :  begin 
                            okunan_veri_r <= {{24{1'b0}},onbellek[onbellek_adres][(secilen_byte * 8) +: 8]};
                         end                      
                        `MEM_LHU : begin 
                            okunan_veri_r <= {{24{1'b0}},onbellek[onbellek_adres][(secilen_byte * 8 ) +: 16]};  
                         end
                   endcase
                   adres_bulundu_r <= 1;
            end           
        end
    
        else if(bellege_yaz_i)begin
            
            if(gecerli_buffer[onbellek_adres] == 1'b0) begin
            
                obek_kirli_r <= 1'b0;
                adres_bulundu_r <= 1'b0;
                etiket_buffer[onbellek_adres] <= etiket; // obek geldiginde ilk else if e girmemeli
                gecerli_buffer[onbellek_adres] <= 1'b1 ; // siradaki sefer geldiginde buraya girmemeli
                
            end 
     
            else if(etiket_buffer[onbellek_adres] != etiket) begin
                 adres_bulundu_r <= 0;
                 if(kirli_buffer[onbellek_adres] == 1) begin 
                    obek_kirli_r <= 1;
                    kirli_obek_adresi_r <= {etiket_buffer[onbellek_adres] , onbellek_adres , 4'b0000};
                    veri_obegi_r <= onbellek[onbellek_adres];
                    etiket_buffer[onbellek_adres] <= etiket; 
                 end
                 else begin
                    obek_kirli_r <= 0;                       
                    etiket_buffer[onbellek_adres] <= etiket; 
                 end   
                                       
            end
     
            else if(anabellekten_obek_geldi_i) begin
                onbellek[onbellek_adres] <= veri_obegi_i;
                case(buyruk_turu_i) 
                    `MEM_SB :  onbellek[onbellek_adres][(secilen_byte*8)+:8]  <= veri_i[7:0];                  
                    `MEM_SH :  onbellek[onbellek_adres][(secilen_byte*8)+:16] <= veri_i[15:0];                
                    `MEM_SW :  onbellek[onbellek_adres][(secilen_byte*8)+:32] <= veri_i[31:0];    
                endcase
                kirli_buffer[onbellek_adres] <= 1'b1;
            end
     
            else begin
                kirli_buffer[onbellek_adres] <= 1'b1;
                case(buyruk_turu_i)                   
                    `MEM_SB : onbellek[onbellek_adres][(secilen_byte)*8 +: 8]  <= veri_i[7:0];
                    `MEM_SH : onbellek[onbellek_adres][(secilen_byte)*8 +: 16] <= veri_i[15:0];
                    `MEM_SW : onbellek[onbellek_adres][(secilen_byte)*8 +: 32] <= veri_i[31:0];
                endcase
                adres_bulundu_r <= 1;
                
            end
        end
        else begin
            adres_bulundu_r <= 0;
        end      
    end
end

assign        okunan_veri_o         =   okunan_veri_r;      
assign        adres_bulundu_o       =   adres_bulundu_r;    
assign        obek_kirli_o          =   obek_kirli_r;       
assign        veri_obegi_o          =   veri_obegi_r;       
assign        kirli_obek_adresi_o   =   kirli_obek_adresi_r;

endmodule