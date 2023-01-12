

//Instruction-address-misaligned exceptions are not possible on machines that support extensions
//with 16-bit aligned instructions, such as the compressed instruction-set extension, C.
`include "operations.vh"

module pipeline_controller (
        input clk_i, rst_i,

        input en_stall_fetch_stage_i,
        input en_stall_decode_stage_i,
        input en_stall_execute_stage_i,
        input en_stall_memory_stage_i,

        input en_flush_branch_misprediction_i,
        input en_flush_mret_instruction_i,

        input [31:0] program_counter_fetch_stage_i,
        input [31:0] program_counter_decode_stage_i,
        input [31:0] program_counter_memory_stage_i,

        input [31:0] adress_memory_stage_i,

        input exception_instr_adress_misaligned_i,
        input exception_illegal_instruction_i,
        input exception_breakpoint_i,
        input exception_load_adress_misaligned_i,
        input exception_store_adress_misaligned_i,
        input exception_env_call_from_M_mode_i,

        input interrupt_machine_software_i,
        input interrupt_machine_timer_i,
        input interrupt_machine_external_i,

        output en_exception_o,
        output [31:0] exception_program_counter_o,
        output [31:0] exception_adress_o,
        output [2:0]  exception_cause_o,
        //output [?:?]  interrupt_cause_o,

        output stall_fetch_stage_o,
        output stall_decode_stage_o,
        output stall_execute_stage_o,
        output stall_memory_stage_o,

        output flush_decode_stage_o,
        output flush_execute_stage_o

    );

    
    reg [31:0] exception_program_counter_r;
    reg [31:0] exception_adress_r;
    reg        en_exception_r;
    reg [2:0]  exception_cause_r;
    reg [2:0]  interrupt_cause_r;

    reg stall_fetch_stage_r;
    reg stall_decode_stage_r;
    reg stall_execute_stage_r;
    reg stall_memory_stage_r;
    reg stall_writeback_stage_r;

    reg flush_fetch_stage_r;
    reg flush_decode_stage_r;
    reg flush_execute_stage_r;
    reg flush_memory_stage_r;
    reg flush_writeback_stage_r;

    always @(*) begin
        en_exception_r = 1'b0;

        if     (exception_load_adress_misaligned_i)  begin
            exception_cause_r           = `EXCEP_LOAD_ADRESS_MISALIGNED;
            exception_adress_r          = adress_memory_stage_i;
            exception_program_counter_r = program_counter_memory_stage_i;
            en_exception_r = 1'b1;
        end
        else if(exception_store_adress_misaligned_i) begin
            exception_cause_r           = `EXCEP_STORE_ADRESS_MISALIGNED;
            exception_adress_r          = adress_memory_stage_i;
            exception_program_counter_r = program_counter_memory_stage_i;
            en_exception_r = 1'b1;
        end
        else if(exception_breakpoint_i) begin
            exception_cause_r           = `EXCEP_BREAKPOINT;
            exception_program_counter_r = program_counter_decode_stage_i;
            en_exception_r = 1'b1;
        end
        else if(exception_env_call_from_M_mode_i)    begin
            exception_cause_r           = `EXCEP_ENV_CALL;
            exception_program_counter_r = program_counter_decode_stage_i;
            en_exception_r = 1'b1;
        end
        else if(exception_illegal_instruction_i)     begin
            exception_cause_r           = `EXCEP_ILLEGAL_INSTRUCTION;
            exception_program_counter_r = program_counter_decode_stage_i;
            en_exception_r = 1'b1;
        end
        else if(exception_instr_adress_misaligned_i) begin
            exception_cause_r           = `EXCEP_INSTR_MISALIGNED;
            exception_program_counter_r = program_counter_fetch_stage_i;
            en_exception_r = 1'b1;
        end

        //flush geldigi durumda bir sonraki boru hatti asamasina nop buyrugu verilir,
        //eger branch predictionun yanlis yapildigi anlasildigi cevrimde dogru buyruk getirilebiliyorsa
        //getir asamasini flushlamaya gerek yok 
        if(en_flush_branch_misprediction_i) begin
            flush_decode_stage_r  = 1'b1;
            flush_execute_stage_r = 1'b1;
        end else if(en_flush_mret_instruction_i) begin  //TODO: eger mret geldigi cevrimde program sayaci dogru instruct getirebiliyorsa 
                                                        //flusha gerek yok
        end

        //stall gelen botu hatti asamasi, saat vurusunda stall gelmisse eger bir sonraki asamaya
        //nop buyrugu vererek, mimari durumunu korur(girdilerden gelen verileri yok sayarak registerdaki verileri tutar)
        //geriyaz asamasi hicbir zaman stallanmiyor
        if     (en_stall_memory_stage_i)  begin
            stall_memory_stage_r  = 1'b1;
            stall_execute_stage_r = 1'b1;
            stall_decode_stage_r  = 1'b1;
            stall_fetch_stage_r   = 1'b1;
        end
        else if(en_stall_execute_stage_i) begin
            stall_execute_srage_r = 1'b1;
            stall_decode_stage_r  = 1'b1;
            stall_fetch_stage_r   = 1'b1;

        end
        else if(en_stall_decode_stage_i)  begin
            stall_decode_stage_r  = 1'b1;
            stall_fetch_stage_r   = 1'b1;
        end
        else if(en_stall_fetch_stage_i)   begin
            stall_fetch_stage_r   = 1'b1;
        end

    end
    
    assign exception_program_counter_o = exception_program_counter_r;
    assign exception_adress_o          = exception_adress_r;
    assign en_exception_o              = en_exception_r;
    assign exception_cause_o           = exception_cause_r;
    assign interrupt_cause_o           = interrupt_cause_r;

    assign  stall_fetch_stage_o     = stall_fetch_stage_r;
    assign  stall_decode_stage_o    = stall_decode_stage_r;
    assign  stall_execute_stage_o   = stall_execute_stage_r;
    assign  stall_memory_stage_o    = stall_memory_stage_r;
    assign  stall_writeback_stage_o = stall_writeback_stage_r;

    assign  flush_fetch_stage_o     = flush_fetch_stage_r;
    assign  flush_decode_stage_o    = flush_decode_stage_r;
    assign  flush_execute_stage_o   = flush_execute_stage_r;
    assign  flush_memory_stage_o    = flush_memory_stage_r;
    assign  flush_writeback_stage_o = flush_writeback_stage_r;

endmodule