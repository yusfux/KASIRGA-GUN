`timescale 1ns / 1ps

module pipelined_multiplier(
    
    input           clk_i,
    input           rst_i,
        
    input           blok_aktif_i,
    
    input           carpim_unsigned_i,
    input           carpim_mulhsu_i,
                 
    input   [31:0]  sayi1_i,
    input   [31:0]  sayi2_i, 
    output  [63:0]  sonuc_o,
    
    output          carpim_hazir_o
        
);

localparam DURUM_0 = 0;
localparam DURUM_1 = 1;
localparam DURUM_2 = 2;
localparam DURUM_3 = 3;
localparam DURUM_4 = 4;

reg     [2:0]       durum_ns;
reg     [2:0]       durum_r;

reg                 carpim_hazir_r;

reg     [63:0]      sonuc_r;
reg     [63:0]      sonuc_ns;

wire    [31:0]      poz_sayi1_w;
assign  poz_sayi1_w = (sayi1_i[31] == 1'b1) ? (~sayi1_i + 1) : sayi1_i;

wire    [31:0]      poz_sayi2_w;
assign  poz_sayi2_w = (sayi2_i[31] == 1'b1) ? (~sayi2_i + 1) : sayi2_i;

reg                 sayi1_neg_mi_r;
reg                 sayi1_neg_mi_ns;

reg                 sayi2_neg_mi_r;
reg                 sayi2_neg_mi_ns;

reg     [15:0]      variable1_r;

reg     [15:0]      variable2_r;

reg     [31:0]      temp1_ns;
reg     [31:0]      temp1_r;

reg     [47:0]      temp2_ns;
reg     [47:0]      temp2_r;

reg     [31:0]      carpim16_output1_ns;
reg     [31:0]      carpim16_output1;

reg     [31:0]      carpim16_output2_ns;
reg     [31:0]      carpim16_output2;

wire     [31:0]     carpim32_output_w;

wire    [47:0]      temp3_w;
assign      temp3_w = {carpim32_output_w , 16'b0};


wire     [31:0]      toplam1_w;
assign  toplam1_w = temp1_ns + carpim16_output2_ns;

wire    [47:0]      temp4_w;
assign  temp4_w = {16'b0 , toplam1_w};

wire     [47:0]      toplam2_w;
assign  toplam2_w = temp3_w + temp2_ns;

wire     [47:0]      toplam3_w;
assign  toplam3_w = toplam2_w + temp4_w; 

pipelined_multiplication carpim16_bit(variable1_r,variable2_r,carpim32_output_w);

always @(*) begin
    
    sonuc_ns = sonuc_r;
 
    carpim_hazir_r = 1'b0;
    sayi1_neg_mi_ns  =  sayi1_neg_mi_r; 
    sayi2_neg_mi_ns  =  sayi2_neg_mi_r; 
    durum_ns     =  durum_r;            
    variable1_r  = 16'd0;
    variable2_r  = 16'd0;
    temp1_ns    =   temp1_r;    
    temp2_ns    =   temp2_r;   
    carpim16_output1_ns = carpim16_output1; 
    carpim16_output2_ns = carpim16_output2; 
    
    if(blok_aktif_i) begin
        carpim_hazir_r = 1'b0;   
                            
        if(carpim_unsigned_i) begin
            case(durum_r)     
            DURUM_0 : begin
                carpim_hazir_r = 1'b0;
                variable1_r = sayi1_i[15:0];                           
                variable2_r = sayi2_i[15:0];
                carpim16_output1_ns = carpim32_output_w;
                temp1_ns = {16'b0 , carpim32_output_w[31:16]};
                durum_ns = DURUM_1;
            end
            DURUM_1 : begin
                carpim_hazir_r = 1'b0; 
                variable1_r = sayi1_i[31:16];                                                
                variable2_r = sayi2_i[15:0];
                carpim16_output2_ns = carpim32_output_w;  
                durum_ns = DURUM_2;     
            end  
            DURUM_2 : begin

                carpim_hazir_r = 1'b0;
                variable1_r = sayi1_i[15:0];                                                
                variable2_r = sayi2_i[31:16];
                temp2_ns = {16'b0 , carpim32_output_w};  
                durum_ns = DURUM_3;                                               
            end
            DURUM_3 : begin
                
                carpim_hazir_r = 1'b1;
                variable1_r = sayi1_i[31:16];                                                 
                variable2_r = sayi2_i[31:16];                                                 
                sonuc_ns = {toplam3_w,carpim16_output1[15:0]};                
                                
                durum_ns = DURUM_0;                                             
            end          
            endcase
        end 
        else if(carpim_mulhsu_i) begin

            if(sayi1_i[31] == 1'b1) begin
                sayi1_neg_mi_ns = 1'b1;
            end
            else begin
                sayi1_neg_mi_ns = 1'b0;            
            end
            
            case(durum_r) 
            DURUM_0 : begin
                carpim_hazir_r = 1'b0;
                variable1_r = poz_sayi1_w[15:0];                           
                variable2_r = sayi2_i[15:0];
                carpim16_output1_ns = carpim32_output_w;
                temp1_ns = {16'b0 , carpim32_output_w[31:16]};
                durum_ns = DURUM_1;
            end
            DURUM_1 : begin
                carpim_hazir_r = 1'b0; 
                variable1_r = poz_sayi1_w[31:16];                                                
                variable2_r = sayi2_i[15:0];
                carpim16_output2_ns = carpim32_output_w;  
                durum_ns = DURUM_2;                                             
            end  
            DURUM_2 : begin
                carpim_hazir_r = 1'b0;
                variable1_r = poz_sayi1_w[15:0];                                                
                variable2_r = sayi2_i[31:16];
                temp2_ns = {16'b0 , carpim32_output_w};  
                durum_ns = DURUM_3;                                               
            end
            DURUM_3 : begin
                carpim_hazir_r = 1'b0;
                variable1_r  = poz_sayi1_w[31:16];                                                 
                variable2_r  = sayi2_i[31:16];                                                 
                                
                sonuc_ns = {toplam3_w,carpim16_output1[15:0]}; 
                durum_ns = DURUM_4;                                             
            end       
            DURUM_4 : begin
                carpim_hazir_r = 1'b1;
                if(sayi1_neg_mi_r == 1'b1) begin
                    sonuc_ns = (~sonuc_r+1);
                end
                durum_ns = DURUM_0;
            end   
            endcase
            
        end
        else begin
            if(sayi1_i[31] == 1'b1) begin
                sayi1_neg_mi_ns = 1'b1;
            end
            else begin
                sayi1_neg_mi_ns = 1'b0;            
            end
            if(sayi2_i[31] == 1'b1) begin
                sayi2_neg_mi_ns = 1'b1;            
            end
            else begin
                sayi2_neg_mi_ns = 1'b0;                    
            end
            
            case(durum_r)     
            DURUM_0 : begin
                carpim_hazir_r = 1'b0;
                variable1_r = poz_sayi1_w[15:0];                           
                variable2_r = poz_sayi2_w[15:0];
                carpim16_output1_ns = carpim32_output_w;
                temp1_ns = {16'b0 , carpim32_output_w[31:16]};
                durum_ns = DURUM_1;
            end
            DURUM_1 : begin
                carpim_hazir_r = 1'b0; 
                variable1_r = poz_sayi1_w[31:16];                                                
                variable2_r = poz_sayi2_w[15:0];
                carpim16_output2_ns = carpim32_output_w;  
                durum_ns = DURUM_2;                                             
            end  
            DURUM_2 : begin
                carpim_hazir_r = 1'b0;
                variable1_r = poz_sayi1_w[15:0];                                                
                variable2_r = poz_sayi2_w[31:16];
                temp2_ns = {16'b0 , carpim32_output_w};  
                durum_ns = DURUM_3;                                               
            end
            DURUM_3 : begin
                carpim_hazir_r = 1'b0;
                variable1_r = poz_sayi1_w[31:16];                                                 
                variable2_r = poz_sayi2_w[31:16];                                                 
                                
                sonuc_ns = {toplam3_w,carpim16_output1_ns[15:0]}; 
                durum_ns = DURUM_4;                                             
            end    
            DURUM_4 : begin
                carpim_hazir_r = 1'b1;
                if(sayi2_neg_mi_r == 1'b1 && sayi1_neg_mi_r == 1'b0 || sayi2_neg_mi_r == 1'b0 && sayi1_neg_mi_r == 1'b1) begin
                    sonuc_ns = ~sonuc_r + 1; 
                end
                durum_ns = DURUM_0;
            end      
            endcase            
        end
    end      
end                                                               
                                              
always @(posedge clk_i) begin
    
    if(rst_i == 1'b0) begin
        sayi1_neg_mi_r  <=  1'b0;   
        sayi2_neg_mi_r  <=  1'b0;   
        durum_r     <=   3'd0;
        sonuc_r     <=   32'd0; 
    end
    else begin
            
        temp1_r      <=   temp1_ns;    
        temp2_r      <=   temp2_ns;   
        carpim16_output1 <= carpim16_output1_ns; 
        carpim16_output2 <= carpim16_output2_ns; 
                                  
        sayi1_neg_mi_r  <=  sayi1_neg_mi_ns;   
        sayi2_neg_mi_r  <=  sayi2_neg_mi_ns;   
        durum_r     <=  durum_ns;
        sonuc_r     <=  sonuc_ns;
        
    end
end

assign  sonuc_o = carpim_hazir_r ? sonuc_ns : 64'd0;
assign  carpim_hazir_o = carpim_hazir_r;

endmodule