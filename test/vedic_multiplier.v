`timescale 1ns / 1ps

module vedic_16x16(a,b,c);
    
    input [15:0]a;
    input [15:0]b;
    output [31:0]c;
    
    wire [15:0]q0;	
    wire [15:0]q1;	
    wire [15:0]q2;
    wire [15:0]q3;	
    wire [31:0]c;
    wire [15:0]temp1;
    wire [23:0]temp2;
    wire [23:0]temp3;
    wire [23:0]temp4;
    wire [15:0]q4;
    wire [23:0]q5;
    wire [23:0]q6;
    // using 4 8x8 multipliers
    vedic_8x8 z1(a[7:0],b[7:0],q0[15:0]);
    vedic_8x8 z2(a[15:8],b[7:0],q1[15:0]);
    vedic_8x8 z3(a[7:0],b[15:8],q2[15:0]);
    vedic_8x8 z4(a[15:8],b[15:8],q3[15:0]);
    
    // stage 1 adders 
    assign temp1 ={8'b0,q0[15:8]};
    assign q4 = q1[15:0] + temp1;
    assign temp2 ={8'b0,q2[15:0]};
    assign temp3 ={q3[15:0],8'b0};
    assign q5 = temp2 + temp3;
    assign temp4={8'b0,q4[15:0]};
    
    //stage 2 adder
    assign q6 = temp4 + q5;
    // fnal output assignment 
    assign c[7:0]=q0[7:0];
    assign c[31:8]=q6[23:0];
    
endmodule

module vedic_8x8(a,b,c);
   
    input [7:0]a;
    input [7:0]b;
    output [15:0]c;
    
    wire [7:0]q0;	
    wire [7:0]q1;	
    wire [7:0]q2;
    wire [7:0]q3;	
    wire [15:0]c;
    wire [7:0]temp1;
    wire [11:0]temp2;
    wire [11:0]temp3;
    wire [11:0]temp4;
    wire [7:0]q4;
    wire [11:0]q5;
    wire [11:0]q6;
    // using 4 4x4 multipliers
    vedic_4x4 z1(a[3:0],b[3:0],q0[7:0]);
    vedic_4x4 z2(a[7:4],b[3:0],q1[7:0]);
    vedic_4x4 z3(a[3:0],b[7:4],q2[7:0]);
    vedic_4x4 z4(a[7:4],b[7:4],q3[7:0]);
    
    // stage 1 adders 
    assign temp1 ={4'b0,q0[7:4]};
    assign q4 = q1[7:0] + temp1;
    assign temp2 ={4'b0,q2[7:0]};
    assign temp3 ={q3[7:0],4'b0};
    assign q5 = temp2 + temp3;
    assign temp4={4'b0,q4[7:0]};
    // stage 2 adder
    assign q6 = temp4 + q5;
    // fnal output assignment 
    assign c[3:0]=q0[3:0];
    assign c[15:4]=q6[11:0];

endmodule

module vedic_4x4(a,b,c);
    
    input [3:0]a;
    input [3:0]b;
    output [7:0]c;
    
    wire [3:0]q0;	
    wire [3:0]q1;	
    wire [3:0]q2;
    wire [3:0]q3;	
    wire [7:0]c;
    wire [3:0]temp1;
    wire [5:0]temp2;
    wire [5:0]temp3;
    wire [5:0]temp4;
    wire [3:0]q4;
    wire [5:0]q5;
    wire [5:0]q6;
    // using 4 2x2 multipliers
    vedic_2x2 z1(a[1:0],b[1:0],q0[3:0]);
    vedic_2x2 z2(a[3:2],b[1:0],q1[3:0]);
    vedic_2x2 z3(a[1:0],b[3:2],q2[3:0]);
    vedic_2x2 z4(a[3:2],b[3:2],q3[3:0]);
    // stage 1 adders 
    assign temp1 ={2'b0,q0[3:2]};
    assign q4 = q1[3:0] + temp1;
    assign temp2 ={2'b0,q2[3:0]};
    assign temp3 ={q3[3:0],2'b0};
    assign q5 = temp2 + temp3;
    assign temp4={2'b0,q4[3:0]};
    // stage 2 adder 
    assign q6 = temp4 + q5;
    // fnal output assignment 
    assign c[1:0]=q0[1:0];
    assign c[7:2]=q6[5:0];

endmodule

module vedic_2x2(a,b,c);
    input [1:0]a;
    input [1:0]b;
    output [3:0]c;
    wire [3:0]c;
    wire [3:0]temp;
    //stage 1
    // four multiplication operation of bits accourding to vedic logic done using and gates 
    assign c[0]=a[0]&b[0]; 
    assign temp[0]=a[1]&b[0];
    assign temp[1]=a[0]&b[1];
    assign temp[2]=a[1]&b[1];
    //stage two 
    // using two half adders 
    ha z1(temp[0],temp[1],c[1],temp[3]);
    ha z2(temp[2],temp[3],c[2],c[3]);
endmodule

module ha(a, b, sum, carry);
    // a and b are inputs
    input a;
    input b;
    output sum;
    output carry;
    assign carry=a&b;
    assign sum=a^b;
endmodule

module vedic_multiplier(
    
    input           clk_i,             
    input           rst_i,
    
    input           blok_aktif_i,
    
    input           carpim_unsigned_i,
                 
    input   [31:0]  sayi1_i,
    input   [31:0]  sayi2_i, 
    output  [63:0]  sonuc_o,
    
    output          carpim_hazir_o,
    output          durdur_o 
    
);

reg     [63:0]      sonuc_r;
reg     [63:0]      sonuc_ns;
              
reg                 carpim_hazir_r;
reg                 carpim_hazir_ns;

wire    [31:0]      poz_sayi1_w;
assign  poz_sayi1_w = (sayi1_i[31] == 1'b1) ? (~sayi1_i + 1) : sayi1_i;

wire    [31:0]      poz_sayi2_w;
assign  poz_sayi2_w = (sayi2_i[31] == 1'b1) ? (~sayi2_i + 1) : sayi2_i;

reg                 sayi1_neg_mi_ns;
reg                 sayi1_neg_mi_r;

reg                 sayi2_neg_mi_ns;
reg                 sayi2_neg_mi_r;

reg     [15:0]      variable1_ns;
reg     [15:0]      variable1_r;

reg     [15:0]      variable2_ns;
reg     [15:0]      variable2_r;

reg     [15:0]      variable3_ns;
reg     [15:0]      variable3_r;

reg     [15:0]      variable4_ns;
reg     [15:0]      variable4_r;

wire     [31:0]      toplam1_w;
wire     [47:0]      toplam2_w;
wire     [47:0]      toplam3_w;

wire     [31:0]      vedic16_output1_w;
wire     [31:0]      vedic16_output2_w;
wire     [31:0]      vedic16_output3_w;
wire     [31:0]      vedic16_output4_w;


wire    [31:0]      temp1_w;
assign      temp1_w = {16'b0 , vedic16_output1_w[31:16]};  

wire    [47:0]      temp2_w;
assign      temp2_w = {16'b0 , vedic16_output3_w};

wire    [47:0]      temp3_w;
assign      temp3_w = {vedic16_output4_w , 16'b0};

wire    [47:0]      temp4_w;
assign      temp4_w = {16'b0 , toplam1_w};


assign  toplam1_w = temp1_w + vedic16_output2_w;

assign  toplam2_w = temp2_w + temp3_w;

assign  toplam3_w = temp4_w + toplam2_w;


vedic_16x16 a(variable1_ns,variable2_ns,vedic16_output1_w);
vedic_16x16 b(variable3_ns,variable2_ns,vedic16_output2_w);
vedic_16x16 c(variable1_ns,variable4_ns,vedic16_output3_w);
vedic_16x16 d(variable3_ns,variable4_ns,vedic16_output4_w);

always @(*) begin
    
    sonuc_ns = sonuc_r;
    variable1_ns = variable1_r;
    variable2_ns = variable2_r;
    variable3_ns = variable3_r;
    variable4_ns = variable4_r;
    carpim_hazir_ns = carpim_hazir_r;

    sayi1_neg_mi_ns = sayi1_neg_mi_r;
    sayi2_neg_mi_ns = sayi2_neg_mi_r;
    
    if(blok_aktif_i) begin
        
        if(carpim_unsigned_i) begin

            variable1_ns = sayi1_i[15:0];                   
            variable2_ns = sayi2_i[15:0];                       
            variable3_ns = sayi1_i[31:16];                  
            variable4_ns = sayi2_i[31:16];                  
                                                                 
            sonuc_ns = {toplam3_w,vedic16_output1_w[15:0]};                        
            carpim_hazir_ns = 1'b1;                             
            
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
            
            variable1_ns = poz_sayi1_w[15:0];                   
            variable2_ns = poz_sayi2_w[15:0];                       
            variable3_ns = poz_sayi1_w[31:16];                  
            variable4_ns = poz_sayi2_w[31:16];                  
                                                                 
            sonuc_ns = {toplam3_w,vedic16_output1_w[15:0]};                        
            carpim_hazir_ns = 1'b1;                             
        end
    end      
end 

always @(posedge clk_i) begin
    if(rst_i == 1'b0) begin

        sonuc_r <= 64'd0;
        carpim_hazir_r <= 1'b0;  
        variable1_r <= 16'd0;            
        variable2_r <= 16'd0;            
        variable3_r <= 16'd0;            
        variable4_r <= 16'd0;            

    end 
    else begin
        sonuc_r <= sonuc_ns;
        carpim_hazir_r <= carpim_hazir_ns;  
        variable1_r <= variable1_ns;      
        variable2_r <= variable2_ns; 
        sayi1_neg_mi_r <= sayi1_neg_mi_ns;
        sayi2_neg_mi_r <= sayi2_neg_mi_ns;    
    end
end

assign  sonuc_o = carpim_unsigned_i ? sonuc_ns :(sayi2_neg_mi_ns == 1'b1 && sayi1_neg_mi_ns == 1'b0) ? (~sonuc_ns+1) : (sayi2_neg_mi_ns == 1'b0 && sayi1_neg_mi_ns == 1'b1) ? (~sonuc_ns+1) : sonuc_ns ;
assign  carpim_hazir_o = carpim_hazir_r;
assign  durdur_o = 1'b0;

endmodule


