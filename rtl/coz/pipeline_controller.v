`define EXCEP_INSTR_MISALIGNED        2'b000
`define EXCEP_ILLEGAL_INSTRUCTION     2'b001
`define EXCEP_BREAKPOINT              2'b010
`define EXCEP_LOAD_ADRESS_MISALIGNED  2'b011
`define EXCEP_STORE_ADRESS_MISALIGNED 2'b100
`define EXCEP_ENV_CALL                2'b101

module pipeline_controller (
        input clk_i, rst_i,

        input en_stall_fetch_stage_i,
        input en_stall_decode_stage_i,
        input en_stall_execute_stage_i,
        input en_stall_memory_stage_i,

        input en_flush_branch_misprediction_i,

        input [31:0] program_counter_fetch_stage_i,
        input [31:0] program_counter_decode_stage_i,
        input [31:0] program_counter_memory_stage_i,

        input [31:0] adress_memory_stage_i,

        input exception_instr_adress_misaligned_i,
        input exception_illegal_instruction_i,
        input exception_load_adress_misaligned_i,
        input exception_store_adress_misaligned_i,
        input exception_env_call_from_M_mode_i,

        input interrupt_machine_software_i,
        input interrupt_machine_timer_i,
        input interrupt_machine_external_i,

        output en_exception_o,
        output [31:0] exception_program_counter_o,
        output [2:0]  exception_cause_o,
        output [?:?]  interrupt_cause_o,

        output stall_fetch_stage_o,
        output stall_decode_stage_o,
        output stall_execute_stage_o,
        output stall_memory_stage_o,
        output stall_writeback_stage_o,

        output flush_fetch_stage_o,
        output flush_decode_stage_o,
        output flush_execute_stage_o,
        output flush_memory_stage_o,
        output flush_writeback_stage_o,

    );

    
    reg [31:0] exception_program_counter_r;
    reg       en_exception_r;
    reg [2:0] exception_cause_r;
    reg [2:0] interrupt_cause_r;

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
         
        if(en_exception_i) begin
            en_exception_r = 1'b1;

            if     (exception_load_adress_misaligned_i)  begin
                exception_cause_r           = `EXCEP_LOAD_ADRESS_MISALIGNED;
                exception_program_counter_r = program_counter_memory_stage_i;
            end
            else if(exception_store_adress_misaligned_i) begin
                exception_cause_r           = `EXCEP_STORE_ADRESS_MISALIGNED;
                exception_program_counter_r = program_counter_memory_stage_i;
            end
            else if(exception_env_call_from_M_mode_i)    begin
                exception_cause_r           = `EXCEP_ENV_CALL;
                exception_program_counter_r = program_counter_decode_stage_i;
            end
            else if(exception_illegal_instruction_i)     begin
                exception_cause_r           = `EXCEP_ILLEGAL_INSTRUCTION;
                exception_program_counter_r = program_counter_decode_stage_i;

            end
            else if(exception_instr_adress_misaligned_i) begin
                exception_cause_r           = `EXCEP_INSTR_MISALIGNED;
                exception_program_counter_r = program_counter_fetch_stage_i;
            end

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
        else if(en_stall_fetch_stage_i)   begin
            stall_execute_stage_r = 1'b1;
            stall_decode_stage_r  = 1'b1;
            stall_fetch_stage_r   = 1'b1;

        end

    end
    
    
