
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
    input                   sikistirilmis_mi_i,
    
    input       [2:0]       dallanma_buy_turu_i,
    input                   dallanma_aktif_i,
    
    output                  AMB_hazir_o,
    output      [31:0]      sonuc_o,
    output      [31:0]      jal_r_adres_o,            //jal ve jalr buyru?u i?in  
    output                  jal_r_adres_gecerli_o,          
    output                  esit_mi_o,  
    output                  buyuk_mu_o,         
    output                  buyuk_mu_o_unsigned,
    
    output                  stall_o
);

reg     [31:0]  sonuc_r               ;
reg     [31:0]  sonuc_r_next          ;
reg     [31:0]  adres_r               ;              
reg             AMB_hazir_r           ;
reg             AMB_hazir_r_next      ;  
reg             jal_r_adres_gecerli_r ;  



reg         esit_mi_o_r;
reg         buyuk_mu_o_r;
reg         buyuk_mu_o_unsigned_r;

assign esit_mi_o   = (yazmac_degeri1_i == yazmac_degeri2_i);
assign buyuk_mu_o  = ($signed(yazmac_degeri1_i) > $signed(yazmac_degeri2_i));
assign buyuk_mu_o_unsigned  = ($unsigned(yazmac_degeri1_i) > $unsigned(yazmac_degeri2_i));

reg  [31:0] aritmetik_sayi1_r;
reg  [31:0] aritmetik_sayi2_r;

reg         cikarma_aktif_r;
wire [31:0] cikarma_sonuc_w;

reg         carpma_aktif_r;
reg         carpim_unsigned_r;
reg         carpim_mulhsu_r;
wire        carpim_sonuc_hazir_w;

reg         bolme_istek_r;
wire        bolme_sonuc_hazir_w;
reg         bolme_signed_r;

wire [31:0] toplama_sonuc_w;
wire [63:0] carpma_sonuc_w;
wire [31:0] bolme_sonuc_w;
wire [31:0] bolme_kalan_w;

reg         stall_r;
assign      stall_o = stall_r;

ripple_carry_adder toplayici(
    .sayi1_i(aritmetik_sayi1_r),
    .sayi2_i(aritmetik_sayi2_r),
    .sonuc_o(toplama_sonuc_w)
);


pipelined_multiplier carpici(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .blok_aktif_i(carpma_aktif_r),
    .carpim_unsigned_i(carpim_unsigned_r),
    .carpim_mulhsu_i(carpim_mulhsu_r),
    .sayi1_i(aritmetik_sayi1_r),
    .sayi2_i(aritmetik_sayi2_r), 
    .sonuc_o(carpma_sonuc_w),
    .carpim_hazir_o(carpim_sonuc_hazir_w)
);

bolme bolme_algoritmasi(
    .clk_i(clk_i),
    .rst_i(rst_i),
    
    .istek_i(bolme_istek_r), 
    .sign_i(bolme_signed_r), //unsigned:0, signed:1
    .bolunen_i(aritmetik_sayi1_r),
    .bolen_i(aritmetik_sayi2_r),
    
    .bolum_o(bolme_sonuc_w),
    .kalan_o(bolme_kalan_w),
    .result_ready_o(bolme_sonuc_hazir_w)
);

cikarma cikarma_islemi(
    .blok_aktif_i(cikarma_aktif_r),
    .sayi1_i(aritmetik_sayi1_r),
    .sayi2_i(aritmetik_sayi2_r),
    .sonuc_o(cikarma_sonuc_w)
);

