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
    //input                   modul_gecerli_i, gerek var mý yok mu anlamadým
    input                   modul_hazir_i,
    input                   anabellekten_obek_geldi_i,
    input       [2:0]       buyruk_turu_i,
        
    output      [127:0]     veri_obegi_o ,
    output      [31:0]      okunan_veri_o,
    output      [31:0]      kirli_obek_adresi,
    output                  adres_bulundu_o,
    output                  onbellek_hazir_o,
    output                  onbellek_gecerli_o,            
    output                  obek_kirli_o 
    
);

reg     [127:0]        veri_obegi_r;

reg                    onbellek_hazir_r;

reg                    onbellek_gecerli_r;

reg                    adres_bulundu_r;

reg     [31:0]         okunan_veri_r;

reg                    obek_kirli_r;

reg     [31:0]         kirli_obek_adresi_r;

// onbellek icin 
reg     [127:0]  onbellek        [255:0]; // boyutu degistir
reg     [17:0]   etiket_buffer   [255:0];
reg              kirli_buffer    [255:0];
reg              gecerli_buffer  [255:0];


wire     [7:0]    onbellek_adres;
wire     [3:0]    secilen_byte_r;
wire     [17:0]   etiket_r;

assign      onbellek_adres =  adres_i[13:6];
assign      secilen_byte   =  adres_i[5:2];
assign      etiket         =  adres_i[31:14];

