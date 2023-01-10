`timescale 1ns/1ps

module buyruk_onbellegi_denetleyici(

    input                clk_i,                    
    input                rst_i,// active low reset
    
    input   [31:0]      adres_i,                    
  
    // onbellek sinyalleri
    input               adres_bulundu_i,
    input   [31:0]      buyruk_i,
    
    output  [127:0]     veri_obegi_o,
    output              onbellege_obek_yaz_o, 
    
    // anabellek denetleyici sinyalleri
    
    input               anabellek_musait_i,
    input               anabellek_hazir_i,
    input   [127:0]     okunan_obek_i,
    
    output  [31:0]      anabellek_adres_o,
    output              anabellek_istek_o,
    output              anabellek_yaz_o,
    output              anabellek_oku_o,
    
    // oncozucuye gidecek olanlar
    
    output  [31:0]      buyruk_o,
    output              buyruk_hazir_o
); 

    localparam ONBELLEK_OKU  = 2'd1;
    localparam ANABELLEK_OKU = 2'd2;
    localparam ONBELLEK_YAZ  = 2'd3;
    
    
    reg     [127:0]     veri_obegi_r;
    reg                 onbellege_obek_yaz_r;
    reg     [31:0]      anabellek_adres_r;
    reg     [31:0]      buyruk_r;
    reg                 buyruk_hazir_r;
    reg     [1:0]       durum_r = ONBELLEK_OKU;
    reg     [1:0]       durum_ns;
    
    
    wire [1:0] veri_araligi;
    assign veri_araligi = adres_i[3:2];
      
    always @(*) begin
       
        durum_ns             = durum_r;
        buyruk_r             = 32'd0;
        anabellek_adres_r    = 32'd0;
        veri_obegi_r         = 128'd0;
        onbellege_obek_yaz_r = 1'b0; 
        buyruk_hazir_r       = 1'b0; 
        
        case(durum_r)
                    
            ONBELLEK_OKU: begin
            
                if(adres_bulundu_i) begin
                    buyruk_r       = buyruk_i;       
                    buyruk_hazir_r = 1'b1;
                end
                else begin   
                    buyruk_hazir_r = 1'b0;          
                    if(anabellek_musait_i) begin
                        anabellek_adres_r = {adres_i[31:4], 4'b0000};
                        buyruk_hazir_r    = 1'b0;
                        durum_ns          = ANABELLEK_OKU ;                     
                    end
                end
            end
            
            ANABELLEK_OKU :begin
                 if(anabellek_hazir_i) begin
                      
                            if(veri_araligi == 2'b00)begin
                                buyruk_r = okunan_obek_i[31:0];
                            end
                            else if(veri_araligi == 2'b01)begin
                                buyruk_r = okunan_obek_i[63:32];
                            end
                            else if(veri_araligi == 2'b10)begin
                                buyruk_r = okunan_obek_i[95:64];
                            end
                            else if(veri_araligi == 2'b11)begin
                                buyruk_r = okunan_obek_i[127:96];
                            end
                            
                            buyruk_hazir_r = 1'b1;
                                                    
                            onbellege_obek_yaz_r = 1'b1;
                            veri_obegi_r         = okunan_obek_i;
                            durum_ns             = ONBELLEK_YAZ;    
                    end
        
            end
            ONBELLEK_YAZ : begin 
                durum_ns = ONBELLEK_OKU;
                
            end
       endcase
    end

    
    always @(posedge clk_i) begin 
       if(!rst_i)begin
           durum_r <= ONBELLEK_OKU;
       end
       else begin
           durum_r <= durum_ns;
       end
   end
    
assign veri_obegi_o         = veri_obegi_r;
assign onbellege_obek_yaz_o = onbellege_obek_yaz_r; 
assign anabellek_adres_o    = anabellek_adres_r;
assign anabellek_istek_o    = (durum_r == ONBELLEK_OKU && durum_ns == ANABELLEK_OKU);
assign anabellek_yaz_o      = 1'b0;
assign anabellek_oku_o      = 1'b1;
assign buyruk_o             = buyruk_r;
assign buyruk_hazir_o       = buyruk_hazir_r;

endmodule