module pipeline_controller (
        input clk_i, rst_i,

        input en_stall_fetch_stage_i,
        input en_stall_decode_stage_i,
        input en_stall_execution_stage_i,
        input en_stall_memory_stage_i,

        input flush_branch_misprediction_i,

        input exception_instr_adress_misaligned_i,
        input exception_illegal_instruction_i,
        input exception_load_adress_misaligned_i,
        input exception_store_adress_misaligned_i,
        input exception_env_call_from_M_mode_i,

        input interrupt_machine_software_i,
        input interrupt_machine_timer_i,
        input interrupt_machine_external_i,

        output [?:?] exception_cause_o,
        output [?:?] interrupt_cause_o,

        output stall_fetch_stage_o,
        output stall_decode_stage_o,
        output stall_execution_stage_o,
        output stall_memory_stage_o,
        output stall_writeback_stage_o,

    );

    
