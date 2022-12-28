`timescale 1ns / 1ps

// BIMODAL BRANCH PREDICTOR

module dallanma_ongoru_blogu(
	// Saat ve reset
    input               clk_i,
    input               rst_i,
	
    input               ongoru_aktif_i, // ONCOZUCU BRANCH GELINCE AKTIVE EDICEK *
	
	// Dallanma cozuldukten sonra gercek sonucu gosteren guncelleme sinyalleri
    input               guncelle_gecerli_i, // Guncelleme aktif
    input               guncelle_atladi_i,  // Ilgili dallanma atladi
    input   [31:0]      guncelle_ps_i,      // Ilgili dallanmanin program sayaci
	input 	[31:0]      guncelle_hedef_adresi_i, // Hedef adres ayarlamasi yapilacak
	
    // Su anda islenen program sayaci 
    input   [31:0]      ps_i,   
    
    // Dallanmada hata olursa
	input               dallanma_hata_i,
	
    // Atlama sonucunu belirten sinyaller
    /* Bu kýsým program sayacý üreticisine girecek */
    output  [31:0]      atlanan_ps_o,       // Atlanilacak olan program sayaci
    output              ongoru_gecerli_o    // Ongoru gecerli
    );
    
    
    reg [127:0] etiket_gecerli_r = 0;
    reg [22:0] etiket_r [127:0];
	reg [1:0] durum_r [127:0];
	reg [31:0] hedef_adres_r [127:0];
	
	reg [1:0] durum_buf = 0;
	reg [31:0] hedef_adres_buf = 0;
    
	// Satir numaralari
	wire [6:0]an_str_idx;
	assign an_str_idx =  ongoru_aktif_i ? ps_i[8:2] : 0;
	wire [6:0]gun_str_idx;
	assign gun_str_idx = guncelle_gecerli_i ? guncelle_ps_i[8:2] : 0;
	
	// Etiket
	wire [22:0] etiket_gun;
	assign etiket_gun = guncelle_gecerli_i ? guncelle_ps_i[31:9] : 0; 
	
	wire [22:0] etiket_anl;
	assign etiket_anl = ongoru_aktif_i ? ps_i[31:9] : 0; 
	
	reg  etiket_gecerli =0;
	
	// Durumlar
    localparam GT = 2'b00;
	localparam ZT = 2'b01;
	localparam ZA = 2'b10;
	localparam GA = 2'b11;
    
	reg [31:0] atlanan_ps_o_r = 0;
	assign atlanan_ps_o = atlanan_ps_o_r;
	
	reg ongoru_gecerli_o_r = 0;
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
	
	atlamaz_tahmin_ns = atlamaz_tahmin;
	atlar_tahmin_ns = atlar_tahmin;
	atlamadi_ns = atlamadi;
	atladi_ns = atladi;
	
    ongoru_gecerli_o_r = 0;
    atlanan_ps_o_r = 0;
    durum_buf = 0;
    hedef_adres_buf = 0;
    etiket_gecerli = 0;
	
	if(guncelle_gecerli_i) begin
	    etiket_gecerli = 1;
	    if(guncelle_atladi_i) begin
	       atladi_ns = atladi + 1'b1;
		   hedef_adres_buf = guncelle_hedef_adresi_i;
		end
		
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
		if((etiket_anl==etiket_r[an_str_idx]) && (etiket_gecerli_r[an_str_idx])) begin
			ongoru_gecerli_o_r = 1'b1;
			if(durum_r[an_str_idx][1]) begin // ATLAR
				atlar_tahmin_ns = atlar_tahmin + 1'b1;
			    atlanan_ps_o_r = hedef_adres_r[an_str_idx];
			end
			else begin // ATLAMAZ
			    atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
				atlanan_ps_o_r = ps_i + 4;
		    end
		end
		
		else begin // ATLAMAZ
			    atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
				atlanan_ps_o_r = ps_i + 4;
		end
	end
	end
	
	
	always @(posedge clk_i) begin
	
	if(!rst_i) begin
	
		atlamaz_tahmin <= atlamaz_tahmin_ns;
        atlar_tahmin <= atlar_tahmin_ns; 
        atlamadi <= atlamadi_ns;
        atladi <= atladi_ns;
	
		if(guncelle_gecerli_i) begin
		    if(etiket_gun != etiket_r[gun_str_idx]) begin
                durum_r[gun_str_idx] <= GT;
            end
            else begin
                durum_r[gun_str_idx] <= durum_buf;
            end
            
            etiket_gecerli_r[gun_str_idx] <= etiket_gecerli; 
            etiket_r[gun_str_idx] <= etiket_gun; // emin degilim
   	 
			if(durum_buf[1]) begin // atlar yazilacaksa
				hedef_adres_r[gun_str_idx] <= hedef_adres_buf;
			end
		end
	end
	
	else begin // RESET
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
