`timescale 1ns / 1ps

// SIGNED 33 CEVRIM / UNSIGNED 33 CEVRIM
module bolme(
        input            clk_i,
        input            rst_i,
        
        input            istek_i, 
        input            sign_i, //unsigned:0, signed:1
        input   [31:0]   bolunen_i,
        input   [31:0]   bolen_i,
        
        output  [31:0]   bolum_o,
        output  [31:0]   kalan_o,
        output           result_ready_o
);

    reg [5:0] Ncounter_ns;
    reg [5:0] Ncounter_r;
    
    reg [31:0] a_ns;
    reg [31:0] q_ns;
    reg [31:0] m_ns;
    
    reg [31:0] a_r;
    reg [31:0] q_r;
    reg [31:0] m_r;  
    
    reg [31:0] q;//quotient
    reg [31:0] a;//remainder
    
    reg [31:0] q2;//quotient
    reg [31:0] a2;//remainder
 
    reg result_ready_r;
    reg result_ready_ns;
    reg [1:0] durum_r; 
    reg [1:0] durum_ns;
    
    reg bolen_isaret_r;
    reg bolunen_isaret_r;
    reg bolen_isaret_ns;
    reg bolunen_isaret_ns;
        
    localparam ISLEM_BEKLE = 2'b00;
    localparam ISLEM       = 2'b01;
    localparam SIGNED_SONUC= 2'B10;
    localparam TAMAMLANDI  = 2'b11;
    
    assign bolum_o = q_ns;
    assign kalan_o = a_ns;  
    assign result_ready_o = result_ready_ns; 
   
    always @* begin
        result_ready_ns   = 1'b0;
        a_ns              = a_r;
        q_ns              = q_r;
        m_ns              = m_r;
        Ncounter_ns       = Ncounter_r;
        durum_ns          = durum_r;
        bolen_isaret_ns   = bolen_isaret_r;   
        bolunen_isaret_ns = bolunen_isaret_r;
         
        case(durum_r)
            ISLEM_BEKLE: begin 
                if (istek_i) begin  
                    if(bolen_i == 32'd0) begin //DIVISION BY ZERO!
                        if(sign_i)begin
                            q_ns=32'hffffffff; //-1
                        end
                        else begin
                            q_ns=32'hffffffff; // max 
                        end
                        a_ns = bolunen_i;
                        durum_ns = ISLEM_BEKLE;
                        result_ready_ns= 1'b1;
                    end
                    else if(sign_i == 1 && bolunen_i == 32'h80000000 && bolen_i == 32'hffffffff)begin //OVERFLOW
                        q_ns= bolunen_i;
                        a_ns = 32'd0;
                        durum_ns = ISLEM_BEKLE;
                        result_ready_ns= 1'b1;
                    end
                    else if(sign_i) begin
                        a_ns              = 32'd0;
                        m_ns              = bolen_i;
                        q_ns              = bolunen_i;    
                        if(bolen_i[31])begin
                            m_ns              = ~bolen_i + 1;           
                        end  
                        if(bolunen_i[31])begin
                            q_ns              = ~bolunen_i + 1;   
                        end    
                        bolen_isaret_ns   = bolen_i[31];   
                        bolunen_isaret_ns = bolunen_i[31];                 
                        durum_ns       = ISLEM;
                    end
                    else begin
                        a_ns               = 32'd0;
                        m_ns               = bolen_i;
                        q_ns               = bolunen_i;
                        if(bolen_i[31])begin
                            m_ns              = ~bolen_i + 1;           
                        end  
                        if(bolunen_i[31])begin
                            q_ns              = ~bolunen_i + 1;   
                        end 
                        durum_ns       = ISLEM;                        
                    end
                end
            end    
            ISLEM: begin
                if(a_r[31])begin
                    a    = a_r << 1;
                    a[0] = q_r[31];
                    q_ns    = q_r << 1;
                    a_ns = a + m_r;       
                end
                else begin
                    a    = a_r << 1;
                    a[0] = q_r[31];
                    q_ns    = q_r << 1;
                    a_ns = a - m_r;       
                end
                q_ns[0] = 1'b1;
                if(a_r[31])begin
                    q_ns[0] = 1'b0;
                end
                Ncounter_ns = Ncounter_r - 1'b1;
                
                if(Ncounter_ns == 6'd0)begin
                    durum_ns = TAMAMLANDI;
                end
            end
            TAMAMLANDI: begin
                if(a_r[31])begin
                    a_ns       = a_r + m_r;
                end
                q_ns    = q_r << 1;
                q_ns[0] = 1'b1;
                if(a_r[31])begin
                   q_ns[0] = 1'b0;
                end
                if(sign_i) begin
                    durum_ns        = SIGNED_SONUC;   
                end
                else begin
                    result_ready_ns = 1'b1;  
                    Ncounter_ns        = 6'd32;//TEKRAR BAK EMIN DEGILIM         
                    durum_ns        = ISLEM_BEKLE;    
                end
            end
            SIGNED_SONUC: begin
                    if(bolunen_isaret_r == 1 && bolen_isaret_r == 1 && a_r != 32'd0)begin
                            //a_ns[31] = 1'b1;
                            a_ns = ~a_r+1;
                    end
                    else if(bolunen_isaret_r == 1 && bolen_isaret_r == 0) begin
                        q_ns = ~(q_r)+1;                     
                        if(a_r != 0) begin
                            //q_ns = q_r + 1;
                           // q_ns = ~(q_r + 1)+1;
                           // a_ns = m_r + 1 + ~a_r;
                            a_ns = ~a_r + 1; 
                            //a_ns[31] = 1'b0;
                            //q_ns[31] = 1'b1;
                        end
                    end
                    else if(bolunen_isaret_r == 0 && bolen_isaret_r == 1) begin
                        q_ns = ~(q_r)+1;                    
                        if(a_r != 0) begin
                            //q_ns = ~(q_r + 1)+1;
                           // a_ns = ~a_r + 1;   
                            a_ns = a_r;
                        end
                    end   
                    Ncounter_ns        = 6'd32;//TEKRAR BAK EMIN DEGILIM   
                    result_ready_ns = 1'b1;        
                    durum_ns        = ISLEM_BEKLE;          
            end
        endcase
    end
    
    always @(posedge clk_i)begin
        if(!rst_i)begin
            result_ready_r    <= 1'b0;  
            a_r               <= 32'd0;
            m_r               <= 32'd0;
            q_r               <= 32'd0;
            Ncounter_r        <= 6'd32;   
            durum_r           <= ISLEM_BEKLE;
            bolen_isaret_r    <= 1'b0;   
            bolunen_isaret_r  <= 1'b0;        
            q                 <= 32'd0;
            a                 <= 32'd0;
            q2                <= 32'd0;
            a2                <= 32'd0;
        end
        else begin
            Ncounter_r        <= Ncounter_ns;
            result_ready_r    <= result_ready_ns;
            a_r               <= a_ns;
            q_r               <= q_ns;
            m_r               <= m_ns;  
            durum_r           <= durum_ns;
            bolen_isaret_r    <= bolen_isaret_ns;   
            bolunen_isaret_r  <= bolunen_isaret_ns;
        end
    end
    
endmodule
