
//-------------------------------------------------------------------------------------
//-----------------------------------I & M instructions--------------------------------
//-------------------------------------------------------------------------------------

//only op_code | U TYPE
`define LUI    0110111
`define AUIPC  0010111
`define JAL    1101111

//funct3 + op_code | S & I TYPE
`define JALR   000_1100111

`define BEQ    000_1100011
`define BNE    001_1100011
`define BLT    100_1100011
`define BGE    101_1100011
`define BLTU   110_1100011
`define BGEU   111_1100011

`define LB     000_0000011
`define LH     001_0000011
`define LW     010_0000011
`define LBU    100_0000011
`define LHU    101_0000011

`define SB     000_0100011
`define SH     001_0100011
`define SW     010_0100011

`define ADDI   000_0010011
`define SLTI   010_0010011
`define SLTIU  011_0010011
`define XORI   100_0010011
`define ORI    110_0010011
`define ANDI   111_0010011

//funct7 + funct3 + op_code | R TYPE
`define SLLI   0000000_001_0010011
`define SRLI   0000000_101_0010011
`define SRAI   0100000_101_0010011

`define ADD    0000000_000_0110011
`define SUB    0100000_000_0110011
`define SLL    0000000_001_0110011
`define SLT    0000000_010_0110011
`define SLTU   0000000_011_0110011
`define XOR    0000000_100_0110011
`define SRL    0000000_101_0110011
`define SRA    0100000_101_0110011
`define OR     0000000_110_0110011
`define AND    0000000_111_0110011
`define MUL    0000001_000_0110011
`define MULH   0000001_001_0110011
`define MULHSU 0000001_010_0110011
`define MULHU  0000001_011_0110011
`define DIV    0000001_100_0110011
`define DIVU   0000001_101_0110011
`define REM    0000001_110_0110011
`define REMU   0000001_111_0110011


//-------------------------------------------------------------------------------------
//-----------------------------------C instructions -----------------------------------
//-------------------------------------------------------------------------------------

//funct3 + op_code
`define C_ADDI4SPN 000_00 
`define C_LW       001_00
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

//funct7 + fucnt3 + op_code
`define HMDST      0000101_001_0110011
`define PKG        0000100_100_0110011
`define SLADD      0010000_010_0110011

//funct7 + rs2 + funct3 + op_code
`define RVRS       011010111000_101_0010011
`define CNTZ       0110000_00001_001_0010011
`define CNTP       0110000_00010_001_0010011

//funct7[0:5] + funct3 + rd + op_code
`define CONV_LD_W  000000_010_00000_0001011
`define CONV_LD_X  000000_000_00000_0001011

//funct7 + rs2 + rs1 + funct3 + rd + op_code
`define CONV_CLR_W 0000000_00000_00000_011_00000_0001011
`define CONV_CLR_X 0000000_00000_00000_011_00000_0001011

//funct7 + rs2 + rs1 + funct3 + op_code
`define CONV_RUN   0000000_00000_00000_100_0001011