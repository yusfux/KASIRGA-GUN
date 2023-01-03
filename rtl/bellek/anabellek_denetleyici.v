`timescale 1ns / 1ps

module anabellek_denetleyici(
        input clk_i,
        input rst_i,//active low reset
        
        input oku_i,
        input yaz_i,
        
        input         anabellege_istek_i,//anabellege yapilacak herhangi bir islem icin once ab denetleyiciye istek atilmali
        input [31:0]  yaz_adres_i, // obegin baslangic adresi yani hep 32'bx0000 seklinde
        input [127:0] yaz_veri_obegi_i,
        input [31:0]  oku_adres_i,
       //anabellekten gelecek sinyaller
        input         iomem_ready_i,
        input  [31:0] anabellekten_veri_i,
       //anabellege gidecek sinyaller
        output [31:0] adres_o, // obegin baslangic adresi yani hep 32'bx0000 seklinde
        output [31:0] yaz_veri_o, // parca parca yaziyor
        output        iomem_valid_o,
        output [3:0]  wr_strb_o,
        
        //onbellek denetleyiciye gidecek sinyaller
        output         anabellek_musait_o,
        output         okunan_veri_obegi_hazir_o,
        output [127:0] okunan_veri_obegi_o
    );
    
    localparam MUSAIT = 2'b00;
    localparam YAZ = 2'b01;        
    localparam OKU = 2'b10; //yeni islem alamaz

    reg [2:0] veri_sayisi_r; //obekte 4 tane veri var o yuzden 2 bit
    reg [2:0] veri_sayisi_ns;
    reg [1:0]durum;
    reg [1:0]durum_next;
    reg      okunan_veri_obegi_hazir_r;
    reg      okunan_veri_obegi_hazir_ns;
    reg[127:0] okunan_veri_obegi_r;
    reg[127:0] okunan_veri_obegi_ns;
    reg [31:0] adres_ns;
    reg [31:0] adres_r;
   

    reg [31:0] yaz_veri_ns; // parca parca yaziyor
    reg [31:0] yaz_veri_r;
    reg [3:0]  wr_strb_ns;
    reg [31:0] wr_strb_r;
    reg [31:0] yazilacak_adres;
    reg        iomem_valid_r;
    reg        iomem_valid_ns;
    
    reg        anabellek_musait_r;
    reg        anabellek_musait_ns;
    
    assign okunan_veri_obegi_o = okunan_veri_obegi_r;
    //assign okunan_veri_obegi_hazir_o = okunan_veri_obegi_hazir_r;
    assign adres_o = adres_r; //adres_r yapinca yanlis adres gonderiyor
    assign yaz_veri_o = yaz_veri_r;
    assign wr_strb_o = wr_strb_r;
    assign iomem_valid_o = iomem_valid_r;//!(durum_next == MUSAIT);
    assign anabellek_musait_o = anabellek_musait_r;//(durum_next == MUSAIT);
    assign okunan_veri_obegi_hazir_o = okunan_veri_obegi_hazir_r; //(durum == OKU) && (durum_next == MUSAIT);

    always @* begin
        durum_next = durum;
        okunan_veri_obegi_ns = okunan_veri_obegi_r;
        okunan_veri_obegi_hazir_ns = okunan_veri_obegi_hazir_r;
        adres_ns = adres_r;
        veri_sayisi_ns = veri_sayisi_r;
        yaz_veri_ns = yaz_veri_r;
        iomem_valid_ns = iomem_valid_r;
        wr_strb_ns = wr_strb_r;
        anabellek_musait_ns = anabellek_musait_r;
        case(durum)
            MUSAIT: begin
            iomem_valid_ns = 1'b0;
            anabellek_musait_ns = 1'b1;
                if(anabellege_istek_i)begin
                    if(oku_i)begin
                        adres_ns = oku_adres_i;
                        iomem_valid_ns = 1;
                        wr_strb_ns = 4'b0000;
                        anabellek_musait_ns = 1'b0;
                        durum_next = OKU;
                    end
                    else if(yaz_i)begin
                        adres_ns = yaz_adres_i;
                        wr_strb_ns = 4'b1111;
                        yaz_veri_ns = yaz_veri_obegi_i[31:0];
                        iomem_valid_ns = 1;
                        anabellek_musait_ns = 1'b0;
                        durum_next = YAZ;
                    end
                    
                end
            end
            YAZ: begin
                if(iomem_ready_i) begin 
                     veri_sayisi_ns = veri_sayisi_r + 1;
                     wr_strb_ns = 4'b1111;
                     iomem_valid_ns = 1'b1;
                     if(veri_sayisi_r == 3'd0)begin
                        yaz_veri_ns = yaz_veri_obegi_i[63:32];
                        adres_ns = adres_r + 4;
                     end
                     else if(veri_sayisi_r == 3'd1) begin
                        yaz_veri_ns = yaz_veri_obegi_i[95:64];
                        adres_ns = adres_r + 4;
                     end
                     else if(veri_sayisi_r == 3'd2) begin
                        yaz_veri_ns = yaz_veri_obegi_i[127:96];
                        adres_ns = adres_r + 4;
                     end
                     else if(veri_sayisi_r == 3'd3)begin
                        veri_sayisi_ns = 0;
                        iomem_valid_ns = 0; 
                        anabellek_musait_ns = 1'b1;
                        durum_next = MUSAIT;
                     end
                end
            end
            OKU : begin
                if(iomem_ready_i)begin
                     veri_sayisi_ns = veri_sayisi_r + 1;
                     okunan_veri_obegi_ns = okunan_veri_obegi_r << 32;
                     okunan_veri_obegi_ns[31:0] = anabellekten_veri_i;
                     if(veri_sayisi_r == 3'd3)begin
                        veri_sayisi_ns = 0;
                        iomem_valid_ns = 0;
                        anabellek_musait_ns = 1'b1;
                        okunan_veri_obegi_hazir_ns = 1'b1;
                        durum_next = MUSAIT;
                     end
                     else begin 
                     iomem_valid_ns = 1; 
                     adres_ns = adres_r + 4'b0100;
                     wr_strb_ns = 4'b0000;
                     end
                end
            end
        endcase
    end

    always @(posedge clk_i) begin
        if(!rst_i) begin
            durum <= MUSAIT;
            veri_sayisi_r <= 3'd0;
            okunan_veri_obegi_r <= 128'd0;
            adres_r <= 32'd0;
            yaz_veri_r <= 32'd0;// multi driven pin warning, satiri acma
            wr_strb_r <= 4'd0; //multi driven pin warning, satiri acma
            iomem_valid_r <= 1'b0; //multi driven pin warning, satiri acma
            anabellek_musait_r <= 1'b0;
            okunan_veri_obegi_hazir_r <= 1'b0;
        end
        else begin
            durum <= durum_next;
            anabellek_musait_r <= anabellek_musait_ns;
            okunan_veri_obegi_r <= okunan_veri_obegi_ns;
            adres_r <= adres_ns;
            veri_sayisi_r <= veri_sayisi_ns;
            yaz_veri_r <= yaz_veri_ns;
            iomem_valid_r <= iomem_valid_ns;
            wr_strb_r <= wr_strb_ns;
            okunan_veri_obegi_hazir_r <= okunan_veri_obegi_hazir_ns;
        end
    
    end
    
endmodule
    
