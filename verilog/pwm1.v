`timescale 1ns / 1ps

module pwm1(
   input           clk_i,
   input           rst_i,
   input [1:0]     pwm1_mode_i, 
   input [31:0]    pwm1_period_i,
   input [31:0]    pwm1_threshold1_i,
   input [31:0]    pwm1_threshold2_i,
   input [11:0]    pwm1_step_i,
   output          pwm1_o
);
    
   wire [1:0]     pwm1_mode_w         ;
   wire [31:0]    pwm1_period_w       ;
   wire [31:0]    pwm1_threshold1_w   ;
   wire [31:0]    pwm1_threshold2_w   ;
   wire [11:0]    pwm1_step_w         ;
    
   assign pwm1_mode_w = pwm1_mode_i;
   assign pwm1_period_w = pwm1_period_i;
   assign pwm1_threshold1_w = pwm1_threshold1_i;
   assign pwm1_threshold2_w = pwm1_threshold2_i;
   assign pwm1_step_w = pwm1_step_i;
    
    
   reg [31:0] counter                 ;
   reg [31:0] counter_next            ;
   reg [31:0] mode2_threshold         ;
   reg [31:0] mode2_threshold_next    ;
   
   reg pwm1_o_r                       ;
   reg pwm1_o_r_next                  ;
   assign pwm1_o = pwm1_o_r           ;
   reg mode2_threshold_control        ;
   reg mode2_threshold_control_next   ;
  
   wire kontrol;
   assign kontrol = (counter==(pwm1_period_w-1'b1));
   
   reg geri_gel_r;
   reg geri_gel_r_next;
    
   always @* begin
      counter_next = counter;
      pwm1_o_r_next = 1'b0;
      mode2_threshold_next = mode2_threshold;
      mode2_threshold_control_next = mode2_threshold_control;
      geri_gel_r_next = geri_gel_r;
      
      if(pwm1_mode_w==2'd0) begin // cikis 0 verilir
         mode2_threshold_control_next = 1'b1;
         pwm1_o_r_next = 1'b0;
      end
      
      else if(pwm1_mode_w==2'd1) begin // standart mod
         mode2_threshold_control_next = 1'b1;
         if(kontrol) begin
            counter_next = 32'd0;
         end
         else begin
            counter_next = counter + 1'b1;
            if(counter<pwm1_threshold1_w) begin
               pwm1_o_r_next = 1'b1;
            end
            else begin
               pwm1_o_r_next = 1'b0;
            end
         end
      end
      
      else if(pwm1_mode_w==2'd2) begin // kalp atisi modu
         if(mode2_threshold_control) begin
            mode2_threshold_next = pwm1_threshold1_w;
            mode2_threshold_control_next = 1'b0;
         end
         else begin
            if(!geri_gel_r && mode2_threshold>pwm1_threshold2_w) begin
               // bitti, bastan basla
               counter_next = 32'd0;
               mode2_threshold_next = pwm1_threshold2_w;
               geri_gel_r_next = 1'b1;
            end 
            if(geri_gel_r && mode2_threshold<pwm1_threshold1_w) begin
               // bitti, bastan basla
               counter_next = 32'd0;
               mode2_threshold_next = pwm1_threshold1_w;
               geri_gel_r_next = 1'b0;
            end
            else begin
               if(kontrol) begin
                  counter_next = 32'd0;
                  if(!geri_gel_r) begin
                     mode2_threshold_next = mode2_threshold + pwm1_step_w; 
                  end
                  else begin
                     mode2_threshold_next = mode2_threshold - pwm1_step_w;
                  end
               end
               else begin
                  mode2_threshold_next = mode2_threshold;
                  counter_next = counter + 1'b1;
                  if(counter<mode2_threshold) begin
                     pwm1_o_r_next = 1'b1;
                  end
                  else begin
                     pwm1_o_r_next = 1'b0;
                  end
               end
            end
         end
      end
   end
   
   always @(posedge clk_i) begin
      if(!rst_i) begin // rst_i == 0 ise resetlenecek
         pwm1_o_r <= 1'b0;
         counter <= 32'd0;
         mode2_threshold <= 32'd0;
         mode2_threshold_control <= 1'b0;
         geri_gel_r <= 1'b0;
      end
      else begin
         pwm1_o_r <= pwm1_o_r_next;
         counter <= counter_next;
         mode2_threshold <= mode2_threshold_next;
         mode2_threshold_control <= mode2_threshold_control_next;
         geri_gel_r <= geri_gel_r_next;
      end  
   end
      
endmodule
