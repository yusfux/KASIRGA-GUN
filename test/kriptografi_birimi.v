`timescale 1ns / 1ps

/*
    Gereken sinyaller
    1-) islem_kodu_i
    hmdst -> 000
    pkg -> 001
    rvrs -> 010
    sladd -> 011
    cntz -> 100
    cntp -> 101
    2-) yazmac_rs1_i
    3-) yazmac_rs2_i
    4-) blok_aktif_i
*/
`include "operations.vh"   

module kriptografi_birimi(
    input clk_i,
    input rst_i,
    input blok_aktif_i,
    input [31:0] yazmac_rs1_i,
    input [31:0] yazmac_rs2_i,
    input [2:0]islem_kodu_i,
    
    output [31:0] sonuc_o,
    output kriptografi_hazir_o 
    
);
    
reg kriptografi_hazir_r = 1'b0;
reg kriptografi_hazir_r_next = 1'b0;

reg [31:0] sonuc_r = 0;
reg [31:0] sonuc_r_next = 0;

integer i=0;

reg [31:0] xor_result_ns ;
reg [31:0] xor_result_r ;

wire [31:0] variable_w;
assign variable_w = xor_result_ns - ((xor_result_ns >> 1) & 32'hdb6d_b6db) - ((xor_result_ns >> 2) & 32'h4924_9249);

