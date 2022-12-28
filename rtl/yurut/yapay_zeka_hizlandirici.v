`timescale 1ns / 1ps

// POST SYNTHESIS SIMULATION'I GECTI

module yapay_zeka_hizlandirici(

    input clk_i,
    input rst_i,
    
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
    
    reg conv_hazir_r = 0;
	reg conv_hazir_r_next = 0;
	
    reg [31:0] convolution_sonuc_r =0;
	reg [31:0] convolution_sonuc_r_next =0;
	
    reg bir_cevrim_stall_r = 0;
    reg bir_cevrim_stall_r_next = 0;
	
    assign conv_hazir_o = blok_aktif_i ? conv_hazir_r : 0;
    assign convolution_sonuc_o = blok_aktif_i ? convolution_sonuc_r : 0;
    assign stall_o = blok_aktif_i ? bir_cevrim_stall_r : 0;
    
    reg [31:0] veri_matris_r [15:0];
    reg [31:0] filtre_matris_r [15:0];
	reg [15:0] rs1_veri_r = 0;
    reg [15:0] rs2_veri_r = 0;
    reg [15:0] rs1_veri_r_next = 0;
    reg [15:0] rs2_veri_r_next = 0;
   
    
    reg [3:0] veri_matris_idx = 0;
    reg [3:0] filtre_matris_idx = 0; 
	reg [3:0] veri_matris_idx_next = 0;
    reg [3:0] filtre_matris_idx_next = 0;
    
    reg [15:0] veri_matris_dolu = 0;
    reg [15:0] filtre_matris_dolu = 0;
	reg [15:0] veri_matris_dolu_next = 0;
    reg [15:0] filtre_matris_dolu_next = 0;
    wire [15:0] conva_hazir;
    assign conva_hazir = veri_matris_dolu & filtre_matris_dolu;
    
    reg [3:0] conv_idx = 0;
    reg [3:0] conv_idx_next = 0;
    
    localparam pasif = 3'b000;
    localparam filtre_1 = 3'b001;
    localparam filtre_2 = 3'b010;
    localparam veri_1 = 3'b011;
    localparam veri_2 = 3'b100;
    
    reg [2:0] mod = 0;
    reg [2:0] mod_next = 0;
    
    integer i = 0;
    
    initial begin
        for(i=0 ; i<16 ; i=i+1) begin
            veri_matris_r[i] = 0;
            filtre_matris_r[i] = 0;
        end
    
    end
    
    
    always @ * begin
    if(rst_i) begin
        
        bir_cevrim_stall_r_next     = 0;                         
        conv_hazir_r_next           = 0;               
        convolution_sonuc_r_next    = 0;        
                      
        veri_matris_idx_next        = 0;            
        filtre_matris_idx_next      = 0;          
                                
        veri_matris_dolu_next       = 0;           
        filtre_matris_dolu_next     = 0;         
                                                     
        conv_idx_next               = 0;                   
                                      
        mod_next                    = 0;                                      
                                     
        rs1_veri_r_next             = 0;                 
        rs2_veri_r_next             = 0;                 
        
    end
    else begin
    
        bir_cevrim_stall_r_next = bir_cevrim_stall_r;
        convolution_sonuc_r_next = convolution_sonuc_r;
        
        veri_matris_idx_next = veri_matris_idx;
        filtre_matris_idx_next = filtre_matris_idx;
        
        veri_matris_dolu_next = veri_matris_dolu;
        filtre_matris_dolu_next = filtre_matris_dolu;
        
        conv_idx_next = conv_idx;
        
        mod_next = 0;
        conv_hazir_r_next = conv_hazir_r;
        
        rs1_veri_r_next = rs1_veri_r;
        rs2_veri_r_next = rs2_veri_r;
            
            if(conv_idx == 15) begin 
                conv_hazir_r_next = 1'b1;
                bir_cevrim_stall_r_next = 1'b0;
            end
        
            if(conv_yap_en_i) begin
               if((conv_idx == 15) || conv_hazir_r) begin
                    bir_cevrim_stall_r_next = 1'b0;
                    conv_hazir_r_next = 1'b1;
               end
               else if(conva_hazir[conv_idx + 1'b1] == 0) begin
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
                        rs2_veri_r_next = rs2_veri_i; // rs2 yükleniyorsa zaten rs1 kesinlikle yükelenecek
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
    
    always @ (posedge clk_i) begin
        if(filtre_sil_i || veri_sil_i) begin
         rs1_veri_r <= 0;
         rs2_veri_r <= 0;
         convolution_sonuc_r <= 0;
         conv_idx <= 0; 
         conv_hazir_r <= 0;
         bir_cevrim_stall_r <= 0;
        
            if(filtre_sil_i) begin
                for(i=0 ; i<16 ; i=i+1) begin
                    filtre_matris_r[i] <= 0;
                end
                filtre_matris_idx <= 0;
                filtre_matris_dolu <= 0;
                veri_matris_idx <= veri_matris_idx_next;
                veri_matris_dolu <= veri_matris_dolu_next;
            end
            
            if(veri_sil_i) begin
                for(i=0 ; i<16 ; i=i+1) begin
                    veri_matris_r[i] <= 0;
                end
                veri_matris_idx <= 0;
                veri_matris_dolu <= 0;
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
        
        mod <= mod_next;
        
        rs1_veri_r <= rs1_veri_i;
        rs2_veri_r <= rs2_veri_i;
	
	 
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
		endcase
	end
	
	
    
    end
    
    
    
    
endmodule
