`define SPI_CTRL   5'h00
`define SPI_STATUS 5'h04
`define SPI_RDATA  5'h08
`define SPI_WDATA  5'h0c
`define SPI_CMD    5'h10

`timescale 1ns / 1ps

module spi(
    input         clk_i,
    input         rst_i,

    input  [4:0]  adres_bit_i,
    input         islem_i,
    input         islem_gecerli_i,
    input  [1:0]  read_type_i,
    input  [1:0]  write_type_i,
    input  [31:0] veri_i,

    output        islem_bitti_o,
    output [31:0] veri_o,

    output        cs_o,
    output        sck_o,
    output        spi_mosi_o,
    input         spi_miso_i
);
    localparam   DURUM_IDLE     = 2'b00;
    localparam   DURUM_RECEIVE  = 2'b01;
    localparam   DURUM_TRANSMIT = 2'b10;
    localparam   DURUM_BOS      = 2'b11;

    reg          islem_bitti_r;
    reg          islem_bitti_ns;
    reg          stall_cmb;

    reg          cs_r;
    reg          cs_ns;
    reg          sck_r;
    reg          sck_ns;
    reg          spi_mosi_r;
    reg          spi_mosi_ns;

    reg  [255:0] miso_buffer_r;
    reg  [255:0] miso_buffer_ns;
    reg  [8:0]   miso_count_r;
    reg  [8:0]   miso_count_ns;
    wire [7:0]   miso_pointer_w;

    reg  [255:0] mosi_buffer_r;
    reg  [255:0] mosi_buffer_ns;
    reg  [8:0]   mosi_count_r;
    reg  [8:0]   mosi_count_ns;
    wire [7:0]   mosi_pointer_w;

    reg  [31:0]  spi_ctrl_r;
    reg  [31:0]  spi_ctrl_ns;

    reg  [5:0]   spi_status_r;
    reg  [5:0]   spi_status_ns;

    reg  [111:0] cmd_buffer_r;
    reg  [111:0] cmd_buffer_ns;
    reg  [3:0]   cmd_count_r;
    reg  [3:0]   cmd_count_ns;
    reg  [13:0]  cmd_current_r;
    reg  [13:0]  cmd_current_ns;

    reg  [31:0]  veri_r;
    reg  [31:0]  veri_ns;

    reg  [1:0]   durum_r;
    reg  [1:0]   durum_ns;

    reg  [15:0]  sayac_r;
    reg  [15:0]  sayac_ns;

    wire         spi_en_w;
    wire         spi_rst_w;
    wire         cpha_w;
    wire         cpol_w;
    wire [15:0]  sck_div_w;

    wire [8:0]   length_w;
    wire         cs_active_w;

    reg  [9:0]   transferred_length_r;
    reg  [9:0]   transferred_length_ns;    
    reg  [2:0]   bit_count_r;
    reg  [2:0]   bit_count_ns;
    
    always @(*) begin
        islem_bitti_ns = 0;
        stall_cmb = 0;
        veri_ns = veri_r;
        cs_ns = cs_r;
        sck_ns = sck_r;
        spi_mosi_ns = spi_mosi_r;
        miso_buffer_ns = miso_buffer_r;
        miso_count_ns = miso_count_r;
        mosi_buffer_ns = mosi_buffer_r;
        mosi_count_ns = mosi_count_r;
        spi_ctrl_ns = spi_ctrl_r;
        spi_status_ns = spi_status_r;
        cmd_buffer_ns = cmd_buffer_r;
        cmd_count_ns = cmd_count_r;
        durum_ns = durum_r;
        sayac_ns = sayac_r;
        cmd_current_ns = cmd_current_r;
        transferred_length_ns = transferred_length_r;
        bit_count_ns = bit_count_r;

        case (durum_r)
        DURUM_IDLE: begin
            sck_ns = cpol_w;
            if(spi_en_w && cmd_count_r == 0) begin
                stall_cmb = 1;
                cmd_current_ns = cmd_buffer_r[13:0];
                cmd_buffer_ns = cmd_buffer_r >> 14;
                cmd_count_ns = cmd_buffer_r - 1;
                spi_status_ns[4:4] = 0;
                if(cmd_count_r == 1) begin
                    spi_status_ns[5:5] = 1;
                end
                sayac_ns = 16'b0;
                cs_ns = 0;
                transferred_length_ns = 0;
                bit_count_ns = 0;
                case (cmd_buffer_r[13:12])
                2'b00: begin // bos dongu (her neyse artik bu)
                    durum_ns = DURUM_BOS;
                end
                2'b01: begin // miso
                    durum_ns = DURUM_RECEIVE;
                end
                2'b10: begin // mosi
                    durum_ns = DURUM_TRANSMIT;
                end
                endcase
            end
        end
        DURUM_RECEIVE: begin
            sayac_ns = sayac_r + 1;
            if(sayac_r == sck_div_w) begin
                sayac_ns = 16'b0;
                stall_cmb = 1;

                sck_ns = !sck_r;
                if(sck_r && cpha_w) begin // negedge
                    if(!(miso_count_r >= 256)) begin
                        miso_buffer_ns[miso_pointer_w +: 1] = spi_miso_i;
                        miso_count_ns = miso_count_r + 1;
                    end
                    bit_count_ns = bit_count_r + 1;

                    if(miso_count_r >= 31) begin
                        spi_status_ns[3:3] = 1'b0;
                    end

                    if(miso_count_r >= 255) begin
                        spi_status_ns[2:2] = 1'b1;
                        miso_count_ns = 0;
                    end
                end
                else if(!cpha_w) begin // posedge
                    if(!(miso_count_r >= 256)) begin
                        miso_buffer_ns[miso_pointer_w +: 1] = spi_miso_i;
                        miso_count_ns = miso_count_r + 1;
                    end
                    bit_count_ns = bit_count_r + 1;

                    if(miso_count_r >= 31) begin
                        spi_status_ns[3:3] = 1'b0;
                    end

                    if(miso_count_r >= 255) begin
                        spi_status_ns[2:2] = 1'b1;
                        miso_count_ns = 0;
                    end
                end
                
                if(bit_count_r == 3'b111) begin
                    transferred_length_ns = transferred_length_r + 1;
                    if(transferred_length_r == length_w) begin
                        if(cs_active_w) begin
                            cs_ns = 0;
                        end
                        else begin
                            cs_ns = 1;
                        end
                    end
                end
            end
        end
        DURUM_TRANSMIT: begin
            sayac_ns = sayac_r + 1;
            if(sayac_r == sck_div_w) begin
                sayac_ns = 16'b0;
                stall_cmb = 1;

                sck_ns = !sck_r;
                if(sck_r && !cpha_w) begin // negedge
                    if(mosi_count_r == 0) begin
                        spi_mosi_ns = 1'b0;
                    end
                    else begin
                        spi_mosi_ns = mosi_buffer_r[0:0];
                        mosi_count_ns = mosi_count_r - 1;
                    end
                    bit_count_ns = bit_count_r + 1;

                    if(mosi_count_r == 1) begin
                        spi_status_ns[1:1] = 1'b1;
                    end

                    if(mosi_count_r <= 225) begin
                        spi_status_ns[0:0] = 1'b0;
                    end
                end
                else if(cpha_w) begin // posedge
                    if(mosi_count_r == 0) begin
                        spi_mosi_ns = 1'b0;
                    end
                    else begin
                        spi_mosi_ns = mosi_buffer_r[0:0];
                        mosi_count_ns = mosi_count_r - 1;
                    end
                    bit_count_ns = bit_count_r + 1;

                    if(mosi_count_r == 1) begin
                        spi_status_ns[1:1] = 1'b1;
                    end

                    if(mosi_count_r <= 225) begin
                        spi_status_ns[0:0] = 1'b0;
                    end
                end

                if(bit_count_r == 3'b111) begin
                    transferred_length_ns = transferred_length_r + 1;
                    if(transferred_length_r == length_w) begin
                        if(cs_active_w) begin
                            cs_ns = 0;
                        end
                        else begin
                            cs_ns = 1;
                        end
                    end
                end
            end
        end
        DURUM_BOS: begin // bu durum cok sacma oldu groupsa sormak sart (direction = bos dongu)
            sayac_ns = sayac_r + 1;
            if(sayac_r == sck_div_w) begin
                sayac_ns = 16'b0;
                stall_cmb = 1;

                sck_ns = !sck_r;

                bit_count_ns = bit_count_r + 1;
                if(bit_count_r == 3'b111) begin
                    transferred_length_ns = transferred_length_r + 1;
                    if(transferred_length_r == length_w) begin
                        if(cs_active_w) begin
                            cs_ns = 0;
                        end
                        else begin
                            cs_ns = 1;
                        end
                        durum_ns = DURUM_IDLE;
                    end
                end
            end
        end
        endcase

        if(islem_gecerli_i && !stall_cmb) begin
            if(islem_i) begin // yaz
                case ({adres_bit_i[4:2], 2'b00})
                `SPI_CTRL: begin
                    case (write_type_i)
                    2'b00: begin
                        spi_ctrl_ns[(adres_bit_i[1:0]*8) +: 8] = veri_i[7:0];
                        islem_bitti_ns = 1;
                    end
                    2'b01: begin
                        spi_ctrl_ns[(adres_bit_i[1:1]*16) +: 16] = veri_i[15:0];
                        islem_bitti_ns = 1;
                    end
                    2'b11: begin
                        spi_ctrl_ns[31:0] = veri_i[31:0];
                        islem_bitti_ns = 1;
                    end
                    endcase
                end
                `SPI_STATUS: begin
                    // sadece okuma
                    islem_bitti_ns = 1;
                end
                `SPI_RDATA: begin
                    // sadece okuma
                    islem_bitti_ns = 1;
                end
                `SPI_WDATA: begin
                    spi_status_ns[1:1] = 0;
                    if(mosi_count_r == 256) begin
                        islem_bitti_ns = 1;
                    end
                    else begin
                        if(mosi_count_r >= 224) begin
                            spi_status_ns[0:0] = 1;
                            mosi_count_ns = 256;
                        end
                        else begin
                            mosi_count_ns = mosi_count_r + 32;
                        end
                        case (write_type_i)
                        2'b00: begin
                            mosi_buffer_ns[mosi_pointer_w +: 32] = {24'b0, veri_i[7:0]};
                            islem_bitti_ns = 1;
                        end
                        2'b01: begin
                            mosi_buffer_ns[mosi_pointer_w +: 32] = {16'b0, veri_i[15:0]};
                            islem_bitti_ns = 1;
                        end
                        2'b11: begin
                            mosi_buffer_ns[mosi_pointer_w +: 32] = veri_i[31:0];
                            islem_bitti_ns = 1;
                        end
                        endcase
                    end
                end
                `SPI_CMD: begin
                    spi_status_ns[5:5] = 0;
                    if(cmd_count_r == 8) begin
                        islem_bitti_ns = 1;
                    end
                    else begin
                        if(cmd_count_r >= 7) begin
                            spi_status_ns[4:4] = 1;
                        end
                        cmd_count_ns = cmd_count_r + 1;
                        case (write_type_i)
                        2'b00: begin
                            cmd_buffer_ns[(cmd_count_r*14) +: 14] = {6'b0, veri_i[7:0]};
                            islem_bitti_ns = 1;
                        end
                        2'b01: begin
                            cmd_buffer_ns[(cmd_count_r*14) +: 14] = veri_i[13:0];
                            islem_bitti_ns = 1;
                        end
                        2'b11: begin
                            cmd_buffer_ns[(cmd_count_r*14) +: 14] = veri_i[13:0];
                            islem_bitti_ns = 1;
                        end
                        endcase
                    end
                end
                endcase
            end
            else begin // oku
                case ({adres_bit_i[4:2], 2'b00})
                `SPI_CTRL: begin
                    case (read_type_i)
                    2'b00: begin
                        veri_ns[31:0] = {24'b0, spi_ctrl_r[7:0]};
                        islem_bitti_ns = 1;
                    end
                    2'b01: begin
                        veri_ns[31:0] = {16'b0, spi_ctrl_r[15:0]};
                        islem_bitti_ns = 1;
                    end
                    2'b11: begin
                        veri_ns[31:0] = spi_ctrl_r[31:0];
                        islem_bitti_ns = 1;
                    end
                    endcase
                end
                `SPI_STATUS: begin
                    veri_ns[31:0] = {26'b0, spi_status_r[5:0]};
                    islem_bitti_ns = 1;
                end
                `SPI_RDATA: begin
                    spi_status_ns[2:2] = 1'b0;
                    if(miso_count_r == 0) begin
                        veri_ns = 32'b0;
                        islem_bitti_ns = 1;
                    end
                    else begin
                        miso_buffer_ns = miso_buffer_r >> 32;
                        if(miso_count_r <= 32) begin
                            spi_status_ns[3:3] = 1'b1;
                            miso_count_ns = 0;
                        end
                        else begin
                            miso_count_ns = miso_count_r - 32;
                        end
                        case (read_type_i)
                        2'b00: begin
                            veri_ns[31:0] = {24'b0, miso_buffer_r[7:0]};
                            islem_bitti_ns = 1;
                        end
                        2'b01: begin
                            veri_ns[31:0] = {16'b0, miso_buffer_r[15:0]};
                            islem_bitti_ns = 1;
                        end
                        2'b11: begin
                            veri_ns[31:0] = miso_buffer_r[31:0];
                            islem_bitti_ns = 1;
                        end
                        endcase
                    end
                end
                `SPI_WDATA: begin
                    // sadece yazma
                    islem_bitti_ns = 1;
                end
                `SPI_CMD: begin
                    // sadece yazma
                    islem_bitti_ns = 1;
                end
                endcase
            end
        end
    end

    always @(posedge clk_i) begin
        if(!rst_i || spi_ctrl_r[1:1]) begin
            cs_r          <= 1'b1;
            sck_r         <= 1'b0;
            spi_mosi_r    <= 1'b0;
            islem_bitti_r <= 1'b0;
            spi_ctrl_r    <= 32'b0;
            spi_status_r  <= 6'b101010;
            miso_buffer_r <= 256'b0;
            miso_count_r  <= 9'b0;
            mosi_buffer_r <= 256'b0;
            mosi_count_r  <= 9'b0;
            cmd_buffer_r  <= 112'b0;
            cmd_count_r   <= 9'b0;
            durum_r       <= 2'b0;
            sayac_r       <= 16'b0;
        end
        else begin
            cs_r                 <= cs_ns;
            sck_r                <= sck_ns;
            spi_mosi_r           <= spi_mosi_r;
            islem_bitti_r        <= islem_bitti_ns;
            veri_r               <= veri_ns;
            spi_ctrl_r           <= spi_ctrl_ns;
            spi_status_r         <= spi_status_ns;
            miso_buffer_r        <= miso_buffer_ns;
            miso_count_r         <= miso_count_ns;
            mosi_buffer_r        <= mosi_buffer_ns;
            mosi_count_r         <= mosi_count_ns;
            cmd_buffer_r         <= cmd_buffer_ns;
            cmd_count_r          <= cmd_count_ns;
            durum_r              <= durum_ns;
            sayac_r              <= sayac_ns;
            cmd_current_r        <= cmd_current_ns;
            transferred_length_r <= transferred_length_ns;
            bit_count_r          <= bit_count_ns;
        end
    end

    assign islem_bitti_o  = islem_bitti_r;
    assign veri_o         = veri_r;
    assign cs_o           = cs_r;
    assign sck_o          = sck_r;
    assign spi_mosi_o     = spi_mosi_r;
    assign miso_pointer_w = miso_count_r[7:0];
    assign mosi_pointer_w = mosi_count_r[7:0];

    assign spi_en_w       = spi_ctrl_r[0:0];
    assign spi_rst_w      = spi_ctrl_r[1:1];
    assign cpha_w         = spi_ctrl_r[2:2];
    assign cpol_w         = spi_ctrl_r[3:3];
    assign sck_div_w      = spi_ctrl_r[31:16];

    assign length_w       = cmd_current_r[8:0];
    assign cs_active_w    = cmd_current_r[9:9];
endmodule