always @(*) begin
   /* durdur_i gelirse icerideki degerler korunmali,
   ama su anda tek cevrimde yapiyor, disariya nop verilmeli */
   sonuc_r_next          =   sonuc_r;
   adres_r               =   32'd0;
   jal_r_adres_gecerli_r =   1'b0;
   AMB_hazir_r_next      =   1'b0;
   aritmetik_sayi1_r     =   32'd0;
   aritmetik_sayi2_r     =   32'd0;
   
   carpma_aktif_r    = 1'b0; 
   carpim_unsigned_r = 1'b0;
   bolme_istek_r     = 1'b0;
   bolme_signed_r    = 1'b0;
   stall_r           = 1'b0;
   carpim_mulhsu_r   = 1'b0;
   
   esit_mi_o_r            = 1'b0;
   buyuk_mu_o_r           = 1'b0;         
   buyuk_mu_o_unsigned_r  = 1'b0;
   
   cikarma_aktif_r        = 1'b0;
   
   if(!durdur_i) begin
       if(AMB_aktif_i) begin
           
           case(islem_kodu_i)
                
                // aritmetik islemler 
               `ALU_ADD     :   begin //sonuc_r_next     =   yazmac_degeri1_i + yazmac_degeri2_i;
                   aritmetik_sayi1_r = yazmac_degeri1_i;
                   aritmetik_sayi2_r = yazmac_degeri2_i;
                   sonuc_r_next      = toplama_sonuc_w;
                   AMB_hazir_r_next = 1'b1;
               end
               
               `ALU_ADDI    :   begin //sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
                   aritmetik_sayi1_r = yazmac_degeri1_i;
                   aritmetik_sayi2_r = anlik_i;
                   sonuc_r_next      = toplama_sonuc_w;
                   AMB_hazir_r_next = 1'b1;
               end
               
               `ALU_MUL     :   begin 
                    sonuc_r_next     =   $signed(yazmac_degeri1_i) * $signed(yazmac_degeri2_i);
//                    sonuc_r_next = 1;
                    AMB_hazir_r_next = 1'b1;
                   
//                   carpma_aktif_r    = 1'b1;
//                   carpim_unsigned_r = 1'b0;
//                   aritmetik_sayi1_r = yazmac_degeri1_i;
//                   aritmetik_sayi2_r = yazmac_degeri2_i;
                    
//                   if(!carpim_sonuc_hazir_w) begin
//                        stall_r     = 1'b1;   
//                   end
//                   else begin
//                        stall_r           = 1'b0;
//                        sonuc_r_next      = carpma_sonuc_w[31:0];
//                        AMB_hazir_r_next = 1'b1;
//                    end

               end 
          
               `ALU_MULH    :   begin 
                    sonuc_r_next     =   ($signed(yazmac_degeri1_i) * $signed(yazmac_degeri2_i)) >> 32;
//                   sonuc_r_next = 2;
                   AMB_hazir_r_next = 1'b1;
                   
//                   carpma_aktif_r    = 1'b1;
//                   carpim_unsigned_r = 1'b0;
//                   aritmetik_sayi1_r = yazmac_degeri1_i;
//                   aritmetik_sayi2_r = yazmac_degeri2_i;
                    
//                   if(!carpim_sonuc_hazir_w) begin
//                        stall_r     = 1'b1;   
//                    end
//                    else begin
//                        stall_r           = 1'b0;
//                        sonuc_r_next      = carpma_sonuc_w[63:32];
//                        AMB_hazir_r_next = 1'b1;
//                    end
                    
               end
                          
               `ALU_MULHSU  :   begin 
                    sonuc_r_next     =   ({{6'd32{yazmac_degeri1_i[31]}},yazmac_degeri1_i} *  {{6'd32{1'b0}},yazmac_degeri2_i}) >> 32;	
//                    sonuc_r_next = 3;
                    AMB_hazir_r_next = 1'b1;
                        
//                    carpma_aktif_r    = 1'b1;
//                    carpim_unsigned_r = 1'b0; 
//                    carpim_mulhsu_r   = 1'b1;
//                    aritmetik_sayi1_r = yazmac_degeri1_i;
//                    aritmetik_sayi2_r = yazmac_degeri2_i;	  
                    
//                    if(!carpim_sonuc_hazir_w) begin
//                        stall_r     = 1'b1;   
//                    end
//                    else begin
//                        stall_r           = 1'b0;
//                        sonuc_r_next      = carpma_sonuc_w[63:32];
//                        AMB_hazir_r_next = 1'b1;
//                    end
               end
               
			   `ALU_MULHU   :   begin 
			        sonuc_r_next     =   ($unsigned(yazmac_degeri1_i) * $unsigned(yazmac_degeri2_i)) >> 32;
//			        sonuc_r_next = 4;
                    AMB_hazir_r_next = 1'b1;
			        
