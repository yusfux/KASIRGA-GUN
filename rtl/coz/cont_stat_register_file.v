`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2023 14:21:03
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//WPRI bu bolumlere read/write ignore ediliyor, read-only zero yapabiliriz
//WLRL legal write legal read yapilmali, write legal degilse arbitrary bir bit pattern donmemiz gerekiyor read yapildiginda?
//WARL her seyi yazabiliyorsun ama sadece legal okuyabiliyorsun, legal value previous write'a deterministically depend etmeli
//sikicem bu field specificationlari read legallarda onceki yazmaya dependent olmayacak sekilde en sonki legal degeri dondurecegim

`include "instructions.vh"
`include "operations.vh"

`define MSTATUS_MPP  12:11
`define MSTATUS_MPIE 7
`define MSTATUS_MIE  3
`define PRIV_MACHINE 2'b11

module cont_stat_register_file (
        input clk_i, rst_i,

        //-------------signals from 'pipeline controller' to 'control status registers'------------

        //teknofestte hicbir zaman interrupt gelme olasiligi olmadigi icin simdilik bu fieldlari implement etmeyecegim
        //input       en_interrupt_i,
        //input [?:?] interrupt_cause,

        input        en_exception_i,
        input [2:0]  exception_cause_i,
        input [31:0] exception_adress_i,
        input [31:0] exception_program_counter_i,

        input        en_mret_instruction_i,
        //-----------------------------------------------------------------------------------------

        //--------------signals from 'decode stage' to 'control and status registers'--------------
        input  [2:0]  op_csr_i,
        input         en_csr_read_i,
        input         en_csr_write_i,
        input  [11:0] adress_csr_i,
        input  [31:0] data_csr_write_i,
        input  [31:0] data_csr_write_imm_i,
        output [31:0] data_csr_read_o,
        //-----------------------------------------------------------------------------------------

        //-----------------------signals from 'controller' to 'fetch stage'------------------------
        output en_excep_program_counter_o,
        output [31:0] excep_program_counter_o
        //-----------------------------------------------------------------------------------------
    );


    //------------------------Unpriviliged Counters/Timers------------------------
    //these CSR's are read-only shadows of mcycle, minstret, and mhpmcountern, respectively
    //the time register is read-only shadow of the memory-mapped mtime register
    /*
        reg [63:0] cycle_r;
        reg [63:0] cycle_ns;
        reg [63:0] cycleh_r;
        reg [63:0] cycleh_ns;

        reg [63:0] time_r;
        reg [63:0] time_ns;
        reg [63:0] timeh_r;
        reg [63:0] timeh_ns;

        reg [63:0] instret_r;
        reg [63:0] instret_ns;
        reg [63:0] instreth_r;
        reg [63:0] instreth_ns;
    */

    //------------------------Machine Information Registers------------------------
    //value of 0 can be returned to indicate the field is not implemented
    wire [31:0] mevendorid_w = 32'b00000000000000000000000000000000;    //vendor id
    wire [31:0] marchid_w    = 32'b00000000000000000000000000000000;    //architecture id 
    wire [31:0] mimpid_w     = 32'b00000000000000000000000000000000;    //implementation id
    wire [31:0] mhartid_w    = 32'b00000000000000000000000000000000;    //hart id
    wire [31:0] mconfigptr_w = 32'b00000000000000000000000000000000;    //configuration pointer

    //------------------------Machine Trap Setup------------------------

    //almost every field in mstatus is read only 0 when S/U mode is not supported
    //SD | WPRI | TSR | TW | TVM | MXR | SUM | MPRIV | XS | FS | MPP | VS | SPP | MPIE | UBE | SPIE | WPRI | MIE | WPRI | SIE | WPRI
    // when a trap is taken: MPIE = MIE, MIE = 0, MPP = M(Machine mode in our case)
    // when executing MRET: MIE = MPIE, MPIE = 1, MPP = M(Machine mode in our case)
    reg [31:0] mstatus_r;
    reg [31:0] mstatus_ns;


    //a value of zero can be returned to indicate the misa register has not been implemented
    //hicbir zaman isa'nin degistirilmesine izin vermeyecegimiz icin read-only,
    wire [31:0] misa_w = 32'b01_0000_00000000000001000100000100;

    //in systems without S-mode, the medeleg and mideleg registers should not exist
    //reg [31:0] medeleg;
    //reg [31:0] mideleg;

    //machine interrupt enable register, bit in mie must be writable if the corresponding interrupt can ever become pending.
    // 16'bcustom | 4'b0 | MEIE | 0 | SEIE | 0 | MTIE | 0 | STIE | 0 | MSIE | 0 | SSIE | 0
    // interrupt handle etmeyecegimiz gore bunlara da gerek yok sanirim
    //reg [31:0] mie_r;
    //reg [31:0] mie_ns;

    //interrupt handle etmeyecegimiz icin direct mode da olsa vectored mode da olsa pc = base olacak
    reg [31:0] mtvec_r;
    reg [31:0] mtvec_ns;

    //in systems without U-mode, the mcounteren register should not exist
    //reg [31:0] mcounteren;

    //it contains the same fields fond in bits 62:36 of mstatus for RV64
    // if MBE = 0, memory acceses are little-endian, big-endian otherwise
    // 26'bWPRI | MBE | SBE | 4'bWPRI
    //we can implement this as read-only zero since we fixed our endiannes to little endian
    wire [31:0] mstatush_w = 32'b00000000000000000000000000000000;

    //------------------------Machine Trap Handling------------------------
    reg [31:0] mscratch_r;
    reg [31:0] mscratch_ns;

    //mepc[1:0] is always zero for implementations that support only IALIGN = 32,
    //but since we have C extension, only mepc[0] should be zero
    //when a trap is taken into M-mode, mepc is written with the virtual address of the instruction
    //that was interrupted or that encountered the exception
    reg [31:0] mepc_r;
    reg [31:0] mepc_ns;

    //when a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap
    // The Interrupt bit in the mcause register is set if the trap was caused by an interrupt.
    // interrupt | exception code
    reg [31:0] mcause_r;
    reg [31:0] mcause_ns;

    //mtval is either set to zero or written with exception-specific information to assist software in handling the trap
    //if the hardware platform specifies that no exceptions set mtval to a nonzero value, then mtval is raed-only zero
    wire [31:0] mtval_w = 32'b00000000000000000000000000000000;

    // 16'bcustom | 4'b0 | MEIP | 0 | SEIP | 0 | MTIP | 0 | STIP | 0 | MSIP | 0 | SSIP | 0
    // MEIP is read-only and is set and cleared by a platform-specific interrupt controller?
    // MTIP is read-only and is cleared by writing to the memory-mapped machine-mode timer compare register
    // MSIP and MSIE are read-only zero since we have only one hart
    // also all fields with SXXX are all read-only zero since supervisor mode is not implemented
    // multiple simultaneous interrupts are handled in the following priority: MEI, MSI, MTI
    // interrupt handle etmeyecegimiz gore bunlara da gerek yok sanirim
    //reg [31:0] mip_r;
    //reg [31:0] mip_ns;

    //mtinst may always be zero, indicating that the hardware is providing no information in the register for this particular trap
    wire [31:0] mtinst_w = 32'b00000000000000000000000000000000;

    //------------------------Machine Configuration------------------------
    //if U-mode is not supported, then registers menvcfg and menvcfgh do not exist
    //reg [31:0] menvcfg;
    //reg [31:0] menvcfgh;

    //they are optional machine security registers so we will ignore these for the sake of simplicity
    //reg [31:0] mseccfg;
    //reg [31:0] mseccfgh;

    //------------------------Machine Memory Protection------------------------
    //TODO: should we implement these registers?

    //------------------------Machine Counter/Timers------------------------
    //TODO: should we implement performance-monitoring counters?
    reg [63:0] mcycle_r;
    reg [63:0] mcycle_ns;

    reg [63:0] minstret_r;
    reg [63:0] minstret_ns;

    reg [63:0] mcycleh_r;
    reg [63:0] mcycleh_ns;

    reg [63:0] minstreth_r;
    reg [63:0] minstreth_ns;

    //------------------------Machine Counter Setup------------------------
    //TODO: should we implement performance-monitoring counter setups?
    //if the mcountinhibit is not implemented, the implementation behaves as though the register were set to zero
    wire [31:0] mcountinhibit_w = 32'b00000000000000000000000000000000;


    reg [31:0] data_csr_read_r;
    reg [31:0] excep_program_counter_r;
    reg        en_excep_program_counter_r;

    //TODO: check the CSR field specifications
    //TODO: attempts to access a non-existent CSR raise an illegal instruction exception
    //TODO: writes to the read-only bits should be ignored
    //TODO: ignore writes on read-only registers if they are read-only zero
    //TODO: MPP is warl but it always has to be 2'b11 in our case
    //TODO: since we support only little-endian memory access, MBE has to be read-only zero
    //TODO: mstatusa implicit read yaptigimiz icin sadece okurken maskeliyor olmamiz ise yaramiyor olabilir
    //TODO: MEPC never written by the implementation, though it may be explicitly written by software??
    //TODO: MCAUSE never written by the implementation, though it may be explicitly written by software??
    //TODO: MTVAL never written by the implementation, though it may be explicitly written by software??
    //TODO: SRET should raise an illegal instruction exception, if supervisor mode is not supported
    always @(*) begin
        mstatus_ns   = mstatus_r;
        mtvec_ns     = mtvec_r;

        mscratch_ns  = mscratch_r;
        mepc_ns      = mepc_r;
        mcause_ns    = mcause_r;

        mcycle_ns    = mcycle_r + 1;
        minstret_ns  = minstret_r;
        mcycleh_ns   = mcycleh_r;
        minstreth_ns = minstreth_r;

        if(en_csr_read_i) begin
            case(adress_csr_i)
                `MVENDORID:  data_csr_read_r = mevendorid_w;
                `MARCHID:    data_csr_read_r = marchid_w;
                `MIMPID:     data_csr_read_r = mimpid_w;
                `MHARTID:    data_csr_read_r = mhartid_w;
                `MCONFIGPTR: data_csr_read_r = mconfigptr_w;

                `MSTATUS:    data_csr_read_r = mstatus_r  & 32'h0000_1888;
                `MISA:       data_csr_read_r = misa_w;
                `MTVEC:      data_csr_read_r = mtvec_r;
                `MSTATUSH:   data_csr_read_r = mstatush_w;

                `MSCRATCH:   data_csr_read_r = mscratch_r;
                `MEPC:       data_csr_read_r = mepc_r;
                `MCAUSE:     data_csr_read_r = mcause_r;
                `MTVAL:      data_csr_read_r = mtval_w;
                `MTINST:     data_csr_read_r = mtinst_w;

                `MCYCLE:     data_csr_read_r = mcycle_r;
                `MINSTRET:   data_csr_read_r = minstret_r;
                `MCYCLEH:    data_csr_read_r = mcycleh_r;
                `MINSTRETH:  data_csr_read_r = minstreth_r;

                `CYCLE:      data_csr_read_r = mcycle_r;
                `INSTRET:    data_csr_read_r = minstret_r;
                `CYCLEH:     data_csr_read_r = mcycleh_r;
                `INSTRETH:   data_csr_read_r = minstreth_r;
            endcase
        end

        //TODO: need to find more elegant way to write values into csrs
        if(en_csr_write_i) begin
            case(op_csr_i)
                `OP_CSR_CSRRS: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_i | mstatus_r;
                        `MTVEC:         mtvec_ns = data_csr_write_i | mtvec_r;

                        `MSCRATCH:   mscratch_ns = data_csr_write_i | mscratch_r;
                        `MEPC:           mepc_ns = data_csr_write_i | mepc_r;
                        `MCAUSE:       mcause_ns = data_csr_write_i | mcause_r;

                        `MCYCLE:       mcycle_ns = data_csr_write_i | mcycle_r;
                        `MINSTRET:   minstret_ns = data_csr_write_i | minstret_r;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_i | mcycleh_r;
                        `MINSTRETH: minstreth_ns = data_csr_write_i | minstreth_r;
                    endcase
                end
                `OP_CSR_CSRRC: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = ~data_csr_write_i & mstatus_r;
                        `MTVEC:         mtvec_ns = ~data_csr_write_i & mtvec_r;

                        `MSCRATCH:   mscratch_ns = ~data_csr_write_i & mscratch_r;
                        `MEPC:           mepc_ns = ~data_csr_write_i & mepc_r;
                        `MCAUSE:       mcause_ns = ~data_csr_write_i & mcause_r;

                        `MCYCLE:       mcycle_ns = ~data_csr_write_i & mcycle_r;
                        `MINSTRET:   minstret_ns = ~data_csr_write_i & minstret_r;
                        `MCYCLEH:     mcycleh_ns = ~data_csr_write_i & mcycleh_r;
                        `MINSTRETH: minstreth_ns = ~data_csr_write_i & minstreth_r;
                    endcase
                end
                `OP_CSR_CSRRW: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_i;
                        `MTVEC:         mtvec_ns = data_csr_write_i;

                        `MSCRATCH:   mscratch_ns = data_csr_write_i;
                        `MEPC:           mepc_ns = data_csr_write_i;
                        `MCAUSE:       mcause_ns = data_csr_write_i;

                        `MCYCLE:       mcycle_ns = data_csr_write_i;
                        `MINSTRET:   minstret_ns = data_csr_write_i;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_i;
                        `MINSTRETH: minstreth_ns = data_csr_write_i;
                    endcase
                end
                `OP_CSR_CSRRSI: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_imm_i | mstatus_r;
                        `MTVEC:         mtvec_ns = data_csr_write_imm_i | mtvec_r;

                        `MSCRATCH:   mscratch_ns = data_csr_write_imm_i | mscratch_r;
                        `MEPC:           mepc_ns = data_csr_write_imm_i | mepc_r;
                        `MCAUSE:       mcause_ns = data_csr_write_imm_i | mcause_r;

                        `MCYCLE:       mcycle_ns = data_csr_write_imm_i | mcycle_r;
                        `MINSTRET:   minstret_ns = data_csr_write_imm_i | minstret_r;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_imm_i | mcycleh_r;
                        `MINSTRETH: minstreth_ns = data_csr_write_imm_i | minstreth_r;
                    endcase
                end
                `OP_CSR_CSRRCI: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = ~data_csr_write_imm_i & mstatus_r;
                        `MTVEC:         mtvec_ns = ~data_csr_write_imm_i & mtvec_r;

                        `MSCRATCH:   mscratch_ns = ~data_csr_write_imm_i & mscratch_r;
                        `MEPC:           mepc_ns = ~data_csr_write_imm_i & mepc_r;
                        `MCAUSE:       mcause_ns = ~data_csr_write_imm_i & mcause_r;

                        `MCYCLE:       mcycle_ns = ~data_csr_write_imm_i & mcycle_r;
                        `MINSTRET:   minstret_ns = ~data_csr_write_imm_i & minstret_r;
                        `MCYCLEH:     mcycleh_ns = ~data_csr_write_imm_i & mcycleh_r;
                        `MINSTRETH: minstreth_ns = ~data_csr_write_imm_i & minstreth_r;
                    endcase
                end
                `OP_CSR_CSRRWI: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_imm_i;
                        `MTVEC:         mtvec_ns = data_csr_write_imm_i;

                        `MSCRATCH:   mscratch_ns = data_csr_write_imm_i;
                        `MEPC:           mepc_ns = data_csr_write_imm_i;
                        `MCAUSE:       mcause_ns = data_csr_write_imm_i;

                        `MCYCLE:       mcycle_ns = data_csr_write_imm_i;
                        `MINSTRET:   minstret_ns = data_csr_write_imm_i;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_imm_i;
                        `MINSTRETH: minstreth_ns = data_csr_write_imm_i;
                    endcase
                end
            endcase
        end

        //TODO:
        //  -interrupt gelmis olabilir | interrupt gelmis olamaz cunku interrupt gelecek bir durumumuz yok :(
        //  -exception gelmis olabilir
        //  -exception'dan return ediliyor olabilir
        if(en_exception_i) begin
            mstatus_ns[`MSTATUS_MPIE] = mstatus_r[`MSTATUS_MIE];
            mstatus_ns[`MSTATUS_MIE]  = 1'b0;
            mstatus_ns[`MSTATUS_MPP]  = `PRIV_MACHINE;

            mepc_ns = exception_program_counter_i;

            en_excep_program_counter_r = 1'b1;
            excep_program_counter_r    = {mtvec_r[31:2], 2'b00};

            //TODO: why there is priority order in page 40 priv-spec, for multiple hart systems?
            case(exception_cause_i)
                `EXCEP_INSTR_MISALIGNED:        begin
                    mcause_ns = {1'b0, 27'b0, 4'b0000};
                end
                `EXCEP_ILLEGAL_INSTRUCTION:     begin
                    mcause_ns = {1'b0, 27'b0, 4'b0010};
                end
                `EXCEP_BREAKPOINT:              begin
                    mcause_ns = {1'b0, 27'b0, 4'b0011};
                end
                `EXCEP_LOAD_ADRESS_MISALIGNED:  begin
                    mcause_ns = {1'b0, 27'b0, 4'b0100};
                end
                `EXCEP_STORE_ADRESS_MISALIGNED: begin
                    mcause_ns = {1'b0, 27'b0, 4'b0110};
                end
                `EXCEP_ENV_CALL:                begin
                    mcause_ns = {1'b0, 27'b0, 4'b1011};
                    mepc_ns   = exception_program_counter_i;
                end
            endcase
        end
        else if(en_mret_instruction_i) begin
            mstatus_ns[`MSTATUS_MIE]  = mstatus_r[`MSTATUS_MPIE];
            mstatus_ns[`MSTATUS_MPIE] = 1'b1;
            mstatus_ns[`MSTATUS_MPP]  = `PRIV_MACHINE;

            en_excep_program_counter_r = 1'b1;
            excep_program_counter_r    = {mepc_r[31:1], 1'b0};  //IALIGN = 16
        end

    end

    always @(posedge clk_i, negedge rst_i) begin
        //TODO: resette yapmamiz gereken hicbir sey yok sanirim performance monitoring registerlari haric
        if(!rst_i) begin

        end
        else begin
            mstatus_r  <= mstatus_ns;
            mtvec_r    <= mtvec_ns;
            mscratch_r <= mscratch_ns;
            mepc_r     <= mepc_ns;
            mcause_r   <= mcause_ns;
            mcycle_r   <= mcycle_ns;
            minstret_r <= minstret_ns;

            //TODO: iskembeden salladim boyle bir sey mi kontrol etmek lazim
            if(mcycle_ns == 32'hFFFF_FFFF)
                mcycleh_r <= mcycleh_ns + 1'b1;

            if(minstret_ns == 32'hFFFF_FFFF)
                minstreth_r <= minstreth_ns + 1'b1;
        end
    end

    assign data_csr_read_o            = data_csr_read_r;
    assign en_excep_program_counter_o = en_excep_program_counter_r;
    assign excep_program_counter_o    = excep_program_counter_r;

endmodule