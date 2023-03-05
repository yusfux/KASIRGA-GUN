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
    /* Bu kisim program sayaci ureticisine girecek */
    output  [31:0]      atlanan_ps_o,       // Atlanilacak olan program sayaci
    output              ongoru_gecerli_o    // Ongoru gecerli
    );
    
    	// Satir numaralari
	wire [6:0]an_str_idx;
	assign an_str_idx =  ongoru_aktif_i ? ps_i[7:1] : 0;
	wire [6:0]gun_str_idx;
	assign gun_str_idx = guncelle_gecerli_i ? guncelle_ps_i[7:1] : 0;
	
	
    reg [127:0] etiket_gecerli_r;
	reg [1:0] durum_r [127:0];
	
	reg  [31:0] hedef_veri_i_r;
	wire [31:0] hedef_veri_o_w;
	reg  [6:0]  hedef_adresi_r;
	reg bram_en_r;
	reg bram_wen_r;
	
	
	blk_mem_gen_2 block_memory_dallanma_hadres(
    .clka(clk_i),
    .rsta(!rst_i),
    .ena(bram_en_r),
    .wea(bram_wen_r),
    .addra(hedef_adresi_r),
    .dina(hedef_veri_i_r),
    .douta(hedef_veri_o_w)
);

    reg  [23:0] etk_hedef_veri_i_r;
	wire [23:0] etk_hedef_veri_o_w;
	reg  [6:0]  etk_hedef_adresi_r;
	reg etk_bram_en_r;
	reg etk_bram_wen_r;
	
	
	blk_mem_gen_3 block_memory_dallanma_etiket(
    .clka(clk_i),
    .rsta(!rst_i),
    .ena(etk_bram_en_r),
    .wea(etk_bram_wen_r),
    .addra(etk_hedef_adresi_r),
    .dina(etk_hedef_veri_i_r),
    .douta(etk_hedef_veri_o_w)
);
	
	reg [1:0] durum_buf;
  
	// Etiket
	wire [23:0] etiket_gun;
	assign etiket_gun = guncelle_gecerli_i ? guncelle_ps_i[31:8] : 0; 
	
	wire [23:0] etiket_anl;
	assign etiket_anl = ongoru_aktif_i ? ps_i[31:8] : 0; 
	
	reg  etiket_gecerli;
	
	// Durumlar
    localparam GT = 2'b00;
	localparam ZT = 2'b01;
	localparam ZA = 2'b10;
	localparam GA = 2'b11;
    
	reg [31:0] atlanan_ps_o_r;
	assign atlanan_ps_o = atlanan_ps_o_r;
	
	reg ongoru_gecerli_o_r;
	assign ongoru_gecerli_o = ongoru_gecerli_o_r; 

	// TEST ICIN
    reg [31:0]atlamaz_tahmin;
    reg [31:0]atlar_tahmin;
    reg [31:0]atladi;
    reg [31:0]atlamadi;
    
    reg [31:0]atlamaz_tahmin_ns;
    reg [31:0]atlar_tahmin_ns;
    reg [31:0]atladi_ns;
    reg [31:0]atlamadi_ns;
	
    integer i;
	
	always @* begin
	
	atlamaz_tahmin_ns = atlamaz_tahmin;
	atlar_tahmin_ns = atlar_tahmin;
	atlamadi_ns = atlamadi;
	atladi_ns = atladi;
	
    ongoru_gecerli_o_r = 1'b0;
    atlanan_ps_o_r = 32'd0;
    durum_buf = 2'd0;
    etiket_gecerli = 1'b0;
	 
	bram_en_r = 1'b0;
	bram_wen_r = 1'b0;
	hedef_adresi_r = 7'd0;
	hedef_veri_i_r = 32'd0;
	
	etk_bram_en_r = 1'b0;
	etk_bram_wen_r = 1'b0;
	etk_hedef_adresi_r = 7'd0;
	etk_hedef_veri_i_r = 24'd0;
	
	if(guncelle_gecerli_i) begin
	    etiket_gecerli = 1'b1;
	    etk_hedef_veri_i_r = etiket_gun;
	    etk_hedef_adresi_r = gun_str_idx;
		etk_bram_en_r = 1'b1;
		etk_bram_wen_r = 1'b1;

	    if(guncelle_atladi_i) begin
	         atladi_ns = atladi + 1'b1;
			 hedef_veri_i_r = guncelle_hedef_adresi_i;
			 hedef_adresi_r = gun_str_idx;
			 bram_en_r = 1'b1;
			 bram_wen_r = 1'b1;
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
        etk_hedef_adresi_r = an_str_idx;
        etk_bram_en_r = 1'b1;
        etk_bram_wen_r = 1'b0;	
        
		if((etiket_anl==etk_hedef_veri_o_w) && (etiket_gecerli_r[an_str_idx])) begin
//			ongoru_gecerli_o_r = 1'b1;
			
			if(durum_r[an_str_idx][1]) begin // ATLAR
			    ongoru_gecerli_o_r = 1'b1;
				atlar_tahmin_ns = atlar_tahmin + 1'b1;
				atlanan_ps_o_r = hedef_veri_o_w;
				hedef_adresi_r = an_str_idx;
			    bram_en_r = 1'b1;
			    bram_wen_r = 1'b0;
			end
			else begin // ATLAMAZ
			    atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
				atlanan_ps_o_r = ps_i + 3'd4;
		    end
		end
		
		else begin // ATLAMAZ
			    atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
				atlanan_ps_o_r = ps_i + 3'd4;
		end
	end
	end
	
	
	always @(posedge clk_i) begin
	
	if(rst_i) begin
	    
		atlamaz_tahmin <= atlamaz_tahmin_ns;
        atlar_tahmin <= atlar_tahmin_ns; 
        atlamadi <= atlamadi_ns;
        atladi <= atladi_ns;
	
		if(guncelle_gecerli_i) begin
		    if((etiket_gecerli_r[gun_str_idx]) && etiket_gun != etk_hedef_veri_o_w) begin //
                durum_r[gun_str_idx] <= GT;
            end
            else begin
                durum_r[gun_str_idx] <= durum_buf;
            end
            
            etiket_gecerli_r[gun_str_idx] <= etiket_gecerli; 
		end
	end
	
	else begin // RESET
	    atlamaz_tahmin <= 32'd0;
        atlar_tahmin <= 32'd0; 
        atlamadi <= 32'd0;
        atladi <= 32'd0;
		  
		etiket_gecerli_r <= 128'd0;
        
		for(i=0;i<128;i=i+1) begin
			durum_r[i] <= 2'd0;
		end
	end
	
	end
  
endmodule
