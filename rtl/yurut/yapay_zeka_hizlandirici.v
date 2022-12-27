`timescale 1ns / 1ps

/*
    or.
    bir cevrim 2 filtre yukle, hemen ustune conv yap gelirse, 1 cevrim fazladan beklenmesi gerekiyor
    bu durum cozulmeli (bir_cevrim_stall_o denetim birimine verilecek)
*/

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
    input conv_yap_yaz_en_i, // conv_run
    
    output [31:0] convolution_sonuc_o,
    output conv_hazir_o,
    
    output bir_cevrim_stall_o 

    );
    
    reg conv_hazir_r = 0;
    reg [31:0] convolution_sonuc_r =0;
    reg bir_cevrim_stall_r = 0;
    reg bir_cevrim_stall_r_next = 0;
    assign conv_hazir_o = conv_hazir_r;
    assign convolution_sonuc_o = convolution_sonuc_r;
    assign bir_cevrim_stall_o = bir_cevrim_stall_r;
    
    reg [31:0] veri_matris_r [15:0];
    reg [31:0] filtre_matris_r [15:0];
   
    
    reg [3:0] veri_matris_idx = 0;
    reg [3:0] filtre_matris_idx = 0;
    
    reg [15:0] veri_matris_dolu = 0;
    reg [15:0] filtre_matris_dolu = 0;
    wire [15:0] conva_hazir;
    assign conva_hazir = veri_matris_dolu & filtre_matris_dolu;
    
    reg [31:0] conv_sonuc = 0;
    reg [3:0] conv_idx = 0;
    reg [31:0] conv_sonuc_next = 0;
    reg [3:0] conv_idx_next = 0;
    
    integer i = 0;
    
    always @ * begin
    conv_sonuc_next = conv_sonuc;
    conv_idx_next = conv_idx;
    bir_cevrim_stall_r_next = 1'b0;
    
    if(blok_aktif_i) begin
        if(conva_hazir[conv_idx]) begin
            conv_sonuc_next = conv_sonuc + (veri_matris_r[conv_idx] * filtre_matris_r[conv_idx]);
            conv_idx_next = conv_idx + 1'b1;  // 15->0
        end
        
        if((conv_idx<15) && conv_yap_yaz_en_i && conva_hazir[conv_idx] && conva_hazir[conv_idx+1'b1]) begin
                bir_cevrim_stall_r_next = 1'b1;    
        end
        else begin
                bir_cevrim_stall_r_next = 1'b0;
        end
        
    end
   
    end
    
    always @ (posedge clk_i) begin
    
    // matrisleri doldurma
    
    if(rst_i) begin
        conv_sonuc <= 0;        
        conv_idx <= 0;          
        convolution_sonuc_r <= 0; 
        filtre_matris_idx <= 0; 
        filtre_matris_dolu <= 0;
        veri_matris_idx <= 0;
        veri_matris_dolu <= 0;
        conv_hazir_r <= 0;
        bir_cevrim_stall_r <= 0;
        
        for(i=0 ; i<16 ; i=i+1) begin
                filtre_matris_r[i] <= 0;
                veri_matris_r[i] <= 0;
        end
        
    end
    else if(blok_aktif_i && !rst_i) begin
    
        if(filtre_sil_i) begin
            for(i=0 ; i<16 ; i=i+1) begin
                filtre_matris_r[i] <= 0;
            end
            conv_sonuc <= 0;
            conv_idx <= 0;
            convolution_sonuc_r <= 0;
            filtre_matris_idx <= 0;
            filtre_matris_dolu <= 0;
            conv_hazir_r <= 0;
        end
        
        if(veri_sil_i) begin
            for(i=0 ; i<16 ; i=i+1) begin
                veri_matris_r[i] <= 0;
            end
            conv_sonuc <= 0;
            conv_idx <= 0;
            convolution_sonuc_r <= 0;
            veri_matris_idx <= 0;
            veri_matris_dolu <= 0;
            conv_hazir_r <= 0;
        end
        
        if(!filtre_sil_i && !veri_sil_i) begin
            conv_sonuc <= conv_sonuc_next;
            conv_idx <= conv_idx_next;
            bir_cevrim_stall_r <= bir_cevrim_stall_r_next;
            
            if(conv_yap_yaz_en_i) begin
                convolution_sonuc_r <= conv_sonuc_next; // bu next olmayabilir *
                conv_hazir_r <= 1'b1;
            end
            else begin
                convolution_sonuc_r <= 0;
                conv_hazir_r <= 1'b0;
            end
            
            if(filtre_rs1_en_i) begin
                filtre_matris_r[filtre_matris_idx] <= rs1_veri_i;
                filtre_matris_dolu[filtre_matris_idx] <= 1'b1;
            end
            
            if(filtre_rs2_en_i) begin
                filtre_matris_r[filtre_matris_idx + 1'b1] <= rs2_veri_i; // rs2 yükleniyorsa zaten rs1 kesinlikle yükelenecek
                filtre_matris_dolu[filtre_matris_idx + 1'b1] <= 1'b1;
                filtre_matris_idx <= filtre_matris_idx + 2;
            end 
            else begin // yalnizca rs1 icin yuklendi
                filtre_matris_idx <= filtre_matris_idx + 1;
            end
            
            if(veri_rs1_en_i) begin
                veri_matris_r[veri_matris_idx] <= rs1_veri_i;
                veri_matris_dolu[veri_matris_idx] <= 1'b1;
            end
            
            if(veri_rs2_en_i) begin
                veri_matris_r[veri_matris_idx + 1'b1] <= rs2_veri_i; // rs2 yukleniyorsa zaten rs1 kesinlikle yuklenecek
                veri_matris_dolu[veri_matris_idx + 1'b1] <= 1'b1;
                veri_matris_idx <= veri_matris_idx + 2;
            end
            else begin // yalnizca rs1 icin yuklendi
                veri_matris_idx <= veri_matris_idx + 1;
            end
        end
    end
    
    end
    
    
    
    
endmodule
