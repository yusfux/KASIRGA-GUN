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


module controller(
    );


    //----------------------------------------------------------------------------------------------------------------------------
    //BELOW LINES ARE ONLY VALID FOR IMPLEMENTATIONS WITH M EXTENSION ONLY, THEY ARE NOT GENERAL SITUATIONS FOR EVERY ARCHITECTURE
    //----------------------------------------------------------------------------------------------------------------------------


    //------------------------Unpriviliged Counters/Timers------------------------
    //TODO: should we implement these registers?
    //these CSR's are read-only shadows of mcycle, minstret, and mhpmcountern, respectively
    //the time register is read-only shadow of the memory-mapped mtime register
    reg [63:0] cycle_r;
    reg [63:0] cycle_ns;
    reg [63:0] cycleh_r;
    reg [63:0] cycleh_ns;

    reg [63:0] time_r;
    reg [63:0] time_ns;
    reg [63:0] timeh_r;
    reg [63:0] timeh_ns;

    reg [63:0] instrat_r;
    reg [63:0] instrat_ns;
    reg [63:0] instreth_r;
    reg [63:0] instreth_ns;

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
    // MPRIV is read-only zero if U-mode is not supported
    // SUM is read-only zero if S-mode is not supported
    // MXR is read-only zero if S-mode is not supported
    // if MBE = 0, memory acceses are little-endian, big-endian otherwise
    // SBE is read-only zer oif S-mode is not suppoerted
    // UBE is read-only zero if U-mode is not supported
    // TVM is read-only zero when S-mode is not supported
    // TW is read-only zero whwen there are no modes less pribiliged than M
    // TSR is read-only zero when S-mode is not supported
    // if neither the F extension nor S-mode is implemented, then FS is read-only zero
    // if neither the v register nor S-mode is implemented, then VS is read-only zero
    // in systems withotu additional user extensions requiring new state, the XS field is read-only zero
    // if FS, XS and VS are all read-only zero, then SD is always zero
    reg [31:0] mstatus_r;
    reg [31:0] mstatus_ns;


    //a value of zero can be returned to indicate the misa register has not been implemented
    //modifiable bir isa implement etmedigimiz icin read-only olarak kullanabiliriz sanirim 
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

    reg [31:0] mstatush;

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

    reg [31:0] mtinst;
    reg [31:0] mtval2;

    //------------------------Machine Configuration------------------------
    reg [31:0] menvcfg;
    reg [31:0] menvcfgh;
    reg [31:0] mseccfg;
    reg [31:0] mseccfgh;

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
    reg [31:0] mcountinhibit = 32'b00000000000000000000000000000000;

    
endmodule