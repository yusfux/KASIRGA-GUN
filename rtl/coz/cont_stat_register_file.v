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

module cont_stat_register_file (
        input clk_i, rst_i,

        //-------------signals from 'pipeline controller' to 'control status registers'------------
        input       en_interrupt_i,
        input [?:?] interrupt_cause,

        input        en_exception_i,
        input [5:0]  exception_cause,
        input [31:0] exception_adress_i,
        input [31:0] exception_program_counter_i,
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
        output [31:0] excep_program_counter_o,
        //-----------------------------------------------------------------------------------------
    );


    //----------------------------------------------------------------------------------------------------------------------------
    //BELOW LINES ARE ONLY VALID FOR IMPLEMENTATIONS WITH M EXTENSION ONLY, THEY ARE NOT GENERAL SITUATIONS FOR EVERY ARCHITECTURE
    //----------------------------------------------------------------------------------------------------------------------------


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
    reg [31:0] mie_r;
    reg [31:0] mie_ns;

    reg [31:0] mtvec_r;
    reg [31:0] mtvec_ns;

    //in systems without U-mode, the mcounteren register should not exist
    //reg [31:0] mcounteren;

    //it contains the same fields fond in bits 62:36 of mstatus for RV64
    // if MBE = 0, memory acceses are little-endian, big-endian otherwise
    // 26'bWPRI | MBE | SBE | 4'bWPRI
    //we can implement this as read-only zero since we fixed our endiannes to little endian
    reg [31:0] mstatush_r;
    reg [31:0] mstatush_ns;

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
    //we can implement mtval as read-only zero ifwe specifie that no exception set mtval a nonzero value
    reg [31:0] mtval_r;
    reg [31:0] mtval_ns;

    // 16'bcustom | 4'b0 | MEIP | 0 | SEIP | 0 | MTIP | 0 | STIP | 0 | MSIP | 0 | SSIP | 0
    // MEIP is read-only and is set and cleared by a platform-specific interrupt controller?
    // MTIP is read-only and is cleared by writing to the memory-mapped machine-mode timer compare register
    // MSIP and MSIE are read-only zero since we have only one hart
    // also all fields with SXXX are all read-only zero since supervisor mode is not implemented
    // multiple simultaneous interrupts are handled in the following priority: MEI, MSI, MTI
    reg [31:0] mip_r;
    reg [31:0] mip_ns;

    reg [31:0] mtinst_r;
    reg [31:0] mtinst_ns;

    //When a trap is taken into M-mode, mtval2 is written with additional exception-specific information, alongside mtval,
    reg [31:0] mtval2_r;
    reg [31:0] mtval2_ns;

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

    //TODO: check the CSR field specifications
    //TODO: attempts to access a non-existent CSR raise an illegal instruction exception
    //TODO: writes to the read-only bits should be ignored
    //TODO: ignore writes on read-only registers if they are read-only zero
    //TODO: MPP is warl but it always has to be 2'b11 in our case
    //TODO: since we support only little-endian memory access, MBE has to be read-only zero
    always @(*) begin
        mstatus_ns   = mstatus_r;
        mie_ns       = mie_r;
        mtvec_ns     = mtvec_r;
        mstatush_ns  = mstatush_r;

        mscratch_ns  = mscratch_r;
        mepc_ns      = mepc_r;
        mcause_ns    = mcause_r;
        mtval_ns     = mtval_r;
        mip_ns       = mip_r;
        mtinst_ns    = mtinst_r;
        mtval2_ns    = mtval2_r;

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
                `MISA:       data_csr_read_r = misa_r;
                `MIE:        data_csr_read_r = mie_r      & 32'h0000_0888;
                `MTVEC:      data_csr_read_r = mtvec_r;
                `MSTATUSH:   data_csr_read_r = mstatush_r & 32'h0000_0020;

                `MSCRATCH:   data_csr_read_r = mscratch_r;
                `MEPC:       data_csr_read_r = mepc_r;
                `MCAUSE:     data_csr_read_r = mcause_r;
                `MTVAL:      data_csr_read_r = mtval_r;
                `MIP:        data_csr_read_r = mip_r      & 32'h0000_0888;
                `MTINST:     data_csr_read_r = mtinst_r;
                `MTVAL2:     data_csr_read_r = mtval2_r;

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
                `CSR_CSRRS: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_i | mstatus_r;
                        `MISA:           misa_ns = data_csr_write_i | misa_r;
                        `MIE:             mie_ns = data_csr_write_i | mie_r;
                        `MTVEC:         mtvec_ns = data_csr_write_i | mtvec_r;
                        `MSTATUSH:   mstatush_ns = data_csr_write_i | mstatush_r;

                        `MSCRATCH:   mscratch_ns = data_csr_write_i | mscratch_r;
                        `MEPC:           mepc_ns = data_csr_write_i | mepc_r;
                        `MCAUSE:       mcause_ns = data_csr_write_i | mcause_r;
                        `MTVAL:         mtval_ns = data_csr_write_i | mtval_r;
                        `MIP:             mip_ns = data_csr_write_i | mip_r;
                        `MTINST:       mtinst_ns = data_csr_write_i | mtinst_r;
                        `MTVAL2:       mtval2_ns = data_csr_write_i | mtval2_r;

                        `MCYCLE:       mcycle_ns = data_csr_write_i | mcycle_r;
                        `MINSTRET:   minstret_ns = data_csr_write_i | minstret_r;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_i | mcycleh_r;
                        `MINSTRETH: minstreth_ns = data_csr_write_i | minstreth_r;
                    endcase
                end
                `CSR_CSRRC: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = ~data_csr_write_i & mstatus_r;
                        `MISA:           misa_ns = ~data_csr_write_i & misa_r;
                        `MIE:             mie_ns = ~data_csr_write_i & mie_r;
                        `MTVEC:         mtvec_ns = ~data_csr_write_i & mtvec_r;
                        `MSTATUSH:   mstatush_ns = ~data_csr_write_i & mstatush_r;

                        `MSCRATCH:   mscratch_ns = ~data_csr_write_i & mscratch_r;
                        `MEPC:           mepc_ns = ~data_csr_write_i & mepc_r;
                        `MCAUSE:       mcause_ns = ~data_csr_write_i & mcause_r;
                        `MTVAL:         mtval_ns = ~data_csr_write_i & mtval_r;
                        `MIP:             mip_ns = ~data_csr_write_i & mip_r;
                        `MTINST:       mtinst_ns = ~data_csr_write_i & mtinst_r;
                        `MTVAL2:       mtval2_ns = ~data_csr_write_i & mtval2_r;

                        `MCYCLE:       mcycle_ns = ~data_csr_write_i & mcycle_r;
                        `MINSTRET:   minstret_ns = ~data_csr_write_i & minstret_r;
                        `MCYCLEH:     mcycleh_ns = ~data_csr_write_i & mcycleh_r;
                        `MINSTRETH: minstreth_ns = ~data_csr_write_i & minstreth_r;
                    endcase
                end
                `CSR_CSRRW: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_i;
                        `MISA:           misa_ns = data_csr_write_i;
                        `MIE:             mie_ns = data_csr_write_i;
                        `MTVEC:         mtvec_ns = data_csr_write_i;
                        `MSTATUSH:   mstatush_ns = data_csr_write_i;

                        `MSCRATCH:   mscratch_ns = data_csr_write_i;
                        `MEPC:           mepc_ns = data_csr_write_i;
                        `MCAUSE:       mcause_ns = data_csr_write_i;
                        `MTVAL:         mtval_ns = data_csr_write_i;
                        `MIP:             mip_ns = data_csr_write_i;
                        `MTINST:       mtinst_ns = data_csr_write_i;
                        `MTVAL2:       mtval2_ns = data_csr_write_i;

                        `MCYCLE:       mcycle_ns = data_csr_write_i;
                        `MINSTRET:   minstret_ns = data_csr_write_i;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_i;
                        `MINSTRETH: minstreth_ns = data_csr_write_i;
                    endcase
                end
                `CSR_CSRRSI: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_imm_i | mstatus_r;
                        `MISA:           misa_ns = data_csr_write_imm_i | misa_r;
                        `MIE:             mie_ns = data_csr_write_imm_i | mie_r;
                        `MTVEC:         mtvec_ns = data_csr_write_imm_i | mtvec_r;
                        `MSTATUSH:   mstatush_ns = data_csr_write_imm_i | mstatush_r;

                        `MSCRATCH:   mscratch_ns = data_csr_write_imm_i | mscratch_r;
                        `MEPC:           mepc_ns = data_csr_write_imm_i | mepc_r;
                        `MCAUSE:       mcause_ns = data_csr_write_imm_i | mcause_r;
                        `MTVAL:         mtval_ns = data_csr_write_imm_i | mtval_r;
                        `MIP:             mip_ns = data_csr_write_imm_i | mip_r;
                        `MTINST:       mtinst_ns = data_csr_write_imm_i | mtinst_r;
                        `MTVAL2:       mtval2_ns = data_csr_write_imm_i | mtval2_r;

                        `MCYCLE:       mcycle_ns = data_csr_write_imm_i | mcycle_r;
                        `MINSTRET:   minstret_ns = data_csr_write_imm_i | minstret_r;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_imm_i | mcycleh_r;
                        `MINSTRETH: minstreth_ns = data_csr_write_imm_i | minstreth_r;
                    endcase
                end
                `CSR_CSRRCI: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = ~data_csr_write_imm_i & mstatus_r;
                        `MISA:           misa_ns = ~data_csr_write_imm_i & misa_r;
                        `MIE:             mie_ns = ~data_csr_write_imm_i & mie_r;
                        `MTVEC:         mtvec_ns = ~data_csr_write_imm_i & mtvec_r;
                        `MSTATUSH:   mstatush_ns = ~data_csr_write_imm_i & mstatush_r;

                        `MSCRATCH:   mscratch_ns = ~data_csr_write_imm_i & mscratch_r;
                        `MEPC:           mepc_ns = ~data_csr_write_imm_i & mepc_r;
                        `MCAUSE:       mcause_ns = ~data_csr_write_imm_i & mcause_r;
                        `MTVAL:         mtval_ns = ~data_csr_write_imm_i & mtval_r;
                        `MIP:             mip_ns = ~data_csr_write_imm_i & mip_r;
                        `MTINST:       mtinst_ns = ~data_csr_write_imm_i & mtinst_r;
                        `MTVAL2:       mtval2_ns = ~data_csr_write_imm_i & mtval2_r;

                        `MCYCLE:       mcycle_ns = ~data_csr_write_imm_i & mcycle_r;
                        `MINSTRET:   minstret_ns = ~data_csr_write_imm_i & minstret_r;
                        `MCYCLEH:     mcycleh_ns = ~data_csr_write_imm_i & mcycleh_r;
                        `MINSTRETH: minstreth_ns = ~data_csr_write_imm_i & minstreth_r;
                    endcase
                end
                `CSR_CSRRWI: begin
                    case(adress_csr_i)
                        `MSTATUS:     mstatus_ns = data_csr_write_imm_i;
                        `MISA:           misa_ns = data_csr_write_imm_i;
                        `MIE:             mie_ns = data_csr_write_imm_i;
                        `MTVEC:         mtvec_ns = data_csr_write_imm_i;
                        `MSTATUSH:   mstatush_ns = data_csr_write_imm_i;

                        `MSCRATCH:   mscratch_ns = data_csr_write_imm_i;
                        `MEPC:           mepc_ns = data_csr_write_imm_i;
                        `MCAUSE:       mcause_ns = data_csr_write_imm_i;
                        `MTVAL:         mtval_ns = data_csr_write_imm_i;
                        `MIP:             mip_ns = data_csr_write_imm_i;
                        `MTINST:       mtinst_ns = data_csr_write_imm_i;
                        `MTVAL2:       mtval2_ns = data_csr_write_imm_i;

                        `MCYCLE:       mcycle_ns = data_csr_write_imm_i;
                        `MINSTRET:   minstret_ns = data_csr_write_imm_i;
                        `MCYCLEH:     mcycleh_ns = data_csr_write_imm_i;
                        `MINSTRETH: minstreth_ns = data_csr_write_imm_i;
                    endcase
                end
            endcase
        end

        //TODO:
        //  -interrupt gelmis olabilir
        //  -exception gelmis olabilir
        //  -exception'dan return ediliyor olabilir

        if(en_interrupt_i) begin

            if(interrupt_cause == `INT_EXTERN) begin

            end
            else if(interrupt_cause == `INT_SOFT) begin

            end
            else if(interrupt_cause == `INT_TIMER) begin

            end
        end
        else if(en_exception_i) begin
            case(exception_cause)

            endcase
        end

    end

    always @(posedge clk_i) begin

    end

    assign data_csr_read_o = data_csr_read_r;

endmodule