//			           carpma_aktif_r    = 1'b1;
//			           carpim_unsigned_r = 1'b1;
//                    aritmetik_sayi1_r = yazmac_degeri1_i;
//                    aritmetik_sayi2_r = yazmac_degeri2_i;
                    
//                    if(!carpim_sonuc_hazir_w) begin
//                        stall_r     = 1'b1;   
//                    end
//                    else begin
//                        stall_r           = 1'b0;
//                        sonuc_r_next      = carpma_sonuc_w[63:32];
//                        AMB_hazir_r_next = 1'b1;
//                    end

               end
			   `ALU_DIV     :   begin        //sonuc_r_next     =   $signed(yazmac_degeri1_i) / $signed(yazmac_degeri2_i);
			           bolme_istek_r     = 1'b1;
			           bolme_signed_r    = 1'b1;
			           aritmetik_sayi1_r = yazmac_degeri1_i;
                    aritmetik_sayi2_r = yazmac_degeri2_i;
                    
                    if(!bolme_sonuc_hazir_w) begin
                        stall_r     = 1'b1;   
                    end
                    else begin
                        stall_r           = 1'b0;
                        sonuc_r_next      = bolme_sonuc_w;
                        AMB_hazir_r_next = 1'b1;
                    end
			   end
               
               `ALU_DIVU    :   begin        //sonuc_r_next     =   $unsigned(yazmac_degeri1_i) / $unsigned(yazmac_degeri2_i);
                    bolme_istek_r     = 1'b1;
                    bolme_signed_r    = 1'b0;
                    aritmetik_sayi1_r = yazmac_degeri1_i;
                    aritmetik_sayi2_r = yazmac_degeri2_i;
                           
                    if(!bolme_sonuc_hazir_w) begin
                        stall_r     = 1'b1; 
                    end
                    else begin
                        stall_r     = 1'b0;
                        sonuc_r_next      = bolme_sonuc_w;
                        AMB_hazir_r_next = 1'b1;
                    end
               end

               `ALU_REM     :   begin //sonuc_r_next     =   $signed(yazmac_degeri1_i) % $signed(yazmac_degeri2_i);
                    bolme_istek_r     = 1'b1;
                    bolme_signed_r    = 1'b1;
                    aritmetik_sayi1_r = yazmac_degeri1_i;
                    aritmetik_sayi2_r = yazmac_degeri2_i;  
                       
                    if(!bolme_sonuc_hazir_w) begin
                        stall_r     = 1'b1; 
                    end
                    else begin
                        stall_r     = 1'b0;
                        sonuc_r_next      = bolme_kalan_w;
                        AMB_hazir_r_next = 1'b1;
                    end 
               end
               
               `ALU_REMU    :   begin //sonuc_r_next     =   $unsigned(yazmac_degeri1_i) % $unsigned(yazmac_degeri2_i); 
                    bolme_istek_r     = 1'b1;
                    bolme_signed_r    = 1'b0;
                    aritmetik_sayi1_r = yazmac_degeri1_i;
                    aritmetik_sayi2_r = yazmac_degeri2_i;
                    if(!bolme_sonuc_hazir_w) begin
                        stall_r     = 1'b1; 
                    end
                    else begin
                        stall_r     = 1'b0;
                        sonuc_r_next      = bolme_kalan_w;
                        AMB_hazir_r_next = 1'b1;
                    end
               end
               
               `ALU_AUIPC   : begin
               
                   sonuc_r_next     =   adres_i + anlik_i;
                   AMB_hazir_r_next = 1'b1;
               
               end
               `ALU_LUI     : begin
                   sonuc_r_next     =   anlik_i;
                   AMB_hazir_r_next = 1'b1;
                end          
                
               `ALU_JAL     : begin  
                   sonuc_r_next          = sikistirilmis_mi_i ? adres_i + 2 : adres_i + 4;
                   adres_r               =   adres_i + anlik_i; 
                   jal_r_adres_gecerli_r = 1'b1;
                   AMB_hazir_r_next = 1'b1;
                end        
               `ALU_JALR    : begin  
                   sonuc_r_next          = sikistirilmis_mi_i ? adres_i + 2 : adres_i + 4;      
                   adres_r               =   yazmac_degeri1_i + anlik_i;     
                   jal_r_adres_gecerli_r = 1'b1;   
                   AMB_hazir_r_next = 1'b1;                         
                end
                
               `ALU_MEM     : begin
                   sonuc_r_next     =   yazmac_degeri1_i + anlik_i;
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_SUB     : begin
                   cikarma_aktif_r   = 1'b1;
                   aritmetik_sayi1_r = yazmac_degeri1_i;
                   aritmetik_sayi2_r = yazmac_degeri2_i;
                   sonuc_r_next      =   cikarma_sonuc_w;
                   AMB_hazir_r_next  = 1'b1;            
               end
               // mantik islemleri
               `ALU_AND     : begin
                   sonuc_r_next = yazmac_degeri1_i & yazmac_degeri2_i;
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_ANDI    : begin
                   sonuc_r_next = yazmac_degeri1_i & anlik_i;
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_OR      : begin
                   sonuc_r_next = yazmac_degeri1_i | yazmac_degeri2_i;
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_XOR     : begin
                   sonuc_r_next = yazmac_degeri1_i ^ yazmac_degeri2_i; 
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_ORI     : begin 
                   sonuc_r_next = yazmac_degeri1_i | anlik_i;   
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_XORI    : begin
                   sonuc_r_next = yazmac_degeri1_i ^ anlik_i;
                   AMB_hazir_r_next = 1'b1;
                end 
               `ALU_SLLI    : begin          
                   sonuc_r_next = yazmac_degeri1_i << anlik_i[4:0];
                   AMB_hazir_r_next = 1'b1;
                end
               `ALU_SRLI    : begin  
                   sonuc_r_next = $signed({1'b0, yazmac_degeri1_i}) >>> anlik_i[4:0];
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SRAI    : begin  
                   sonuc_r_next = $signed(yazmac_degeri1_i) >>> anlik_i[4:0];
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SLL    :  begin  
                   sonuc_r_next = yazmac_degeri1_i << yazmac_degeri2_i[4:0];
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SLT     : begin 
                   sonuc_r_next = $signed(yazmac_degeri1_i) < $signed(yazmac_degeri2_i);
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SLTU    : begin  
                   sonuc_r_next = $unsigned(yazmac_degeri1_i) < $unsigned(yazmac_degeri2_i);
                   AMB_hazir_r_next = 1'b1; 
                end              
               `ALU_SRL     : begin  
                   sonuc_r_next = $signed({1'b0, yazmac_degeri1_i}) >>> yazmac_degeri2_i[4:0]  ; 
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SRA     : begin  
                   sonuc_r_next = $signed({yazmac_degeri1_i[31], yazmac_degeri1_i}) >>> yazmac_degeri2_i[4:0];
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SLTI    : begin 
                   sonuc_r_next = $signed(yazmac_degeri1_i) < $signed(anlik_i);
                   AMB_hazir_r_next = 1'b1;
                end              
               `ALU_SLTIU   : begin  
                   sonuc_r_next = $unsigned(yazmac_degeri1_i) < $unsigned(anlik_i); 
                   AMB_hazir_r_next = 1'b1;
                end
                         
           endcase 
        end
        
        if(dallanma_aktif_i) begin
           cikarma_aktif_r   = 1'b1;
           aritmetik_sayi1_r = yazmac_degeri1_i;
           aritmetik_sayi2_r = yazmac_degeri2_i;
       
           if(cikarma_sonuc_w == 32'd0) begin
              esit_mi_o_r = 1'b1;
           end
           
           if($signed(cikarma_sonuc_w) > 0) begin
              buyuk_mu_o_r = 1'b1;
           end
           
           if(aritmetik_sayi1_r[31] && !aritmetik_sayi2_r[31]) begin
              buyuk_mu_o_unsigned_r = 1'b1;
           end
           
           if(!aritmetik_sayi1_r[31] && !aritmetik_sayi2_r [31] && !cikarma_sonuc_w[31]) begin
              buyuk_mu_o_unsigned_r = 1'b1;
           end
           
           if(aritmetik_sayi1_r[31] && aritmetik_sayi2_r[31] && !cikarma_sonuc_w[31]) begin
              buyuk_mu_o_unsigned_r = 1'b1;
           end
           
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