`include "operations.vh"

//TODO: bellek ve yurutten ayni anda durdur sinyali geldigi durumda aslinda birbirlerini durdurmamalari iyi olabilir,
//cunku carpma veya bolme gibi cok cevrimde yapilacak islemlerde bellegin hala calisir olmasi daha avantajli bir durum
module pipeline_controller (
        input en_stall_decode_stage_i,
        input en_stall_execute_stage_i,
        input en_stall_memory_stage_i,

        input en_flush_branch_misprediction_i,

        output stall_fetch_stage_o,
        output stall_decode_stage_o,
        output stall_execute_stage_o,

        output flush_decode_stage_o
    );

    reg stall_fetch_stage_r;
    reg stall_decode_stage_r;
    reg stall_execute_stage_r;

    reg flush_decode_stage_r;

    always @(*) begin
        stall_fetch_stage_r         = 1'b0;
        stall_decode_stage_r        = 1'b0;
        stall_execute_stage_r       = 1'b0;

        flush_decode_stage_r        = 1'b0;

        if(en_flush_branch_misprediction_i) begin
            flush_decode_stage_r  = 1'b1;
        end 

        if     (en_stall_memory_stage_i)  begin
            stall_execute_stage_r = 1'b1;
            stall_decode_stage_r  = 1'b1;
            stall_fetch_stage_r   = 1'b1;
        end
        else if(en_stall_execute_stage_i) begin
            stall_decode_stage_r  = 1'b1;
            stall_fetch_stage_r   = 1'b1;

        end
        else if(en_stall_decode_stage_i)  begin
            stall_fetch_stage_r   = 1'b1;
        end
    end
    
    assign stall_fetch_stage_o         = stall_fetch_stage_r;
    assign stall_decode_stage_o        = stall_decode_stage_r;
    assign stall_execute_stage_o       = stall_execute_stage_r;

    assign flush_decode_stage_o        = flush_decode_stage_r;
endmodule