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


//X instructions -------------------------------------------------------
// burayi bi incelemek lazim sacma sapan bir encoding vermisler ne oldugu anlasilmiyor
// evet hepsini alacakmisiz encodingde kullanmak icin :D 

//funct7 + fucnt3 + op_code
`define HMDST 0000101_001_0110011
`define PKG 0000100_100_0110011
`define SLADD 0010000_010_0110011

//funct3 + op_code
`define RVRS 101_0010011


//funct7 + rs2 + funct3 + op_code
`define CNTZ 0110000_00001_001_0010011
`define CNTP 0110000_00010_001_0010011

//funct7[0:5] + funct3 + op_code
`define CONV.LD.W 00000_010_0001011
`define CONV.LD.X 00000_000_0001011 //rd = 00000

//funct7 + rs2 + rs1 + funct3 + rd + op_code
`define CONV.CLR.W 0000000_00000_00000_011_00000_0001011
`define CONV.CLR.X 0000000_00000_00000_011_00000_0001011