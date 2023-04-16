`timescale 1ns / 1ps
/*
 Response sinyalleri ayarlanacak
*/


module axi_interface_uart(
     input              s_axi_aclk_i, 
     input              s_axi_aresetn_i,
     
     //         READ SIGNALS 
    // ar -> address read (address in)
    // r  -> read (data out)
     input   [31:0]     s_axi_araddr_i,  
     output             s_axi_arready_o,  
     input              s_axi_arvalid_i,     
     input              s_axi_rready_i,
     output             s_axi_rvalid_o, 
     output  [31:0]     s_axi_rdata_o, 
     
     //         WRITE SIGNALS
    // aw -> address write (address in)
     // w  -> write (data in)
    // b  -> response 
    
     input   [31:0]     s_axi_awaddr_i,
     output             s_axi_awready_o,
     input              s_axi_awvalid_i,  
     input   [31:0]     s_axi_wdata_i,
     output             s_axi_wready_o,
     input   [3:0]      s_axi_wstrb_i, // kullanmadim
     input              s_axi_wvalid_i,     
     input              s_axi_bready_i,
     output             s_axi_bvalid_o,    
     
     // UART
     input              r_done_i,
     input              t_done_i,
     input   [7:0]      rx_i,
     output             rx_en_o,
     output             tx_en_o,
     output  [7:0]      tx_o,
     output  [15:0]     baud_div_o,
     input   [3:0]      read_size_i
    );
    
   // OUTPUTS
   reg s_axi_arready_o_r      ;
   reg s_axi_rvalid_o_r       ;
   reg [31:0] s_axi_rdata_o_r ;
   reg s_axi_awready_o_r      ;
   reg s_axi_wready_o_r       ;
   reg s_axi_bvalid_o_r       ;
   
   assign s_axi_arready_o = s_axi_arready_o_r;
   assign s_axi_rvalid_o  = s_axi_rvalid_o_r;
   assign s_axi_rdata_o   = s_axi_rdata_o_r;
   assign s_axi_awready_o = s_axi_awready_o_r;
   assign s_axi_wready_o  = s_axi_wready_o_r;
   assign s_axi_bvalid_o  = s_axi_bvalid_o_r;
   
   
   // ADDRESS
   parameter [31:0] UART_BASE_ADDR = 32'h2000_0000;
   parameter [31:0] UART_MASK_ADDR = 32'h0000_000f;
   
   // REGISTERS
   reg [31:0] uart_ctrl  ; 
   reg [3:0] uart_status ;
    //reg [7:0] uart_rdata  = 8'd0; ihtiyac duyulmadi
   reg [7:0] uart_wdata  ;
   
   // BUFFERS
   reg [7:0] rx_buffer [31:0];
   reg [7:0] tx_buffer [31:0];
   
   // STATES
   localparam state_uart_ctrl   = 4'b0000;
   localparam state_uart_status = 4'b0100;
   localparam state_uart_rdata  = 4'b1000;
   localparam state_uart_wdata  = 4'b1100;
   
   // WRITE/READ ENABLE FOR REGISTERS
   
   wire read_en; 
   assign read_en = !(s_axi_araddr_i[3] && s_axi_araddr_i[2]);
   
   wire write_en;
   assign write_en = (s_axi_awaddr_i[3] ^ ~s_axi_awaddr_i[2]);
   
   // AXI HANDHSHAKE
   wire r_adress_check;
   wire w_adress_check;
   assign r_adress_check = s_axi_arvalid_i & ((s_axi_araddr_i & ~UART_MASK_ADDR) == UART_BASE_ADDR) & read_en; 
   assign w_adress_check = s_axi_awvalid_i &   s_axi_wvalid_i &  ((s_axi_awaddr_i & ~UART_MASK_ADDR) == UART_BASE_ADDR) & write_en;

   // UART STATUS, ilk degerler 4'b1010
   reg us3 ;
   reg us2 ;
   reg us1 ;
   reg us0 ;
   
   assign tx_o = uart_wdata;
   assign tx_en_o = uart_ctrl[0] && !us1;  // tx_en ve tx_not_empty
   assign rx_en_o = uart_ctrl[1] && !us2; //  rx_en ve rx_not_full
   assign baud_div_o = uart_ctrl[31:16];
    
   // UART CTRL
   reg [31:0] uart_ctrl_next;
   
   // RX/TX ENABLE
   wire tx_en; // REG REG REG
   assign tx_en = uart_ctrl[0];
   
   wire rx_en;
   assign rx_en = uart_ctrl[1];
   
   // UART WRITE DATA
   reg [7:0] uart_wdata_next ;
   reg tx_first ;
   reg tx_first_next ;
   
   // UART RECEIVE DATA
   reg [7:0] uart_rdata_next ;
   
   // TX BUFFER DATA
   reg [7:0] tx_buf_data ;
   reg [4:0] tx_buffer_write_idx ;
   reg [4:0] tx_buffer_write_idx_next ;
   reg [4:0] tx_buffer_read_idx ;
   reg [4:0] tx_buffer_read_idx_next ;
   
   // RX BUFFER DATA, 6 bit gerekti
   reg [7:0] rx_buf_data ;
   reg [4:0] rx_buffer_write_idx ;
   reg [4:0] rx_buffer_write_idx_next ;
   reg [4:0] rx_buffer_read_idx ;
   reg [4:0] rx_buffer_read_idx_next ;
   
   reg s_axi_arready_o_next ;
   reg [31:0] s_axi_rdata_o_next ;
   reg s_axi_awready_o_next ;
   reg s_axi_wready_o_next  ;
   reg s_axi_bvalid_o_next  ;
   reg s_axi_rvalid_o_next  ;
   reg s_axi_bresp_o_r_next ;
   reg s_axi_rresp_o_r_next ;
   
   wire [3:0]   reg_addres_r;
   assign reg_addres_r = s_axi_araddr_i;
   
   wire [3:0]   reg_addres_w;
   assign reg_addres_w = s_axi_awaddr_i;
   
   wire tx_buffer_write_condition;
   assign  tx_buffer_write_condition = (reg_addres_w==state_uart_wdata) && s_axi_bready_i;
   
   wire write_word;
   assign write_word = &s_axi_wstrb_i;   
   wire write_half;
   assign write_half = (s_axi_wstrb_i[0] && s_axi_wstrb_i[1]);
   wire write_byte;
   assign write_byte = s_axi_wstrb_i[0];
   
   wire read_word;
   assign read_word = &read_size_i;   
   wire read_half;
   assign read_half = (read_size_i[0] && read_size_i[1]);
   wire read_byte;
   assign read_byte = read_size_i[0];
     
   integer j=0;
   integer k=0;
   
   always @* begin
   
      s_axi_arready_o_next = 1'b1;
      s_axi_rdata_o_next = s_axi_rdata_o_r;
      s_axi_awready_o_next = 1'b1;
      s_axi_wready_o_next = 1'b1;
      s_axi_bvalid_o_next = 1'b0;
      s_axi_rvalid_o_next = 1'b0;
      us3 = uart_status[3];
      us2 = uart_status[2];
      us1 = uart_status[1];
      us0 = uart_status[0];
      uart_ctrl_next = uart_ctrl;
      uart_wdata_next = uart_wdata;
      uart_rdata_next = rx_buffer[rx_buffer_read_idx];//
      tx_buf_data = s_axi_wdata_i[7:0]; //0
      rx_buf_data = rx_i; //0 *********
      tx_buffer_write_idx_next = tx_buffer_write_idx;
      tx_buffer_read_idx_next = tx_buffer_read_idx;
      rx_buffer_write_idx_next = rx_buffer_write_idx;
      rx_buffer_read_idx_next = rx_buffer_read_idx;
      tx_first_next = tx_first;
      s_axi_bresp_o_r_next = 1'b0;
      s_axi_rresp_o_r_next = 1'b0;
      
      if(r_adress_check && s_axi_rready_i) begin
      s_axi_rresp_o_r_next = 1'b1;
      
         case(reg_addres_r) 
            state_uart_ctrl   : begin
               s_axi_rvalid_o_next = 1'b1;
               s_axi_rdata_o_next[7:0] = uart_ctrl[7:0];
               if(read_word)begin
                  s_axi_rdata_o_next[31:8] = uart_ctrl[31:8];
               end
               else if(read_half) begin
                  s_axi_rdata_o_next[15:8] = uart_ctrl[15:8];
               end
            end
            
            state_uart_status : begin
               s_axi_rvalid_o_next = 1'b1;
               s_axi_rdata_o_next = {28'b0,uart_status};         
            end
            
            state_uart_rdata  : begin // only read
               if(!uart_status[3]) begin // rx_is_not_empty
                  us2 = 1'b0; // rx_is_not_full
                  s_axi_rvalid_o_next = 1'b1;
                  s_axi_rdata_o_next[7:0] = rx_buffer[rx_buffer_read_idx ];
                  if(read_byte)begin // bayt okunacak
                     rx_buffer_read_idx_next = rx_buffer_read_idx + 1'b1;
                     if(rx_buffer_read_idx_next == rx_buffer_write_idx) begin
                        us3 = 1'b1; // rx_buffer bosaltildi
                     end
                  end            
               end
               else begin
                  s_axi_rvalid_o_next = 1'b0;
               end
            end
            
            default : begin
               // simdilik bos
            end
         endcase
      end

      
      if(w_adress_check && s_axi_bready_i)begin
      
         case(reg_addres_w)
         
            state_uart_ctrl   : begin
               s_axi_bvalid_o_next = 1'b1;
               s_axi_bresp_o_r_next = 1'b1;
               if(s_axi_wstrb_i[0])
                  uart_ctrl_next[7:0]          =       s_axi_wdata_i[7:0];
               if(s_axi_wstrb_i[1])
                  uart_ctrl_next[15:8]       =       s_axi_wdata_i[15:8];
               if(s_axi_wstrb_i[2])
                  uart_ctrl_next[23:16]       =       s_axi_wdata_i[23:16];
               if(s_axi_wstrb_i[3])
                  uart_ctrl_next[31:24]       =       s_axi_wdata_i[31:24];
            end
            
            state_uart_wdata  : begin // only write           
               if(!uart_status[0] && !t_done_i) begin // tx_is_not_full
                  s_axi_bvalid_o_next = 1'b1;
                  us1 = 1'b0; // tx_is_not_empty
                  tx_buf_data = s_axi_wdata_i[7:0]; 
                  if(write_byte) begin
                     tx_buffer_read_idx_next = tx_buffer_read_idx + 1'b1;
                     if(tx_buffer_read_idx_next==tx_buffer_write_idx) begin
                        us0 = 1'b1; // tx_full
                     end
                  end
               end
               else begin // tx buffer doluydu
                  s_axi_bvalid_o_next = 1'b0;
                  s_axi_bresp_o_r_next=1'b0;
               end
            end
         endcase
      end
      
      
      if(tx_en && (!uart_status[1])) begin  // tx_en && tx_buffer_is_not_empty
         uart_wdata_next = tx_buffer[tx_buffer_write_idx];
         if(tx_first) begin
            us1 = 1'b0; // tx_empty (not)
            
            if(t_done_i)begin
               if(tx_buffer_write_idx == (tx_buffer_read_idx-1'b1)) begin 
                  tx_buffer_write_idx_next = 5'd0;
                  tx_buffer_read_idx_next = 5'd0; // okunanlar ile islem yapildi
                  us1 = 1'b1; // tx_empty
                  //uart_ctrl_next[0] = 1'b0; // tx_en (not)
               end
               else begin
                  tx_first_next = 1'b0;
                  tx_buffer_write_idx_next = tx_buffer_write_idx + 1'b1;
                  us0 = 1'b0; // tx_full_not
               end
            end
         end 
         else begin
            if(t_done_i) begin
               if(tx_buffer_write_idx == (tx_buffer_read_idx-1'b1)) begin 
                  tx_buffer_write_idx_next = 5'd0;
                  tx_buffer_read_idx_next = 5'd0; // okunanlar ile islem yapildi
                  us1 = 1'b1; // tx_empty
                  //uart_ctrl_next[0] = 1'b0; // tx_en (not)
               end
               else begin
                  tx_buffer_write_idx_next = tx_buffer_write_idx + 1'b1;
                  us1 = 1'b0; // tx_is_not_empty
                  us0 = 1'b0; // tx_full_not
               end
            end   
         end
      end
      else begin
         tx_first_next = 1'b1;
      end
      
      if(rx_en && (!uart_status[2])) begin // rx_en && !rx_full
         if(r_done_i) begin   
            us3 = 1'b0; // rx_is_not_empty
            if(rx_buffer_write_idx == (rx_buffer_read_idx-1'b1)) begin // ==31 eski hali *****
               us2 = 1'b1; // rx_full
               rx_buffer_write_idx_next = rx_buffer_write_idx;
            end 
            else begin
               us2 = 1'b0; // rx_is_not_full
               rx_buffer_write_idx_next = rx_buffer_write_idx + 1'b1;
            end  
            rx_buf_data       = rx_i;               
         end         
      end
        
   end
   
   always @(posedge s_axi_aclk_i) begin
     if(!s_axi_aresetn_i)begin // s_axi_aresetn_i == 0 ise resetlenecek
        s_axi_arready_o_r <= 1'b0;        
        s_axi_rdata_o_r   <= 32'd0;          
        s_axi_awready_o_r <= 32'd0;        
        s_axi_wready_o_r  <= 1'b0;         
        s_axi_bvalid_o_r  <= 1'b0;         
        s_axi_rvalid_o_r  <= 1'b0;                                                                                                                                
        uart_status[3]    <= 1'b1;                            
        uart_status[2]    <= 1'b0;                            
        uart_status[1]    <= 1'b1;                            
        uart_status[0]    <= 1'b0;                                                                                   
        uart_ctrl         <= 32'd0;                                                                          
        uart_wdata        <= 8'd0;                                    
                                                          
        for(j=0 ; j<32 ; j=j+1) begin                     
           tx_buffer[j] <= 8'd0; 
        end
                                                          
        tx_buffer_write_idx <= 5'd0;  
        tx_buffer_read_idx <= 5'd0;    
                                                          
        for(k=0 ; k<32 ; k=k+1) begin                        
         rx_buffer[k] <= 8'd0; 
        end
                                                          
        rx_buffer_write_idx <= 5'd0;  
        rx_buffer_read_idx  <= 5'd0;    
                                                          
        tx_first <= 1'b0;                                                                        
     end    
     
     else begin
        s_axi_arready_o_r <= s_axi_arready_o_next;
        s_axi_rdata_o_r   <= s_axi_rdata_o_next;
        s_axi_awready_o_r <= s_axi_awready_o_next;
        s_axi_wready_o_r  <= s_axi_wready_o_next;  
        s_axi_rvalid_o_r  <= s_axi_rvalid_o_next;     
        uart_status[3]    <= us3;
        uart_status[2]    <= us2;
        uart_status[1]    <= us1;
        uart_status[0]    <= us0;
        uart_wdata        <= uart_wdata_next;  
        uart_ctrl         <= uart_ctrl_next;
        
        if(tx_buffer_write_condition && !uart_status[0]/*tx_is_not_full*/) begin   
           tx_buffer[tx_buffer_read_idx]    <= tx_buf_data;   
        end
           
        s_axi_bvalid_o_r  <= s_axi_bvalid_o_next;         
        tx_buffer_write_idx <= tx_buffer_write_idx_next;
        tx_buffer_read_idx <= tx_buffer_read_idx_next;
        
        if(rx_en && r_done_i) begin
           rx_buffer[rx_buffer_write_idx] <= rx_buf_data;   
        end         
        rx_buffer_write_idx <= rx_buffer_write_idx_next;
        rx_buffer_read_idx <= rx_buffer_read_idx_next; 
        tx_first <= tx_first_next;
     end
   end
   

endmodule
