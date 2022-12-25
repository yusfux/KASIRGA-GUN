`timescale 1ns / 1ps


`include "operations.vh"

/*
    JUMP flash gerektirebilir * -> denetim birimine sinyal gitmeli
    JUMP geldiginde clock'ta program sayacý üreticisine adres gonderimi yapildi
*/

module AMB(
    input                   clk_i,
    input                   rst_i, // ayarlanmali
    input       [31:0]      anlik_i,
    input       [31:0]      yazmac_degeri1_i,
    input       [31:0]      yazmac_degeri2_i,
    input       [31:0]      adres_i,
    input       [5:0]       islem_kodu_i,
            
    output      [31:0]      sonuc_o,
    output      [31:0]      adres_o,            //jal ve jalr buyru?u için 
    output                  esit_mi_o,  
    output                  buyuk_mu_o            
);

reg     [31:0]  sonuc_r      =    0;
reg     [31:0]  sonuc_r_next      =    0;
reg     [31:0]  adres_r      =    0;        
reg     [31:0]  adres_r_next =    0;        
        
assign esit_mi_o = (yazmac_degeri1_i == yazmac_degeri2_i);
assign buyuk_mu_o  =  (yazmac_degeri1_i > yazmac_degeri2_i);
     
always @(*) begin
  
   sonuc_r_next = sonuc_r;
   adres_r_next = adres_r;
   
   case(islem_kodu_i)
        
        // aritmatik i?lemler 
       `ALU_ADD     :   sonuc_r_next     =   yazmac_degeri1_i + yazmac_degeri2_i;
       
       `ALU_ADDI    :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
       
       `ALU_MUL     :   sonuc_r_next     =   yazmac_degeri1_i * yazmac_degeri2_i; 
  
       `ALU_MULH    :   sonuc_r_next     =   (yazmac_degeri1_i * yazmac_degeri2_i) >> 32; 
  
       `ALU_MULHSU  :   sonuc_r_next     =   ($signed(yazmac_degeri1_i) * $unsigned(yazmac_degeri2_i)) >> 32; 
    
       `ALU_MULHU   :   sonuc_r_next     =   ($unsigned(yazmac_degeri1_i) * $unsigned(yazmac_degeri2_i)) >> 32; 
  
       `ALU_DIV     :   sonuc_r_next     =   yazmac_degeri1_i / yazmac_degeri2_i;
       
       `ALU_DIVU    :   sonuc_r_next     =   $unsigned(yazmac_degeri1_i) / $unsigned(yazmac_degeri2_i);   
       
       `ALU_REM     :   sonuc_r_next     =   yazmac_degeri1_i % yazmac_degeri2_i;
       
       `ALU_REMU    :   sonuc_r_next     =   $unsigned(yazmac_degeri1_i) % $unsigned(yazmac_degeri2_i); 
       
       `ALU_AUIPC   :   sonuc_r_next     =   adres_i + (anlik_i[19:0]<<12);   
       
       `ALU_LUI     :   sonuc_r_next     =   anlik_i[19:0] << 12;
                 
       `ALU_JAL     : begin  
                sonuc_r_next     =   adres_i + 4; 
                adres_r_next     =   adres_i + anlik_i; 
        end        
       `ALU_JALR    : begin  
                 sonuc_r_next     =   adres_i + 4;      
                 adres_r_next     =   yazmac_degeri1_i + anlik_i;                                 
        end
       `MEM_LB      :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i; 
    
       `MEM_LH      :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
    
       `MEM_LW      :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
  
       `MEM_LBU     :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
  
       `MEM_LHU     :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i; 
  
       `MEM_SB      :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
 
       `MEM_SH      :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
 
       `MEM_SW      :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
 
       `ALU_SUB     :   sonuc_r_next     =   yazmac_degeri1_i - yazmac_degeri2_i;
 
       
       
       // mantik islemleri
       `ALU_AND     :   sonuc_r_next = yazmac_degeri1_i & yazmac_degeri2_i;
 
       `ALU_ANDI    :   sonuc_r_next = yazmac_degeri1_i & anlik_i;
 
       `ALU_OR      :   sonuc_r_next = yazmac_degeri1_i | yazmac_degeri2_i;
 
       `ALU_XOR     :   sonuc_r_next = yazmac_degeri1_i ^ yazmac_degeri2_i; 
 
       `ALU_ORI     :   sonuc_r_next = yazmac_degeri1_i | anlik_i;   
 
       `ALU_XORI    :   sonuc_r_next = yazmac_degeri1_i ^ anlik_i;
        
       `ALU_SLLI    :   sonuc_r_next = yazmac_degeri1_i << anlik_i[4:0];
  
       `ALU_SRLI    :   sonuc_r_next = $signed({1'b0, yazmac_degeri1_i}) >>> anlik_i[4:0];
 
       `ALU_SRAI    :   sonuc_r_next = {(anlik_i[31])>>(anlik_i[4:0]),(yazmac_degeri1_i >> anlik_i[4:0])};
 
       `ALU_SLL    :    sonuc_r_next = yazmac_degeri1_i << yazmac_degeri2_i[4:0];
 
       `ALU_SLT     :   sonuc_r_next = $signed(yazmac_degeri1_i) < $signed(yazmac_degeri2_i);
 
       `ALU_SLTU    :   sonuc_r_next = $unsigned(yazmac_degeri1_i) < $unsigned(yazmac_degeri2_i); 
 
       `ALU_SRL     :   sonuc_r_next = $signed({1'b0, yazmac_degeri1_i}) >>> yazmac_degeri2_i[4:0]  ; 

       `ALU_SRA     :   sonuc_r_next = $signed({yazmac_degeri1_i[31], yazmac_degeri1_i}) >>> yazmac_degeri2_i[4:0];

       `ALU_SLTI    :   sonuc_r_next = $signed(yazmac_degeri1_i) < $signed(anlik_i);

       `ALU_SLTIU   :   sonuc_r_next = $unsigned(yazmac_degeri1_i) < $unsigned(anlik_i) ; 

                 
   endcase 
end

    always @(posedge clk_i)begin
    if(rst_i) begin
        sonuc_r <= 0;
        adres_r <= 0;
    end
    else begin
        sonuc_r <= sonuc_r_next;
        adres_r <= adres_r_next;
    end
    
    end
    
assign sonuc_o       =   sonuc_r;
assign adres_o       =   adres_r;    

endmodule