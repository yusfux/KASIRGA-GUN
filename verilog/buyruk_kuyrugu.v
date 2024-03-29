`timescale 1ns / 1ps

module buyruk_kuyrugu(
   input         clk_i,
   input         rst_i,

   input         kuyruk_aktif_i,
   input         durdur_i,
   input         ps_atladi_i,

   input  [31:0] ps_i,
   input  [31:0] buyruk_i,               // Yeni gelen buyruk

   output [31:0] buyruk_o,               // Islenecek buyruk
   output [31:0] ps_o,
   output        ps_gecerli_o,
   output        buyruk_hazir_o,         // Cikisa verilen buyruk hazir

   output        ps_durdur_o,
   output        ps_iki_artir_o

);
   
localparam  DURUM_BOS           = 2'b00;     // Kuyrukta bos
localparam  DURUM_YARIM         = 2'b01;     // Kuyrukta yarim buyruk var
localparam  DURUM_SIKISTIRILMIS = 2'b10;     // Kuyrukta sikistirilmis buyruk var
localparam  DURUM_ATLADI        = 2'b11;

localparam  BUYRUK_TAM          = 2'b11; // En anlamsiz iki biti 1 ise buyruk tamdir

reg  [1:0]  durum_r;
reg  [1:0]  durum_ns;

reg  [15:0] kuyruk_r;
reg  [15:0] kuyruk_ns;

reg  [31:0] buyruk_o_cmb;
reg         buyruk_hazir_cmb;

reg  [31:0] ps_r;
reg  [31:0] ps_ns;
reg         ps_gecerli_cmb;

reg         ps_durdur_o_cmb;
reg         ps_iki_artir_o_cmb;

wire [1:0]  buyruk_i_birinci_kisim;
wire [1:0]  buyruk_i_ikinci_kisim;


always @(*) begin
   durum_ns = durum_r;
   kuyruk_ns = kuyruk_r;
   ps_ns = ps_r;
   ps_gecerli_cmb = 1'b0;
   buyruk_hazir_cmb = 1'b0;
   buyruk_o_cmb = 32'd0;
   ps_durdur_o_cmb = 1'b0;
   ps_iki_artir_o_cmb = 1'b0;

   if(kuyruk_aktif_i || (durum_r == DURUM_SIKISTIRILMIS && !durdur_i)) begin
      case (durum_r)
         DURUM_BOS: begin
            if(buyruk_i_birinci_kisim == BUYRUK_TAM) begin
               buyruk_o_cmb = buyruk_i;
               buyruk_hazir_cmb = 1'b1;
            end
            else begin
               buyruk_o_cmb[15:0] = buyruk_i[15:0];
               kuyruk_ns = buyruk_i[31:16];
               if(buyruk_i_ikinci_kisim == BUYRUK_TAM) begin
                  ps_ns = ps_i + 2'd2;
                  durum_ns = DURUM_YARIM;
                  buyruk_hazir_cmb = 1'b1;
               end
               else begin
                  ps_ns = ps_i + 2'd2;
                  if(kuyruk_aktif_i) begin
                     ps_durdur_o_cmb = 1'b1;
                     buyruk_hazir_cmb = 1'b1;
                  end
                  durum_ns = DURUM_SIKISTIRILMIS;
                  buyruk_hazir_cmb = 1'b1;
               end
            end
         end
         DURUM_YARIM: begin
            buyruk_o_cmb = {buyruk_i[15:0], kuyruk_r};
            kuyruk_ns = buyruk_i[31:16];
            ps_gecerli_cmb = 1'b1;
            if(buyruk_i_ikinci_kisim == BUYRUK_TAM) begin
               ps_ns = ps_i + 2'd2;
               durum_ns = DURUM_YARIM;
               buyruk_hazir_cmb = 1'b1;
            end
            else begin
               ps_ns = ps_i + 2'd2;
               if(kuyruk_aktif_i) begin
                  ps_durdur_o_cmb = 1'b1;
               end
               durum_ns = DURUM_SIKISTIRILMIS;
               buyruk_hazir_cmb = 1'b1;
            end
         end
         DURUM_SIKISTIRILMIS: begin
            buyruk_o_cmb = {16'b0, kuyruk_r};
            kuyruk_ns = 16'd0;
            ps_gecerli_cmb = 1'b1;
            durum_ns = DURUM_BOS;
            buyruk_hazir_cmb = 1'b1;
         end
         DURUM_ATLADI: begin
            if(ps_i[1:1]) begin
               ps_iki_artir_o_cmb = 1'b1;
               if(buyruk_i_ikinci_kisim == BUYRUK_TAM) begin
                  ps_ns = ps_i;
                  buyruk_o_cmb = 32'h0000_0013;
                  buyruk_hazir_cmb = 1'b1;
                  kuyruk_ns = buyruk_i[31:16];
                  durum_ns = DURUM_YARIM;
               end
               else begin
                  buyruk_o_cmb = buyruk_i[31:16];
                  buyruk_hazir_cmb = 1'b1;
                  durum_ns = DURUM_BOS;
               end
            end
            else begin
               if(buyruk_i_birinci_kisim == BUYRUK_TAM) begin
                  buyruk_o_cmb = buyruk_i;
                  durum_ns = DURUM_BOS;
                  buyruk_hazir_cmb = 1'b1;
               end
               else begin
                  buyruk_o_cmb[15:0] = buyruk_i[15:0];
                  kuyruk_ns = buyruk_i[31:16];
                  if(buyruk_i_ikinci_kisim == BUYRUK_TAM) begin
                     ps_ns = ps_i + 2'd2;
                     durum_ns = DURUM_YARIM;
                     buyruk_hazir_cmb = 1'b1;
                  end
                  else begin
                     ps_ns = ps_i + 2'd2;
                     if(kuyruk_aktif_i) begin
                        ps_durdur_o_cmb = 1'b1;
                        buyruk_hazir_cmb = 1'b1;
                     end
                     durum_ns = DURUM_SIKISTIRILMIS;
                     buyruk_hazir_cmb = 1'b1;
                  end
               end
            end
         end
      endcase
   end

   if(ps_atladi_i) begin
      durum_ns = DURUM_ATLADI;
      kuyruk_ns = kuyruk_r;
      ps_ns = ps_r;
   end
end

always @(posedge clk_i) begin
   if(!rst_i) begin
      kuyruk_r <= 16'd0;
      durum_r  <= 2'd0;
   end
   else if(kuyruk_aktif_i || ps_atladi_i || (durum_r == DURUM_SIKISTIRILMIS && !durdur_i)) begin
      durum_r  <= durum_ns;
      kuyruk_r <= kuyruk_ns;
      ps_r     <= ps_ns;
   end
end

assign buyruk_o               = buyruk_o_cmb;
assign buyruk_hazir_o         = buyruk_hazir_cmb;
assign ps_durdur_o            = ps_durdur_o_cmb;
assign ps_iki_artir_o         = ps_iki_artir_o_cmb;
assign ps_o                   = ps_r;
assign ps_gecerli_o           = ps_gecerli_cmb;
assign buyruk_i_birinci_kisim = buyruk_i[1:0];
assign buyruk_i_ikinci_kisim  = buyruk_i[17:16];
   
endmodule
