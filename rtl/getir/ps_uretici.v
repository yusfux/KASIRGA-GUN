`timescale 1ns / 1ps
module ps_uretici(
    input         clk_i,
    input         rst_i,

    input         ps_durdur_i,

    input         ps_atlat_aktif_i,
    input  [31:0] ps_atlanacak_adres_i,

    input         dallanma_hata_i,
    input  [31:0] guncelle_hedef_adresi_i,

    input         jal_gecerli_i,
    input  [31:0] jal_adres_i,

    input         mret_gecerli_i,
    input  [31:0] mret_ps_i,
    
    output [31:0] ps_ongorucu_o,
    output [31:0] ps_o

    );

reg [31:0] ps_o_r  = 0;
reg [31:0] ps_o_ns = 0;

always @(*) begin
    if(!rst_i) begin
        ps_o_ns = 0;
    end
    else begin
        if(dallanma_hata_i) begin
            ps_o_ns = guncelle_hedef_adresi_i;
        end
        else if(mret_gecerli_i) begin
            ps_o_ns = mret_ps_i;
        end
        else if(jal_gecerli_i) begin
            ps_o_ns = jal_adres_i;
        end
        else if(ps_atlat_aktif_i) begin
            ps_o_ns = ps_atlanacak_adres_i;
        end
        else begin
            ps_o_ns = ps_o_r + 4;
        end
    end
end

always @(posedge clk_i) begin
    if(!rst_i) begin
        ps_o_r <= 0;
    end
    else begin
        if(!ps_durdur_i) begin
            ps_o_r <= ps_o_ns;
        end
    end
end

assign ps_o = ps_o_ns;//ps_atlat_aktif_i ? ps_atlanacak_adres_i : ps_o_r;
assign ps_ongorucu_o = ps_o_r;//ps_o_r;

endmodule