// function 
always @(posedge clk_i) begin
            
      onbellek_hazir_r <= 0;
      
      if(modul_hazir_i == 1'b1) begin
            
/*           
onbelekte adres aranýr bunun icin etiketle karsýlarýrma yapýlýr eger adres bulunurrsa else durumuna girer adres
verilir eger adres bulunamzsa adres bulunamadý sinayli gider ve veri öbeginin kirli olup olunmadýgýna bakýlýr eger kirliyse o öbek anabellege yazýlmalý bu sebepten 
öbek denetleyicye gönderilir ve o obegin adresi de gonderilir, daha sonra ana bellekten obek gelir ve bu obek onbellege yazilmalidir 
hala durum bellekten_oku_i dir, anabllekten anabllek obegi buldu diye sinyal gelir ve onbellege obek yazilir  
*/          
            if(bellekten_oku_i) begin
                 if(gecerli_buffer[onbellek_adres] == 1'b0) begin
                
                    adres_bulundu_r <= 0;
                    etiket_buffer[onbellek_adres] <= etiket; // obek geldiginde ilk else if e girmemeli
                    gecerli_buffer[onbellek_adres] <= 1'b1; // sýradaki sefer geldiginde buraya girmemeli
                end 
                else if(etiket_buffer[onbellek_adres] != etiket) begin
                     adres_bulundu_r <= 0;
                     if(kirli_buffer[onbellek_adres] == 1) begin 
                        obek_kirli_r <= 1;
                        veri_obegi_r <= onbellek[onbellek_adres];
                        kirli_obek_adresi_r <= {etiket_buffer[onbellek_adres] , onbellek_adres ,6'b000000};
                        etiket_buffer[onbellek_adres] <= etiket; 
                     end
                     else begin
                        obek_kirli_r <= 0;                       
                        etiket_buffer[onbellek_adres] <= etiket; 
                     end   
                end
                else if(anabellekten_obek_geldi_i) begin
                
                       onbellek[onbellek_adres] <= veri_obegi_i;
                       kirli_buffer[onbellek_adres] <= 1'b0;  
                       // veriyi burada yollayacaz mý yoksa veri zaten alýnmýþ mý olacak ?
                       case(buyruk_turu_i)
                            `MEM_LB  :  okunan_veri_r <= {{24{onbellek[onbellek_adres][((secilen_byte)<<3) + 7]}} ,onbellek[onbellek_adres][(secilen_byte)<<3 +: 7]} ;
                            `MEM_LH  :  okunan_veri_r <= {{16{onbellek[onbellek_adres][((secilen_byte)<<3) + 15]}} ,onbellek[onbellek_adres][(secilen_byte)<<3 +: 15]};
                            `MEM_LW  :  okunan_veri_r <= onbellek[onbellek_adres][(secilen_byte)<<3 +: 31];
                            `MEM_LBU :  okunan_veri_r <= { {24{1'b0}} , onbellek[onbellek_adres][(secilen_byte)<<3 +: 7]} ;
                            `MEM_LHU :  okunan_veri_r <= { {16{1'b0}} , onbellek[onbellek_adres][(secilen_byte)<<3 +: 15]};
                       endcase
                       onbellek_hazir_r <= 1'b1;
                end
                else begin
                    
                       case(buyruk_turu_i)
                            `MEM_LB  :  okunan_veri_r <= {{24{onbellek[onbellek_adres][((secilen_byte)<<3) + 7]}} ,onbellek[onbellek_adres][(secilen_byte)<<3 +: 7]} ;
                            `MEM_LH  :  okunan_veri_r <= {{16{onbellek[onbellek_adres][((secilen_byte)<<3) + 15]}} ,onbellek[onbellek_adres][(secilen_byte)<<3 +: 15]};
                            `MEM_LW  :  okunan_veri_r <= onbellek[onbellek_adres][(secilen_byte)<<3 +: 31];
                            `MEM_LBU :  okunan_veri_r <= { {24{1'b0}} , onbellek[onbellek_adres][(secilen_byte)<<3 +: 7]} ;
                            `MEM_LHU :  okunan_veri_r <= { {16{1'b0}} , onbellek[onbellek_adres][(secilen_byte)<<3 +: 15]};
                       endcase
                       onbellek_hazir_r <= 1'b1;
                end           
            end
/*
onbellekte adres aranir eger bulunursa obege yazilir ve kirli biti 1 yapýlýr eger onbellekte bulunamazsa adres bulunamadý, 
eger obek kirliyse obek_kirli sinyali ve obek de ardesiyle breaber yollanýr, denetleyici anabellekten 
obegi alýr onbellege anabellketen_obek_geldi sinayili yollar ve obegide yollar obek onbellege yazýlýr ve daha sonra yazýlmak 
istenen veri yazýlýr
kirli biti 1 olur
*/            
            else if(bellege_yaz_i)begin
                
                // eger gecerli 0 sa daha once hic veri yazilmamis demek anabellekten obek gelmeli ve obegin ustune yazilmal
                if(gecerli_buffer[onbellek_adres] == 1'b0) begin
                
                    adres_bulundu_r <= 0;
                    etiket_buffer[onbellek_adres] <= etiket; // obek geldiginde ilk else if e girmemeli
                    gecerli_buffer[onbellek_adres] <= 1'b1; // sýradaki sefer geldiginde buraya girmemeli
                end 
                else if(etiket_buffer[onbellek_adres] != etiket) begin
                     adres_bulundu_r <= 0;
                     if(kirli_buffer[onbellek_adres] == 1) begin 
                        obek_kirli_r <= 1;
                        kirli_obek_adresi_r <= {etiket_buffer[onbellek_adres] , onbellek_adres , 6'b000000};
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
                        `MEM_SB : onbellek[onbellek_adres][(secilen_byte)<<3 +: 7]  <= veri_i[7:0]     ;
                        `MEM_SH : onbellek[onbellek_adres][(secilen_byte)<<3 +: 15] <= veri_i[15:0]    ;
                        `MEM_SW : onbellek[onbellek_adres][(secilen_byte)<<3 +: 31] <= veri_i[31:0]    ;
                    endcase
                    kirli_buffer[onbellek_adres] <= 1'b1;
                end
                else begin
                    kirli_buffer[onbellek_adres] <= 1'b1;
                    
                    case(buyruk_turu_i)                   
                        `MEM_SB : onbellek[onbellek_adres][(secilen_byte)<<3 +: 7]  <= veri_i[7:0]     ;
                        `MEM_SH : onbellek[onbellek_adres][(secilen_byte)<<3 +: 15] <= veri_i[15:0]    ;
                        `MEM_SW : onbellek[onbellek_adres][(secilen_byte)<<3 +: 31] <= veri_i[31:0]    ;
                    endcase
                end
            end      
      end 
end

assign        onbellek_hazir_o      =   onbellek_hazir_r;   
assign        okunan_veri_o         =   okunan_veri_r;      
assign        adres_bulundu_o       =   adres_bulundu_r;    
assign        onbellek_gecerli_o    =   onbellek_gecerli_r; 
assign        obek_kirli_o          =   obek_kirli_r;       
assign        veri_obegi_o          =   veri_obegi_r;       
assign        kirli_obek_adresi_o   =   kirli_obek_adresi_r;

endmodule
