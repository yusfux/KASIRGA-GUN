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
    
    reg conv_hazir_r = 1'b0;
	reg conv_hazir_r_next = 1'b0;
	
    reg [31:0] convolution_sonuc_r = 32'd0;
	reg [31:0] convolution_sonuc_r_next = 32'd0;
	
    reg bir_cevrim_stall_r = 1'b0;
    reg bir_cevrim_stall_r_next = 1'b0;
	
    assign conv_hazir_o = (blok_aktif_i || stall_o) ? conv_hazir_r : 1'b0; // stall_o durumunda da calismali
    assign convolution_sonuc_o = (blok_aktif_i || stall_o) ? convolution_sonuc_r : 32'd0;
    assign stall_o = bir_cevrim_stall_r; // blok_aktif_i ? bir_cevrim_stall_r : 0 seklinde yapmistim
    
    reg [31:0] veri_matris_r [15:0]; 
    reg [31:0] filtre_matris_r [15:0];
    reg [31:0] rs1_veri_r_next = 32'd0;
    reg [31:0] rs2_veri_r_next = 32'd0;
   
    
    reg [3:0] veri_matris_idx = 4'd0;
    reg [3:0] filtre_matris_idx = 4'd0; 
	reg [3:0] veri_matris_idx_next = 4'd0;
    reg [3:0] filtre_matris_idx_next = 4'd0;
    
    reg [15:0] veri_matris_dolu = 16'd0;
    reg [15:0] filtre_matris_dolu = 16'd0;
	reg [15:0] veri_matris_dolu_next = 16'd0;
    reg [15:0] filtre_matris_dolu_next = 16'd0;
    wire [15:0] conva_hazir;
    assign conva_hazir = veri_matris_dolu & filtre_matris_dolu;
    
    reg [3:0] conv_idx = 4'd0;
    reg [3:0] conv_idx_next = 4'd0;
    
    localparam pasif = 3'b000;
    localparam filtre_1 = 3'b001;
    localparam filtre_2 = 3'b010;
    localparam veri_1 = 3'b011;
    localparam veri_2 = 3'b100;
    
    reg [2:0] mod = 3'd0;
    reg [2:0] mod_next = 3'd0;
    
    integer i = 0;
    integer j = 0;
    integer k = 0;
    
    initial begin
        for(i=0 ; i<16 ; i=i+1) begin
            veri_matris_r[i] = 32'd0;
            filtre_matris_r[i] = 32'd0;
        end
    end
    
    
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
        
         if(durdur_i) begin // conv hazir degilse wrapper'da sonuc aktarilmiyor, ama icerideki sinyaller ayni kalicak
            conv_hazir_r_next = 1'b0; 
         end
         else begin
            conv_hazir_r_next = conv_hazir_r;
            
            if(conv_idx == 15) begin 
                conv_hazir_r_next = 1'b1;
                bir_cevrim_stall_r_next = 1'b0;
            end
        
            if(conv_yap_en_i) begin
               if((conv_idx == 15) || conv_hazir_r) begin
                    bir_cevrim_stall_r_next = 1'b0;
                    conv_hazir_r_next = 1'b1;
               end
               else if(conva_hazir[conv_idx + 1'b1] == 1'b0) begin
                    bir_cevrim_stall_r_next = 1'b0;
                    conv_hazir_r_next = 1'b1;
               end
               else begin
                    bir_cevrim_stall_r_next = 1'b1;
                    conv_hazir_r_next = 1'b0;
               end
            end
            
            if(conva_hazir[conv_idx] && (!conv_hazir_r)) begin
                convolution_sonuc_r_next = convolution_sonuc_r + (veri_matris_r[conv_idx] * filtre_matris_r[conv_idx]);
                conv_idx_next = conv_idx + 1'b1;  // 15->0
            end
            else begin
                convolution_sonuc_r_next = convolution_sonuc_r;
                conv_idx_next = conv_idx; 
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
                        rs2_veri_r_next = rs2_veri_i; // rs2 y�kleniyorsa zaten rs1 kesinlikle y�kelenecek
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
        
            if(filtre_sil_i) begin
                for(j=0 ; j<16 ; j=j+1) begin
                    filtre_matris_r[j] <= 32'd0;
                end
                filtre_matris_idx <= 4'd0;
                filtre_matris_dolu <= 16'd0;
                veri_matris_idx <= veri_matris_idx_next;
                veri_matris_dolu <= veri_matris_dolu_next;
            end
            
            if(veri_sil_i) begin
                for(k=0 ; k<16 ; k=k+1) begin
                    veri_matris_r[k] <= 32'd0;
                end
                veri_matris_idx <= 4'd0;
                veri_matris_dolu <= 16'd0;
                filtre_matris_idx <= filtre_matris_idx_next;
                filtre_matris_dolu <= filtre_matris_dolu_next;
            end
        end
	
        else begin
        
        conv_hazir_r <= conv_hazir_r_next;
        convolution_sonuc_r <= convolution_sonuc_r_next;
        bir_cevrim_stall_r <= bir_cevrim_stall_r_next;
        
        veri_matris_idx <= veri_matris_idx_next;
        filtre_matris_idx <= filtre_matris_idx_next;
        
        veri_matris_dolu <= veri_matris_dolu_next;
        filtre_matris_dolu <= filtre_matris_dolu_next;
        
        conv_idx <= conv_idx_next;
	 
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