
`timescale 1ns / 1ps

/*module full_adder(in0, in1, cin, out, cout);
	input in0, in1, cin;
	output out, cout;

	assign out = in0 ^ in1 ^ cin;
	assign cout = ((in0 ^ in1) & cin) | (in0 & in1);
endmodule
*/
module ripple_carry_adder_48(
        
    
    input   [47:0]  sayi1_i,
    input   [47:0]  sayi2_i,
    output  [47:0]  sonuc_o
);

wire c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,cout;
wire [47:0] sonuc_w;
full_adder fa0 (sayi1_i[0] ,  sayi2_i[0], 1'b0, sonuc_w[0], c1);
full_adder fa1 (sayi1_i[1] ,  sayi2_i[1],  c1,  sonuc_w[1], c2);
full_adder fa2 (sayi1_i[2] ,  sayi2_i[2],  c2,  sonuc_w[2], c3);
full_adder fa3 (sayi1_i[3] ,  sayi2_i[3],  c3,  sonuc_w[3], c4);      
full_adder fa4 (sayi1_i[4] ,  sayi2_i[4],  c4,  sonuc_w[4], c5);
full_adder fa5 (sayi1_i[5] ,  sayi2_i[5],  c5,  sonuc_w[5], c6);     
full_adder fa6 (sayi1_i[6] ,  sayi2_i[6],  c6,  sonuc_w[6], c7);
full_adder fa7 (sayi1_i[7] ,  sayi2_i[7],  c7,  sonuc_w[7], c8);      
full_adder fa8 (sayi1_i[8] ,  sayi2_i[8],  c8,  sonuc_w[8], c9);
full_adder fa9 (sayi1_i[9] ,  sayi2_i[9],  c9,  sonuc_w[9], c10);
full_adder fa10(sayi1_i[10], sayi2_i[10], c10,  sonuc_w[10],c11);
full_adder fa11(sayi1_i[11], sayi2_i[11], c11,  sonuc_w[11],c12);        
full_adder fa12(sayi1_i[12], sayi2_i[12], c12,  sonuc_w[12],c13);
full_adder fa13(sayi1_i[13], sayi2_i[13], c13,  sonuc_w[13],c14);  
full_adder fa14(sayi1_i[14], sayi2_i[14], c14,  sonuc_w[14],c15);
full_adder fa15(sayi1_i[15], sayi2_i[15], c15,  sonuc_w[15],c16);                              
full_adder fa16(sayi1_i[16], sayi2_i[16], c16,  sonuc_w[16],c17);
full_adder fa17(sayi1_i[17], sayi2_i[17], c17,  sonuc_w[17],c18);
full_adder fa18(sayi1_i[18], sayi2_i[18], c18,  sonuc_w[18],c19);
full_adder fa19(sayi1_i[19], sayi2_i[19], c19,  sonuc_w[19],c20);
full_adder fa20(sayi1_i[20], sayi2_i[20], c20,  sonuc_w[20],c21);        
full_adder fa21(sayi1_i[21], sayi2_i[21], c21,  sonuc_w[21],c22);        
full_adder fa22(sayi1_i[22], sayi2_i[22], c22,  sonuc_w[22],c23);        
full_adder fa23(sayi1_i[23], sayi2_i[23], c23,  sonuc_w[23],c24);        
full_adder fa24(sayi1_i[24], sayi2_i[24], c24,  sonuc_w[24],c25);        
full_adder fa25(sayi1_i[25], sayi2_i[25], c25,  sonuc_w[25],c26);        
full_adder fa26(sayi1_i[26], sayi2_i[26], c26,  sonuc_w[26],c27);                                 
full_adder fa27(sayi1_i[27], sayi2_i[27], c27,  sonuc_w[27],c28);        
full_adder fa28(sayi1_i[28], sayi2_i[28], c28,  sonuc_w[28],c29);        
full_adder fa29(sayi1_i[29], sayi2_i[29], c29,  sonuc_w[29],c30);        
full_adder fa30(sayi1_i[30], sayi2_i[30], c30,  sonuc_w[30],c31);        
full_adder fa31(sayi1_i[31], sayi2_i[31], c31,  sonuc_w[31],c32);        
full_adder fa32(sayi1_i[32], sayi2_i[32], c32,  sonuc_w[32],c33);        
full_adder fa33(sayi1_i[33], sayi2_i[33], c33,  sonuc_w[33],c34);        
full_adder fa34(sayi1_i[34], sayi2_i[34], c34,  sonuc_w[34],c35);        
full_adder fa35(sayi1_i[35], sayi2_i[35], c35,  sonuc_w[35],c36);        
full_adder fa36(sayi1_i[36], sayi2_i[36], c36,  sonuc_w[36],c37);        
full_adder fa37(sayi1_i[37], sayi2_i[37], c37,  sonuc_w[37],c38);        
full_adder fa38(sayi1_i[38], sayi2_i[38], c38,  sonuc_w[38],c39);        
full_adder fa39(sayi1_i[39], sayi2_i[39], c39,  sonuc_w[39],c40);        
full_adder fa40(sayi1_i[40], sayi2_i[40], c40,  sonuc_w[40],c41);        
full_adder fa41(sayi1_i[41], sayi2_i[41], c41,  sonuc_w[41],c42);        
full_adder fa42(sayi1_i[42], sayi2_i[42], c42,  sonuc_w[42],c43);        
full_adder fa43(sayi1_i[43], sayi2_i[43], c43,  sonuc_w[43],c44);        
full_adder fa44(sayi1_i[44], sayi2_i[44], c44,  sonuc_w[44],c45);        
full_adder fa45(sayi1_i[45], sayi2_i[45], c45,  sonuc_w[45],c46);        
full_adder fa46(sayi1_i[46], sayi2_i[46], c46,  sonuc_w[46],c47);        
full_adder fa47(sayi1_i[47], sayi2_i[47], c47,  sonuc_w[47],cout);        

assign  sonuc_o = sonuc_w;
endmodule
/*
module ripple_carry_adder_32(
        
    
    input   [31:0]  sayi1_i,
    input   [31:0]  sayi2_i,
    output  [31:0]  sonuc_o
);


wire c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,cout;
wire [31:0] sonuc_w;
full_adder fa0 (sayi1_i[0] ,  sayi2_i[0], 1'b0, sonuc_w[0], c1);
full_adder fa1 (sayi1_i[1] ,  sayi2_i[1],  c1,  sonuc_w[1], c2);
full_adder fa2 (sayi1_i[2] ,  sayi2_i[2],  c2,  sonuc_w[2], c3);
full_adder fa3 (sayi1_i[3] ,  sayi2_i[3],  c3,  sonuc_w[3], c4);      
full_adder fa4 (sayi1_i[4] ,  sayi2_i[4],  c4,  sonuc_w[4], c5);
full_adder fa5 (sayi1_i[5] ,  sayi2_i[5],  c5,  sonuc_w[5], c6);     
full_adder fa6 (sayi1_i[6] ,  sayi2_i[6],  c6,  sonuc_w[6], c7);
full_adder fa7 (sayi1_i[7] ,  sayi2_i[7],  c7,  sonuc_w[7], c8);      
full_adder fa8 (sayi1_i[8] ,  sayi2_i[8],  c8,  sonuc_w[8], c9);
full_adder fa9 (sayi1_i[9] ,  sayi2_i[9],  c9,  sonuc_w[9], c10);
full_adder fa10(sayi1_i[10], sayi2_i[10], c10,  sonuc_w[10],c11);
full_adder fa11(sayi1_i[11], sayi2_i[11], c11,  sonuc_w[11],c12);        
full_adder fa12(sayi1_i[12], sayi2_i[12], c12,  sonuc_w[12],c13);
full_adder fa13(sayi1_i[13], sayi2_i[13], c13,  sonuc_w[13],c14);  
full_adder fa14(sayi1_i[14], sayi2_i[14], c14,  sonuc_w[14],c15);
full_adder fa15(sayi1_i[15], sayi2_i[15], c15,  sonuc_w[15],c16);                              
full_adder fa16(sayi1_i[16], sayi2_i[16], c16,  sonuc_w[16],c17);
full_adder fa17(sayi1_i[17], sayi2_i[17], c17,  sonuc_w[17],c18);
full_adder fa18(sayi1_i[18], sayi2_i[18], c18,  sonuc_w[18],c19);
full_adder fa19(sayi1_i[19], sayi2_i[19], c19,  sonuc_w[19],c20);
full_adder fa20(sayi1_i[20], sayi2_i[20], c20,  sonuc_w[20],c21);        
full_adder fa21(sayi1_i[21], sayi2_i[21], c21,  sonuc_w[21],c22);        
full_adder fa22(sayi1_i[22], sayi2_i[22], c22,  sonuc_w[22],c23);        
full_adder fa23(sayi1_i[23], sayi2_i[23], c23,  sonuc_w[23],c24);        
full_adder fa24(sayi1_i[24], sayi2_i[24], c24,  sonuc_w[24],c25);        
full_adder fa25(sayi1_i[25], sayi2_i[25], c25,  sonuc_w[25],c26);        
full_adder fa26(sayi1_i[26], sayi2_i[26], c26,  sonuc_w[26],c27);                                 
full_adder fa27(sayi1_i[27], sayi2_i[27], c27,  sonuc_w[27],c28);        
full_adder fa28(sayi1_i[28], sayi2_i[28], c28,  sonuc_w[28],c29);        
full_adder fa29(sayi1_i[29], sayi2_i[29], c29,  sonuc_w[29],c30);        
full_adder fa30(sayi1_i[30], sayi2_i[30], c30,  sonuc_w[30],c31);        
full_adder fa31(sayi1_i[31], sayi2_i[31], c31,  sonuc_w[31],cout);        

assign  sonuc_o = sonuc_w;
endmodule
*/
module ripple_carry_adder_16(
        
    
    input   [15:0]  sayi1_i,
    input   [15:0]  sayi2_i,
    output  [15:0]  sonuc_o
);



wire c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,cout;
wire [15:0] sonuc_w;

full_adder fa0 (sayi1_i[0] ,  sayi2_i[0], 1'b0, sonuc_w[0], c1);
full_adder fa1 (sayi1_i[1] ,  sayi2_i[1],  c1,  sonuc_w[1], c2);
full_adder fa2 (sayi1_i[2] ,  sayi2_i[2],  c2,  sonuc_w[2], c3);
full_adder fa3 (sayi1_i[3] ,  sayi2_i[3],  c3,  sonuc_w[3], c4);      
full_adder fa4 (sayi1_i[4] ,  sayi2_i[4],  c4,  sonuc_w[4], c5);
full_adder fa5 (sayi1_i[5] ,  sayi2_i[5],  c5,  sonuc_w[5], c6);     
full_adder fa6 (sayi1_i[6] ,  sayi2_i[6],  c6,  sonuc_w[6], c7);
full_adder fa7 (sayi1_i[7] ,  sayi2_i[7],  c7,  sonuc_w[7], c8);      
full_adder fa8 (sayi1_i[8] ,  sayi2_i[8],  c8,  sonuc_w[8], c9);
full_adder fa9 (sayi1_i[9] ,  sayi2_i[9],  c9,  sonuc_w[9], c10);
full_adder fa10(sayi1_i[10], sayi2_i[10], c10,  sonuc_w[10],c11);
full_adder fa11(sayi1_i[11], sayi2_i[11], c11,  sonuc_w[11],c12);        
full_adder fa12(sayi1_i[12], sayi2_i[12], c12,  sonuc_w[12],c13);
full_adder fa13(sayi1_i[13], sayi2_i[13], c13,  sonuc_w[13],c14);  
full_adder fa14(sayi1_i[14], sayi2_i[14], c14,  sonuc_w[14],c15);
full_adder fa15(sayi1_i[15], sayi2_i[15], c15,  sonuc_w[15],cout);                              


assign  sonuc_o = sonuc_w ;
endmodule

module ripple_carry_adder_8(
    
    
    
    input   [7:0]  sayi1_i,
    input   [7:0]  sayi2_i,
    output  [7:0]  sonuc_o
);

reg     [7:0]      sonuc_ns;

wire c1,c2,c3,c4,c5,c6,c7,cout;
wire [7:0] sonuc_w;
full_adder fa0 (sayi1_i[0] ,  sayi2_i[0], 1'b0, sonuc_w[0], c1);
full_adder fa1 (sayi1_i[1] ,  sayi2_i[1],  c1,  sonuc_w[1], c2);
full_adder fa2 (sayi1_i[2] ,  sayi2_i[2],  c2,  sonuc_w[2], c3);
full_adder fa3 (sayi1_i[3] ,  sayi2_i[3],  c3,  sonuc_w[3], c4);      
full_adder fa4 (sayi1_i[4] ,  sayi2_i[4],  c4,  sonuc_w[4], c5);
full_adder fa5 (sayi1_i[5] ,  sayi2_i[5],  c5,  sonuc_w[5], c6);     
full_adder fa6 (sayi1_i[6] ,  sayi2_i[6],  c6,  sonuc_w[6], c7);
full_adder fa7 (sayi1_i[7] ,  sayi2_i[7],  c7,  sonuc_w[7], cout);      


assign  sonuc_o = sonuc_w;
endmodule

module ripple_carry_adder_4(
            
    input   [3:0]   sayi1_i,
    input   [3:0]   sayi2_i,
    output  [3:0]   sonuc_o
);


wire c1,c2,c3,cout;
wire [3:0] sonuc_w;

full_adder fa0 (sayi1_i[0] ,  sayi2_i[0], 1'b0, sonuc_w[0], c1);
full_adder fa1 (sayi1_i[1] ,  sayi2_i[1],  c1,  sonuc_w[1], c2);
full_adder fa2 (sayi1_i[2] ,  sayi2_i[2],  c2,  sonuc_w[2], c3);
full_adder fa3 (sayi1_i[3] ,  sayi2_i[3],  c3,  sonuc_w[3], cout);     
 

assign  sonuc_o = sonuc_w;
endmodule


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
    wire [31:0]q5;
    wire [31:0]q6;
    // using 4 8x8 multipliers
    vedic_8x8 z1(a[7:0],b[7:0],q0[15:0]);
    vedic_8x8 z2(a[15:8],b[7:0],q1[15:0]);
    vedic_8x8 z3(a[7:0],b[15:8],q2[15:0]);
    vedic_8x8 z4(a[15:8],b[15:8],q3[15:0]);
    
    // stage 1 adders 
    ripple_carry_adder_16 m1( q1[15:0], temp1,q4);
    ripple_carry_adder m2( {8'b0,temp2}, {8'b0,temp3}, q5);
    ripple_carry_adder m3( {8'b0,temp4}, q5 , q6);
    
    assign temp1 ={8'b0,q0[15:8]};
    assign temp2 ={8'b0,q2[15:0]};
    assign temp3 ={q3[15:0],8'b0};
    assign temp4={8'b0,q4[15:0]};
    
    //stage 2 adder
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
    wire [15:0]q5;
    wire [15:0]q6;
    // using 4 4x4 multipliers
    vedic_4x4 z1(a[3:0],b[3:0],q0[7:0]);
    vedic_4x4 z2(a[7:4],b[3:0],q1[7:0]);
    vedic_4x4 z3(a[3:0],b[7:4],q2[7:0]);
    vedic_4x4 z4(a[7:4],b[7:4],q3[7:0]);

    ripple_carry_adder_8 m3( temp1, q1[7:0],q4);
    ripple_carry_adder_16 m4( {4'b0,temp2}, {4'b0,temp3}, q5);
    ripple_carry_adder_16 m5( {4'b0,temp4}, q5, q6);
    
    // stage 1 adders 
    assign temp1 ={4'b0,q0[7:4]};
    assign temp2 ={4'b0,q2[7:0]};
    assign temp3 ={q3[7:0],4'b0};
    assign temp4={4'b0,q4[7:0]};
    // stage 2 adder
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
    wire [7:0]q5;
    wire [7:0]q6;
    // using 4 2x2 multipliers
    vedic_2x2 z1(a[1:0],b[1:0],q0[3:0]);
    vedic_2x2 z2(a[3:2],b[1:0],q1[3:0]);
    vedic_2x2 z3(a[1:0],b[3:2],q2[3:0]);
    vedic_2x2 z4(a[3:2],b[3:2],q3[3:0]);
    // stage 1 adders 

    ripple_carry_adder_4 m5( q1[3:0], temp1,q4 );
    ripple_carry_adder_8 m6( {2'b0,temp2}, {2'b0,temp3}, q5);
    ripple_carry_adder_8 m7( {2'b0,temp4}, q5 , q6);
        
    assign temp1 ={2'b0,q0[3:2]};
    assign temp2 ={2'b0,q2[3:0]};
    assign temp3 ={q3[3:0],2'b0};
    assign temp4={2'b0,q4[3:0]};
    // stage 2 adder 
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
        
    input           blok_aktif_i,
    
    input           carpim_unsigned_i,
    input           carpim_mulhsu_i,
                 
    input   [31:0]  sayi1_i,
    input   [31:0]  sayi2_i, 
    output  [63:0]  sonuc_o
        
);

reg     [63:0]      sonuc_r;
              

wire    [31:0]      poz_sayi1_w;
assign  poz_sayi1_w = (sayi1_i[31] == 1'b1) ? (~sayi1_i + 1) : sayi1_i;

wire    [31:0]      poz_sayi2_w;
assign  poz_sayi2_w = (sayi2_i[31] == 1'b1) ? (~sayi2_i + 1) : sayi2_i;

reg                 sayi1_neg_mi_r;

reg                 sayi2_neg_mi_r;

reg     [15:0]      variable1_r;

reg     [15:0]      variable2_r;

reg     [15:0]      variable3_r;

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

ripple_carry_adder m1( temp1_w, vedic16_output2_w , toplam1_w);

ripple_carry_adder_48 m2( temp2_w, temp3_w , toplam2_w);

ripple_carry_adder_48 m3( temp4_w, toplam2_w , toplam3_w);

vedic_16x16 a(variable1_r,variable2_r,vedic16_output1_w);
vedic_16x16 b(variable3_r,variable2_r,vedic16_output2_w);
vedic_16x16 c(variable1_r,variable4_r,vedic16_output3_w);
vedic_16x16 d(variable3_r,variable4_r,vedic16_output4_w);

always @(*) begin
    
    sonuc_r = 0;
    variable1_r = 0;
    variable2_r = 0;
    variable3_r = 0;
    variable4_r = 0;
    
    sayi1_neg_mi_r = 0;
    sayi2_neg_mi_r = 0;
    
    if(blok_aktif_i) begin
        
        if(carpim_unsigned_i) begin

            variable1_r = sayi1_i[15:0];                   
            variable2_r = sayi2_i[15:0];                       
            variable3_r = sayi1_i[31:16];                  
            variable4_r = sayi2_i[31:16];                  
                                                                 
            sonuc_r = {toplam3_w,vedic16_output1_w[15:0]};                        
            
        end 
        else if(carpim_mulhsu_i) begin

            if(sayi1_i[31] == 1'b1) begin
                sayi1_neg_mi_r = 1'b1;
            end
            else begin
                sayi1_neg_mi_r = 1'b0;            
            end

            variable1_r = poz_sayi1_w[15:0];                   
            variable2_r = sayi2_i[15:0];                       
            variable3_r = poz_sayi1_w[31:16];                  
            variable4_r = sayi2_i[31:16];                  

            sonuc_r = {toplam3_w,vedic16_output1_w[15:0]};                        
            
        end
        else begin
            if(sayi1_i[31] == 1'b1) begin
                sayi1_neg_mi_r = 1'b1;
            end
            else begin
                sayi1_neg_mi_r = 1'b0;            
            end
            if(sayi2_i[31] == 1'b1) begin
                sayi2_neg_mi_r = 1'b1;            
            end
            else begin
                sayi2_neg_mi_r = 1'b0;                    
            end
            
            variable1_r = poz_sayi1_w[15:0];                   
            variable2_r = poz_sayi2_w[15:0];                       
            variable3_r = poz_sayi1_w[31:16];                  
            variable4_r = poz_sayi2_w[31:16];                  
                                                                 
            sonuc_r = {toplam3_w,vedic16_output1_w[15:0]};                        
        end
    end      
end 

assign  sonuc_o = carpim_unsigned_i ? sonuc_r : carpim_mulhsu_i ? ((sayi1_neg_mi_r == 1'b1) ? (~sonuc_r+1) : sonuc_r ) : (sayi2_neg_mi_r == 1'b1 && sayi1_neg_mi_r == 1'b0) ? (~sonuc_r+1) : (sayi2_neg_mi_r == 1'b0 && sayi1_neg_mi_r == 1'b1) ? (~sonuc_r+1) : sonuc_r ;

endmodule


