`timescale 1ns / 1ps

module ripple_carry_adder(        
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





















