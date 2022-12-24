`timescale 1ns / 1ps

// BIMODAL BRANCH PREDICTOR

/*
    GEREKEN SINYALLER 
    1-) ongoru_aktif_i
    2-) ps_i
    3-) buyruk_i
    
    ongoru_aktif_i -> oncozucude, dallanma buyrugu geldigi anlasilirsa 1 yapilmali
    
*/


module Dallanma_Ongoru_Blogu(
	// Saat ve reset
    input clk_i,
    input rst_i,
	
    input ongoru_aktif_i, // ONCOZUCU BRANCH GELINCE AKTIVE EDICEK *
	
	// Dallanma cozuldukten sonra gercek sonucu gosteren guncelleme sinyalleri
    input               guncelle_gecerli_i, // Guncelleme aktif
    input               guncelle_atladi_i,  // Ilgili dallanma atladi
    input   [31:0]      guncelle_ps_i,      // Ilgili dallanmanin program sayaci

    // Su anda islenen program sayaci ve buyruk
    input   [31:0]      ps_i,  
    input   [31:0]      buyruk_i, 

    // Atlama sonucunu belirten sinyaller
    output  [31:0]      atlanan_ps_o,       // Atlanilacak olan program sayaci
    output              ongoru_gecerli_o   // Ongoru gecerli
	

    );
    
    
    reg [22:0] etiket_r [127:0];
	reg [1:0] durum_r [127:0];
	reg [31:0] hedef_adres_r [127:0];
	
	reg [1:0] durum_buf = 0;
	reg [31:0] hedef_adres_buf = 0;
    
	// Anlýk deger
    wire [11:0]Br_imm;
	assign Br_imm = {buyruk_i[31],buyruk_i[7],buyruk_i[30:25],buyruk_i[11:8]};
    
	// Satir numaralari
	wire [6:0]an_str_idx;
	assign an_str_idx = ps_i[8:2];
	wire [6:0]gun_str_idx;
	assign gun_str_idx = guncelle_ps_i[8:2];
	
	// Etiket
	wire [22:0] etiket;
	assign etiket = ps_i[32:9]; 
	
	// Durumlar
    localparam GT = 2'b00;
	localparam ZT = 2'b01;
	localparam ZA = 2'b10;
	localparam GA = 2'b11;
    
	reg [31:0] atlanan_ps_o_r = 0;
	reg ongoru_gecerli_o_r = 0;
	
	assign atlanan_ps_o = atlanan_ps_o_r;
	assign ongoru_gecerli_o = ongoru_gecerli_o_r;

	// TEST ÝÇÝN
    reg [31:0]atlamaz_tahmin = 0;
    reg [31:0]atlar_tahmin = 0;
    reg [31:0]atladi= 0;
    reg [31:0]atlamadi= 0;
    
    reg [31:0]atlamaz_tahmin_ns = 0;
    reg [31:0]atlar_tahmin_ns = 0;
    reg [31:0]atladi_ns= 0;
    reg [31:0]atlamadi_ns= 0;
	
	integer i;
	
	initial begin
		
		for(i=0;i<128;i=i+1) begin
			etiket_r[i] = 0;
			durum_r[i] = 0;
			hedef_adres_r[i] = 0;
		end
	
	end
	
	always @* begin
	
	ongoru_gecerli_o_r = 0;
	atlanan_ps_o_r = 0;
	durum_buf = 0;
	hedef_adres_buf = 0;
	
	atlamaz_tahmin_ns = atlamaz_tahmin;
	atlar_tahmin_ns = atlar_tahmin;
	atlamadi_ns = atlamadi;
	atladi_ns = atladi;
	
	if(guncelle_gecerli_i) begin
	    if(guncelle_atladi_i) 
	       atladi_ns = atladi + 1'b1;
	    else 
	       atlamadi_ns = atlamadi + 1'b1;
	       
		case(durum_r[gun_str_idx])
		      
			GT : begin
				if(guncelle_atladi_i)
					durum_buf = ZT;
				else 	
					durum_buf = GT;
			end
				
			ZT : begin
				if(guncelle_atladi_i)
					durum_buf = ZA;
				else 	
					durum_buf = GT;
						
			end
				
			ZA : begin
				if(guncelle_atladi_i)
					durum_buf = GA;
				else 	
					durum_buf = ZT;
			end
				
			GA : begin
				if(guncelle_atladi_i)
					durum_buf = GA;
				else 	
					durum_buf = ZA;
			end
			
		endcase
	
	end
	
	if(ongoru_aktif_i) begin
		
		if(etiket == etiket_r[an_str_idx]) begin
			ongoru_gecerli_o_r = 1'b1;
			
			if(durum_r[an_str_idx][1]) begin // ATLAR
			    $display("girdi");
				atlar_tahmin_ns = atlar_tahmin + 1'b1;
				hedef_adres_buf = ps_i + {20'hFFFFF,Br_imm};
				
				if(hedef_adres_r[an_str_idx] != 0) begin
					atlanan_ps_o_r = hedef_adres_r[an_str_idx];
				end
			
				else begin
					if(Br_imm[11]) begin
						atlanan_ps_o_r = ps_i + {20'hFFFFF,Br_imm};
					end
					else begin
						atlanan_ps_o_r = ps_i + {20'h00000,Br_imm};	
					end
				end
			end
			
			else begin // ATLAMAZ
			    atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
				atlanan_ps_o_r = ps_i + 4;
			end
		
		end
	
	end
	
	end
	
	
	always @(posedge clk_i) begin
	
	
	if(!rst_i) begin
		if(guncelle_gecerli_i) begin
			durum_r[gun_str_idx] <= durum_buf;
			
			if(durum_r[an_str_idx][1]) begin
				hedef_adres_r[gun_str_idx] <= hedef_adres_buf;
			end
		end
		
		atlamaz_tahmin <= atlamaz_tahmin_ns;
        atlar_tahmin <= atlar_tahmin_ns; 
        atlamadi <= atlamadi_ns;
        atladi <= atladi_ns;
	end
	else begin
	    atlamaz_tahmin <= 0;
        atlar_tahmin <= 0; 
        atlamadi <= 0;
        atladi <= 0;
        
		for(i=0;i<128;i=i+1) begin
			etiket_r[i] <= 0;
			durum_r[i] <= 0;
			hedef_adres_r[i] <= 0;
		end
	
	end
	
	end
  
endmodule
