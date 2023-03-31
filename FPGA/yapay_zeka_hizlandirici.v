`timescale 1ns / 1ps

// POST SYNTHESIS SIMULATION'I GECTI
// durdur_i implemente edildi
module yapay_zeka_hizlandirici(

    input clk_i,
    input rst_i,
    input durdur_i,
    
    // Sartnamede belirtildigi sekliyle bu sinyal cozden gelmeli
    input blok_aktif_i,
    
    // Sartnamede belirtildigi sekliyle bu sinyaller cozden gelmeli
    input [31:0] rs1_veri_i,
    input [31:0] rs2_veri_i,
    
    // Sartnamede belirtildigi sekliyle bu sinyaller cozden gelmeli
    input filtre_rs1_en_i,
    input filtre_rs2_en_i,
    input filtre_sil_i,
    
    // Sartnamede belirtildigi sekliyle bu sinyaller cozden gelmeli
    input veri_rs1_en_i,
    input veri_rs2_en_i,
    input veri_sil_i,
    
    // Sartnamede belirtildigi sekliyle bu sinyaller cozden gelmeli
    input conv_yap_en_i, // conv_run
    
    output [31:0] convolution_sonuc_o,
    output conv_hazir_o,
    
    output stall_o 

    );
    
   reg conv_hazir_r;
   reg conv_hazir_r_next;
   
   reg [31:0] convolution_sonuc_r;
   reg [31:0] convolution_sonuc_r_next;
   
   reg bir_cevrim_stall_r;
   reg bir_cevrim_stall_r_next;
   
   reg conv_yap_en_i_r;
      
   reg cikis_ver;
   reg cikis_ver_next;
   
   assign conv_hazir_o = (conv_yap_en_i_r && conv_hazir_r) || (bir_cevrim_stall_r && conv_hazir_r_next) || (cikis_ver); // stall_o durumunda da calismali
   assign convolution_sonuc_o =  convolution_sonuc_r;
   assign stall_o = bir_cevrim_stall_r_next; // blok_aktif_i ? bir_cevrim_stall_r : 0 seklinde yapmistim
   
   reg [31:0] veri_matris_r [15:0]; 
   reg [31:0] filtre_matris_r [15:0];
   reg [31:0] rs1_veri_r_next;
   reg [31:0] rs2_veri_r_next;
   
    
   reg [3:0] veri_matris_idx;
   reg [3:0] filtre_matris_idx; 
   reg [3:0] veri_matris_idx_next;
   reg [3:0] filtre_matris_idx_next;
   
   reg [15:0] veri_matris_dolu;
   reg [15:0] filtre_matris_dolu;
   reg [15:0] veri_matris_dolu_next;
   reg [15:0] filtre_matris_dolu_next;
   wire [15:0] conva_hazir;
   assign conva_hazir = veri_matris_dolu & filtre_matris_dolu;
   
   reg [3:0] conv_idx;
   reg [3:0] conv_idx_next;
   
   reg toplama_islemi;
   reg toplama_islemi_next;
   
   reg [31:0] carpim_sonuc;
   reg [31:0] carpim_sonuc_next;
   
   localparam pasif = 3'b000;
   localparam filtre_1 = 3'b001;
   localparam filtre_2 = 3'b010;
   localparam veri_1 = 3'b011;
   localparam veri_2 = 3'b100;
   
   reg [2:0] mod;
   reg [2:0] mod_next; 

    
    always @ * begin
       if(!rst_i) begin // rst_i 0 ise reset
         bir_cevrim_stall_r_next     = 1'b0;                         
         conv_hazir_r_next           = 1'b0;               
         convolution_sonuc_r_next    = 32'd0;                 
         veri_matris_idx_next        = 4'd0;            
         filtre_matris_idx_next      = 4'd0;                               
         veri_matris_dolu_next       = 16'd0;           
         filtre_matris_dolu_next     = 16'd0;                                                     
         conv_idx_next               = 4'd0;                                                   
         mod_next                    = 3'd0;                                                             
         rs1_veri_r_next             = 32'd0;                 
         rs2_veri_r_next             = 32'd0;  
         toplama_islemi_next         = 1'b0;         
         carpim_sonuc_next           = 32'd0;
         cikis_ver_next              = 1'b0;
           
       end
       else begin
           
         bir_cevrim_stall_r_next = bir_cevrim_stall_r;
         convolution_sonuc_r_next = convolution_sonuc_r;
         
         veri_matris_idx_next = veri_matris_idx;
         filtre_matris_idx_next = filtre_matris_idx;
         
         veri_matris_dolu_next = veri_matris_dolu;
         filtre_matris_dolu_next = filtre_matris_dolu;
         
         conv_idx_next = conv_idx;
         
         mod_next = 3'd0;
         rs1_veri_r_next = 32'd0;
         rs2_veri_r_next = 32'd0;
         cikis_ver_next  = 1'b0;
         
         conv_hazir_r_next = conv_hazir_r;
         
         toplama_islemi_next = toplama_islemi;
         carpim_sonuc_next   = carpim_sonuc;
         
         if(!durdur_i) begin
         
//            if(conv_idx == 15) begin 
//               conv_hazir_r_next = 1'b1;
//               bir_cevrim_stall_r_next = 1'b0;
//            end

            if(conv_yap_en_i) begin // 
               if(conv_hazir_r) begin
                  bir_cevrim_stall_r_next = 1'b0;
                  conv_hazir_r_next = 1'b1;
               end
               else if(conva_hazir[conv_idx + 1'b1] == 1'b0) begin
                  bir_cevrim_stall_r_next = 1'b0;
                  cikis_ver_next = 1'b1;
               end
               else begin
                  bir_cevrim_stall_r_next = 1'b1;
                  conv_hazir_r_next = 1'b0;
               end
            end
            
            
            // sonra topla
            if(toplama_islemi) begin
               convolution_sonuc_r_next = convolution_sonuc_r + carpim_sonuc;
               conv_idx_next = conv_idx + 1'b1;  // 15->0
               toplama_islemi_next = 1'b0;
               
               if(conv_idx == 15) begin
                  conv_hazir_r_next = 1'b1;
                  bir_cevrim_stall_r_next = 1'b0;
               end
            end
            // once carp
            else if(conva_hazir[conv_idx] && (!conv_hazir_r)) begin
               carpim_sonuc_next   = veri_matris_r[conv_idx] * filtre_matris_r[conv_idx];
               toplama_islemi_next = 1'b1;
            end
            
            if(!conv_hazir_r) begin
               if((!filtre_sil_i) && (!veri_sil_i)) begin
                  if(filtre_rs1_en_i && (!filtre_rs2_en_i)) begin
                     rs1_veri_r_next = rs1_veri_i;
                     filtre_matris_dolu_next[filtre_matris_idx] = 1'b1;
                     filtre_matris_idx_next = filtre_matris_idx + 1'b1;
                     mod_next = filtre_1;
                  end
                  else if(filtre_rs2_en_i) begin
                     rs1_veri_r_next = rs1_veri_i;
                     rs2_veri_r_next = rs2_veri_i; // rs2 yukleniyorsa zaten rs1 kesinlikle yuklenecek
                     filtre_matris_dolu_next[filtre_matris_idx + 1'b1] = 1'b1;
                     filtre_matris_dolu_next[filtre_matris_idx] = 1'b1;
                     filtre_matris_idx_next = filtre_matris_idx + 2'b10;
                     mod_next = filtre_2;
                  end  
                  else begin
                     if(veri_rs1_en_i && (!veri_rs2_en_i)) begin
                        rs1_veri_r_next = rs1_veri_i;
                        veri_matris_dolu_next[veri_matris_idx] = 1'b1;
                        veri_matris_idx_next = veri_matris_idx + 1'b1;
                        mod_next = veri_1;
                     end
                     else if(veri_rs2_en_i) begin
                        rs1_veri_r_next = rs1_veri_i;
                        rs2_veri_r_next = rs2_veri_i; // rs2 yukleniyorsa zaten rs1 kesinlikle yuklenecek
                        veri_matris_dolu_next[veri_matris_idx + 1'b1] = 1'b1;
                        veri_matris_dolu_next[veri_matris_idx] = 1'b1;
                        veri_matris_idx_next = veri_matris_idx + 2'b10;
                        mod_next = veri_2;
                     end
                  end
               end
            end
          end
        end
    end
    
    always @ (posedge clk_i) begin
    
      if(filtre_sil_i || veri_sil_i) begin
         convolution_sonuc_r <= 32'd0;
         conv_idx <= 4'd0; 
         conv_hazir_r <= 1'b0;
         bir_cevrim_stall_r <= 1'b0;
         conv_yap_en_i_r <= conv_yap_en_i;
       
         if(filtre_sil_i) begin
            filtre_matris_idx  <= 4'd0;
            filtre_matris_dolu <= 16'd0;
            veri_matris_idx    <= veri_matris_idx_next;
            veri_matris_dolu   <= veri_matris_dolu_next;
         end
         
         if(veri_sil_i) begin
             veri_matris_idx   <= 4'd0;
             veri_matris_dolu  <= 16'd0;
             filtre_matris_idx <= filtre_matris_idx_next;
             filtre_matris_dolu<= filtre_matris_dolu_next;
         end
      end
   
      else begin
         cikis_ver <= cikis_ver_next;
         conv_yap_en_i_r <= conv_yap_en_i;
         conv_hazir_r <= conv_hazir_r_next;
         convolution_sonuc_r <= convolution_sonuc_r_next;
         bir_cevrim_stall_r <= bir_cevrim_stall_r_next;
         
         veri_matris_idx <= veri_matris_idx_next;
         filtre_matris_idx <= filtre_matris_idx_next;
         
         veri_matris_dolu <= veri_matris_dolu_next;
         filtre_matris_dolu <= filtre_matris_dolu_next;
         
         conv_idx <= conv_idx_next;
         
         toplama_islemi <= toplama_islemi_next;
         carpim_sonuc   <= carpim_sonuc_next;
         
    
         case(mod_next)
           filtre_1 : begin
              filtre_matris_r[filtre_matris_idx] <= rs1_veri_r_next;
           end
           
           filtre_2 : begin
              filtre_matris_r[filtre_matris_idx] <= rs1_veri_r_next;
              filtre_matris_r[filtre_matris_idx + 1'b1] <= rs2_veri_r_next;
           end
           
           veri_1 : begin
              veri_matris_r[veri_matris_idx] <= rs1_veri_r_next;
           end
           
           veri_2 : begin
              veri_matris_r[veri_matris_idx] <= rs1_veri_r_next;
              veri_matris_r[veri_matris_idx + 1'b1] <= rs2_veri_r_next;
           end
           
           default : begin
               // do nothing
           end
         endcase
      end 
   end
    
endmodule
