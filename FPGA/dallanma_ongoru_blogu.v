`timescale 1ns / 1ps

// BIMODAL BRANCH PREDICTOR

module dallanma_ongoru_blogu #(parameter hafiza_boyutu = 64)(
   // Saat ve reset
    input               clk_i,
    input               rst_i,
   
    input               ongoru_aktif_i, // ONCOZUCU BRANCH GELINCE AKTIVE EDICEK *
   
   // Dallanma cozuldukten sonra gercek sonucu gosteren guncelleme sinyalleri
    input               guncelle_gecerli_i, // Guncelleme aktif
    input               guncelle_atladi_i,  // Ilgili dallanma atladi
    input   [31:0]      guncelle_ps_i,      // Ilgili dallanmanin program sayaci
    input   [31:0]      guncelle_hedef_adresi_i, // Hedef adres ayarlamasi yapilacak
   
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
   localparam idx_width = $clog2(hafiza_boyutu);
   
   wire [idx_width-1:0]an_str_idx;
   assign an_str_idx =  ongoru_aktif_i ? ps_i[idx_width:1] : 0;
   wire [idx_width-1:0]gun_str_idx;
   assign gun_str_idx = guncelle_gecerli_i ? guncelle_ps_i[idx_width:1] : 0;
   
   reg [hafiza_boyutu-1'b1:0] etiket_gecerli_r;
   reg [1:0] durum_r [hafiza_boyutu-1'b1:0];
   reg [30-hafiza_boyutu:0] etiket_r [hafiza_boyutu-1'b1:0];
   reg [31:0] hedef_adres_r [hafiza_boyutu-1'b1:0];
   reg [31:0] hedef_adres_buf;
   reg [1:0] durum_buf;
  
   // Etiket
   wire [5'd30-idx_width:0] etiket_gun;
   assign etiket_gun =  guncelle_ps_i[31:idx_width+1'b1]; 
   
   wire [5'd30-idx_width:0] etiket_anl;
   assign etiket_anl = ps_i[31:idx_width+1'b1]; 
   
   reg  etiket_gecerli;
   reg  [idx_width-1:0] gun_str_idx_buf;
   
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
   reg [123:0]atlamaz_tahmin;
   reg [123:0]atlar_tahmin;
   reg [123:0]atladi;
   reg [123:0]atlamadi;
   
   reg [123:0]atlamaz_tahmin_ns;
   reg [123:0]atlar_tahmin_ns;
   reg [123:0]atladi_ns;
   reg [123:0]atlamadi_ns;
   
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
    
      hedef_adres_buf = 32'd0;
   
      if(guncelle_gecerli_i) begin
        etiket_gecerli = 1'b1;
        if(guncelle_atladi_i) begin
           atladi_ns = atladi + 1'b1;
           hedef_adres_buf = guncelle_hedef_adresi_i;
           gun_str_idx_buf = gun_str_idx;
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
              if(guncelle_atladi_i) begin
                 durum_buf = ZA;
              end 
                else    
                 durum_buf = GT;      
           end
              
           ZA : begin
              if(guncelle_atladi_i) begin
                 durum_buf = GA;
              end
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
           if(durum_r[an_str_idx][1]) begin // ATLAR
              ongoru_gecerli_o_r = 1'b1;
              atlar_tahmin_ns = atlar_tahmin + 1'b1;      
              atlanan_ps_o_r = hedef_adres_r[an_str_idx];
           end
           else begin // ATLAMAZ
              atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
              //atlanan_ps_o_r = ps_i + 3'd4;
           end
           end
        else begin // ATLAMAZ
           atlamaz_tahmin_ns = atlamaz_tahmin + 1'b1;
           //atlanan_ps_o_r = ps_i + 3'd4;
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
         if((etiket_gecerli_r[gun_str_idx]) && etiket_gun != etiket_r[gun_str_idx]) begin 
            durum_r[gun_str_idx] <= GT;
         end
         else begin
            durum_r[gun_str_idx] <= durum_buf;
         end
           
         if(guncelle_atladi_i) begin
            etiket_gecerli_r[gun_str_idx] <= etiket_gecerli; 
            etiket_r[gun_str_idx] <= etiket_gun;   
            if(durum_buf[1]) begin // atlar yazilacaksa
               hedef_adres_r[gun_str_idx] <= hedef_adres_buf;
            end
         end
      end
   end
     
   else begin // RESET
      atlamaz_tahmin   <= 124'd0;
      atlar_tahmin     <= 124'd0; 
      atlamadi         <= 124'd0;
      atladi           <= 124'd0;
      etiket_gecerli_r <= 128'd0;  
      
      for(i=0;i<hafiza_boyutu;i=i+1) begin
         durum_r[i] <= 2'd0;
      end
   end
   end
  
  wire [124:0] toplam_tahmin;
  assign toplam_tahmin = atlar_tahmin + atlamaz_tahmin;
  reg [123:0] hatali_tahmin = 124'd0;
  wire [15:0] dogru_tahmin_yuzde;
  assign dogru_tahmin_yuzde = (100*(toplam_tahmin - hatali_tahmin))/toplam_tahmin;
  
  always @(posedge clk_i) begin
   if(dallanma_hata_i) begin
      hatali_tahmin <= hatali_tahmin + 1'b1;
   end
  
  end
  
  
endmodule