always @* begin
    
    xor_result_ns = xor_result_r;
    sonuc_r_next = sonuc_r;
    kriptografi_hazir_r_next = 1'b0;
    
    if(blok_aktif_i) begin
        
        case(islem_kodu_i) 
        `CRY_HMDST : begin              
            xor_result_ns = yazmac_rs1_i ^ yazmac_rs2_i;
            sonuc_r_next = ((variable_w + (variable_w >> 3)) & 32'hc71c_71c7) % 63;
            kriptografi_hazir_r_next = 1'b1;
         end
        
        `CRY_PKG : begin
            sonuc_r_next = {yazmac_rs2_i[15:0],yazmac_rs1_i[15:0]};
            kriptografi_hazir_r_next = 1'b1;
         end
        
        `CRY_RVRS : begin
            for(i=0;i<32;i=i+1) begin
                sonuc_r_next[31-i] = yazmac_rs1_i[i];
            end
            kriptografi_hazir_r_next = 1'b1;
         end
        
        `CRY_SLADD : begin
            sonuc_r_next = ( yazmac_rs1_i << 1 ) + yazmac_rs2_i;
            kriptografi_hazir_r_next = 1'b1;
         end
        
        `CRY_CNTZ : begin // ilk 1 i bulmak için binary search yapýlýyor
        
            if(yazmac_rs1_i[15:0] == 16'd0) begin
                if(yazmac_rs1_i[23:16] == 8'd0) begin
                    if(yazmac_rs1_i[27:24] == 4'd0) begin
                        if(yazmac_rs1_i[29:28] == 2'd0) begin
                            if(yazmac_rs1_i[30] == 1'b1) 
                                sonuc_r_next = 32'd30;
                            else if(yazmac_rs1_i[31] == 1'b1) 
                                sonuc_r_next = 32'd31;
                            else
                                sonuc_r_next = 32'd32;            
                        end
                        else begin
                            if(yazmac_rs1_i[28] == 1'b1) 
                                sonuc_r_next = 32'd28;
                            else if(yazmac_rs1_i[29] == 1'b1) 
                                sonuc_r_next = 32'd29;                                
                        end
                    end
                    else begin
                        if(yazmac_rs1_i[25:24] == 2'd0) begin
                            if(yazmac_rs1_i[26] == 1'b1) 
                                sonuc_r_next = 32'd26;
                            else if(yazmac_rs1_i[27] == 1'b1) 
                                sonuc_r_next = 32'd27;                                
                        end
                        else begin
                            if(yazmac_rs1_i[24] == 1'b1) 
                                sonuc_r_next = 32'd24;
                            else if(yazmac_rs1_i[25] == 1'b1) 
                                sonuc_r_next = 32'd25;
                        end        
                    end
                end
                else begin 
                    if(yazmac_rs1_i[19:16] == 4'd0) begin
                        if(yazmac_rs1_i[21:20] == 2'd0) begin
                            if(yazmac_rs1_i[22] == 1'b1) 
                                sonuc_r_next = 32'd22;
                            else if(yazmac_rs1_i[23] == 1'b1) 
                                sonuc_r_next = 32'd23;
                        end
                        else begin
                            if(yazmac_rs1_i[20] == 1'b1) 
                                sonuc_r_next = 32'd20;
                            else if(yazmac_rs1_i[21] == 1'b1) 
                                sonuc_r_next = 32'd21;                                
                        end
                    end
                    else begin
                        if(yazmac_rs1_i[17:16] == 2'd0) begin
                            if(yazmac_rs1_i[18] == 1'b1) 
                                sonuc_r_next = 32'd18;
                            else if(yazmac_rs1_i[19] == 1'b1) 
                                sonuc_r_next = 32'd19;                                
                        end
                        else begin
                            if(yazmac_rs1_i[16] == 1'b1) 
                                sonuc_r_next = 32'd16;
                            else if(yazmac_rs1_i[17] == 1'b1) 
                                sonuc_r_next = 32'd17;
                        end        
                    end
                end
             end
                 else begin
                    if(yazmac_rs1_i[7:0] == 8'd0) begin
                        if(yazmac_rs1_i[11:8] == 4'd0) begin
                            if(yazmac_rs1_i[13:12] == 2'd0) begin
                                if(yazmac_rs1_i[14] == 1'b1) 
                                    sonuc_r_next = 32'd14;
                                else if(yazmac_rs1_i[15] == 1'b1) begin
                                    sonuc_r_next = 32'd15;
                                end                                  
                            end
                            else begin
                                if(yazmac_rs1_i[12] == 1'b1) 
                                    sonuc_r_next = 32'd12;
                                else if(yazmac_rs1_i[13] == 1'b1) 
                                    sonuc_r_next = 32'd13;
                            end
                        end
                        else begin
                            if(yazmac_rs1_i[9:8] == 2'd0) begin
                                if(yazmac_rs1_i[10] == 1'b1) 
                                    sonuc_r_next = 32'd10;
                                else if(yazmac_rs1_i[11] == 1'b1) begin
                                    sonuc_r_next = 32'd11;
                                end                                  
                            end
                            else begin
                                if(yazmac_rs1_i[8] == 1'b1) 
                                    sonuc_r_next = 32'd8;
                                else if(yazmac_rs1_i[9] == 1'b1) 
                                    sonuc_r_next = 32'd9;
                            end                        
                        end                        
                    end
                    else begin
                    if(yazmac_rs1_i[3:0] == 4'd0) begin
                        if(yazmac_rs1_i[5:4] == 2'd0) begin
                            if(yazmac_rs1_i[6] == 1'b1) 
                                sonuc_r_next = 32'd6;
                            else if(yazmac_rs1_i[7] == 1'b1) begin
                                sonuc_r_next = 32'd7;
                            end                                  
                        end
                        else begin
                            if(yazmac_rs1_i[4] == 1'b1) 
                                sonuc_r_next = 32'd4;
                            else if(yazmac_rs1_i[5] == 1'b1) 
                                sonuc_r_next = 32'd5;
                        end
                    end
                    else begin
                        if(yazmac_rs1_i[1:0] == 2'd0) begin
                            if(yazmac_rs1_i[2] == 1'b1) 
                                sonuc_r_next = 32'd2;
                            else if(yazmac_rs1_i[3] == 1'b1) begin
                                sonuc_r_next = 32'd3;
                            end                                  
                        end
                        else begin
                            if(yazmac_rs1_i[0] == 1'b1) begin
                                sonuc_r_next = 32'd0;
                            end    
                            else if(yazmac_rs1_i[1] == 1'b1) begin
                                sonuc_r_next = 32'd1;
                            end    
                        end                        
                    end                                        
                end
            end
            kriptografi_hazir_r_next = 1'b1;   
         end
        `CRY_CNTP : begin         
            sonuc_r_next = ((variable_w + (variable_w >> 3)) & 32'hc71c_71c7) % 63;
            kriptografi_hazir_r_next = 1'b1;                 
         end
        endcase
    end   
end

always @(posedge clk_i) begin
    if(!rst_i || (!blok_aktif_i)) begin
        sonuc_r <= 0;
        kriptografi_hazir_r <= 0; 
    end
    else begin
        sonuc_r <= sonuc_r_next;
        kriptografi_hazir_r <= kriptografi_hazir_r_next;
        xor_result_r <= xor_result_ns;
    end    
end

assign kriptografi_hazir_o = kriptografi_hazir_r;
assign sonuc_o = sonuc_r;

endmodule