
//-------------------------------------------------------------------------------------
//-----------------------------------I & M instructions--------------------------------
//-------------------------------------------------------------------------------------


//only op_code
`define LUI    0110111
`define AUIPC  0010111
`define JAL    1101111
`define JALR   1100111  //funct3 == 3'b0

`define BRANCH 1100011
`define BEQ    000
`define BNE    001
`define BLT    100
`define BGE    101
`define BLTU   110
`define BGEU   111

`define LOAD   0000011
`define LB     000
`define LH     001
`define LW     010
`define LBU    100
`define LHU    101

`define STORE  0100011
`define SB     000
`define SH     001
`define SW     010

`define OP_IMM 0010011
`define ADDI   000
`define SLTI   010
`define SLTIU  011
`define XORI   100
`define ORI    110
`define ANDI   111
`define SLLI   0000000_001
`define SRLI   0000000_101
`define SRAI   0100000_101

`define OP     0110011
`define ADD    0000000_000
`define SUB    0100000_000
`define SLL    0000000_001
`define SLT    0000000_010
`define SLTU   0000000_011
`define XOR    0000000_100
`define SRL    0000000_101
`define SRA    0100000_101
`define OR     0000000_110
`define AND    0000000_111
`define MUL    0000001_000
`define MULH   0000001_001
`define MULHSU 0000001_010
`define MULHU  0000001_011
`define DIV    0000001_100
`define DIVU   0000001_101
`define REM    0000001_110
`define REMU   0000001_111


//-------------------------------------------------------------------------------------
//-----------------------------------C instructions -----------------------------------
//-------------------------------------------------------------------------------------

//funct3 + op_code
`define C_ADDI4SPN 000_00 
`define C_LW       010_00
`define C_SW       110_00
`define C_JAL      001_01
`define C_J        101_01
`define C_BEQZ     110_01
`define C_BNEZ     111_01
`define C_SWSP     110_10

`define C_ADDI     000_01   //rd != 0
`define C_NOP      000_01   //rd = 0

`define C_LI       010_01   //rd != 0

`define C_ADDI16SP 011_01   //rd = 2
`define C_LUI      011_01   //rd != 0 && rd != 2

`define C_SLLI     000_10   //rd != 0

`define C_LWSP     010_10   //rd != 0

`define C_SRLI     100_01   //inst[11:10] = 00
`define C_SRAI     100_01   //inst[11:10] = 01
`define C_ANDI     100_01   //inst[11:10] = 10
`define C_SUB      100_01   //inst[12:10] = 011 && inst[6:5] = 00
`define C_XOR      100_01   //inst[12:10] = 011 && inst[6:5] = 01
`define C_OR       100_01   //inst[12:10] = 011 && inst[6:5] = 10
`define C_AND      100_01   //inst[12:10] = 011 && inst[6:5] = 11


`define C_JR       100_10   //inst[12] = 0 && rd != 0 && rs2 = 0
`define C_MV       100_10   //inst[12] = 0 && rd != 0 && rs2 != 0
`define C_JALR     100_10   //inst[12] = 1 && rd != 0 && rs2 = 0
`define C_ADD      100_10   //isnt[12] = 1 && rd != 0 && rs2 != 0


//-------------------------------------------------------------------------------------
//-----------------------------------X instructions -----------------------------------
//-------------------------------------------------------------------------------------

//op_code = OP
`define HMDST      0000101_001
`define PKG        0000100_100
`define SLADD      0010000_010

//funct7 + rs2 + funct3
//op_code = OP_IMM
`define RVRS       0110101_11000_101
`define CNTZ       0110000_00001_001
`define CNTP       0110000_00010_001

`define AI 0001011
`define CONV_LD_X  000000_000 //funct7[6] == 1 ise rs1 + rs2, degilse yalnizca rs1 | rd == 5'b0
`define CONV_LD_W  000000_010 //funct7[6] == 1 ise rs1 + rs2, degilse yalnizca rs1 | rd == 5'b0
`define CONV_CLR_X 0000000_001 //rs1 = rs2 = rd = 5'b0
`define CONV_CLR_W 0000000_011 //rs1 = rs2 = rd = 5'b0
`define CONV_RUN   0000000_100 //rs1 = rs2 = 5'b0


//-------------------------------------------------------------------------------------
//--------------------------------SYSTEM instructions ---------------------------------
//-------------------------------------------------------------------------------------

`define SYSTEM 1110011
`define PRIV   000
`define CSRRW  001
`define CSRRS  010
`define CSRRC  011
`define CSRRWI 101
`define CSRRSI 110
`define CSRRCI 111

//-------------------------------------------------------------------------------------
//--------------------------ADRESS SPACES FOR CSR instructions--------------------------
//-------------------------------------------------------------------------------------

`define MVENDORID  12'hF11
`define MARCHID    12'hF12
`define MIMPID     12'hF13
`define MHARTID    12'hF14
`define MCONFIGPTR 12'hF15

`define MSTATUS    12'h300
`define MISA       12'h301
`define MIE        12'h304
`define MTVEC      12'h305
`define MSTATUSH   12'h310

`define MSCRATCH   12'h340
`define MEPC       12'h341
`define MCAUSE     12'h342
`define MTVAL      12'h343
`define MIP        12'h344
`define MTINST     12'h34A
`define MTVAL2     12'h34B

`define MCYCLE     12'hB00
`define MINSTRET   12'hB00
`define MCYCLEH    12'hB80
`define MINSTRETH  12'hB82

`define CYCLE      12'hC00
`define INSTRET    12'hC02
`define CYCLEH     12'hC80
`define INSTRETH   12'hC82