`timescale 1ns / 1ps


`include "operations.vh"

/*
    JUMP flash gerektirebilir * -> denetim birimine sinyal gitmeli
    JUMP geldiginde clock'ta program sayac? ?reticisine adres gonderimi yapildi
*/

module AMB(
    input                   clk_i,
    input                   rst_i, // ayarlanmali
    input                   durdur_i,
    
    input                   AMB_aktif_i,
    input       [31:0]      anlik_i,
    input       [31:0]      yazmac_degeri1_i,
    input       [31:0]      yazmac_degeri2_i,
    input       [31:0]      adres_i,
    input       [5:0]       islem_kodu_i,
    
    output                  AMB_hazir_o,
    output      [31:0]      sonuc_o,
    output      [31:0]      jal_r_adres_o,            //jal ve jalr buyru?u i?in  
    output                  jal_r_adres_gecerli_o,          
    output                  esit_mi_o,  
    output                  buyuk_mu_o,         
    output                  buyuk_mu_o_unsigned         
);

reg     [63:0]  sonuc_r               =    64'd0    ;
reg     [63:0]  sonuc_r_next          =    64'd0    ;
reg     [31:0]  adres_r               =    32'd0    ;              
reg             AMB_hazir_r           =    1'b0     ;
reg             AMB_hazir_r_next      =    1'b0     ;  
reg             jal_r_adres_gecerli_r =    1'b0      ;  

// hasana dallanma birimindeki yanlisiliklari da soylemeyi unutma
assign esit_mi_o   =  AMB_aktif_i ? (yazmac_degeri1_i == yazmac_degeri2_i) : 0;
assign buyuk_mu_o  =  AMB_aktif_i ? ($signed(yazmac_degeri1_i) > $signed(yazmac_degeri2_i)) : 0;
assign buyuk_mu_o_unsigned  =  AMB_aktif_i ? ($unsigned(yazmac_degeri1_i) > $unsigned(yazmac_degeri2_i)) : 0;
     
always @(*) begin
   /* durdur_i gelirse icerideki degerler korunmali,
   ama su anda tek cevrimde yapiyor, disariya nop verilmeli */
   sonuc_r_next      =   sonuc_r;
   adres_r           =   32'd0;
   jal_r_adres_gecerli_r = 1'b0;
   AMB_hazir_r_next  =   1'b0;
   
   if(!durdur_i) begin
       if(AMB_aktif_i) begin
           AMB_hazir_r_next = 1'b1;
           case(islem_kodu_i)
                
                // aritmatik i?lemler 
               `ALU_ADD     :   sonuc_r_next     =   yazmac_degeri1_i + yazmac_degeri2_i;
               
               `ALU_ADDI    :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
               
               `ALU_MUL     :   sonuc_r_next     =   $signed(yazmac_degeri1_i) * $signed(yazmac_degeri2_i); 
          
               `ALU_MULH    :   sonuc_r_next     =   ($signed(yazmac_degeri1_i) * $signed(yazmac_degeri2_i)) >> 32;
                          
               `ALU_MULHSU  :   sonuc_r_next     =   ({{6'd32{yazmac_degeri1_i[31]}},yazmac_degeri1_i} *  {{6'd32{1'b0}},yazmac_degeri2_i}) >> 32;
                          
               `ALU_MULHU   :   sonuc_r_next     =   ($unsigned(yazmac_degeri1_i) * $unsigned(yazmac_degeri2_i)) >> 32;
                               
               `ALU_DIV     :   sonuc_r_next     =   $signed(yazmac_degeri1_i) / $signed(yazmac_degeri2_i);
               
               `ALU_DIVU    :   sonuc_r_next     =   $unsigned(yazmac_degeri1_i) / $unsigned(yazmac_degeri2_i);

               `ALU_REM     :   sonuc_r_next     =   yazmac_degeri1_i % yazmac_degeri2_i;
               
               `ALU_REMU    :   sonuc_r_next     =   $unsigned(yazmac_degeri1_i) % $unsigned(yazmac_degeri2_i); 
               
               `ALU_AUIPC   :   sonuc_r_next     =   adres_i + anlik_i;
               
               `ALU_LUI     :   sonuc_r_next     =   anlik_i;
                         
               `ALU_JAL     : begin  
                         sonuc_r_next     =   adres_i + 4; 
                         adres_r     =   adres_i + anlik_i; 
                         jal_r_adres_gecerli_r = 1'b1;
                end        
               `ALU_JALR    : begin  
                         sonuc_r_next     =   adres_i + 4;      
                         adres_r     =   yazmac_degeri1_i + anlik_i;     
                         jal_r_adres_gecerli_r = 1'b1;                            
                end
                
               `ALU_MEM     :   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
               
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
         
               `ALU_SRAI    :   sonuc_r_next = $signed(yazmac_degeri1_i) >>> anlik_i[4:0];
         
               `ALU_SLL    :    sonuc_r_next = yazmac_degeri1_i << yazmac_degeri2_i[4:0];
         
               `ALU_SLT     :   sonuc_r_next = (yazmac_degeri1_i) < (yazmac_degeri2_i);
         
               `ALU_SLTU    :   sonuc_r_next = $unsigned(yazmac_degeri1_i) < $unsigned(yazmac_degeri2_i); 
         
               `ALU_SRL     :   sonuc_r_next = $signed({1'b0, yazmac_degeri1_i}) >>> yazmac_degeri2_i[4:0]  ; 
        
               `ALU_SRA     :   sonuc_r_next = $signed({yazmac_degeri1_i[31], yazmac_degeri1_i}) >>> yazmac_degeri2_i[4:0];
        
               `ALU_SLTI    :   sonuc_r_next = $signed(yazmac_degeri1_i) < $signed(anlik_i);
        
               `ALU_SLTIU   :   sonuc_r_next = $unsigned(yazmac_degeri1_i) < $unsigned(anlik_i) ; 
        
                         
           endcase 
        end
    end
end

always @(posedge clk_i)begin
if(!rst_i) begin // rst_i 0 ise reset
    sonuc_r             <=   0;
    AMB_hazir_r         <=   0;
    
end

else if (!durdur_i) begin
    AMB_hazir_r        <=    AMB_hazir_r_next;
    sonuc_r            <=    sonuc_r_next;
end

end

assign sonuc_o               =   sonuc_r [31:0];
assign jal_r_adres_o         =   adres_r;    
assign AMB_hazir_o           =   AMB_hazir_r;
assign jal_r_adres_gecerli_o = jal_r_adres_gecerli_r;

endmodule