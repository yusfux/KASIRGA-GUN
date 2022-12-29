//-------------------------------------------------------------------------------------
//-----------------------------------ALU OPERATIONS------------------------------------
//-------------------------------------------------------------------------------------
`define ALU_LUI   6'b000000
`define ALU_AUIPC 6'b000001
`define ALU_JAL   6'b000010
`define ALU_JALR  6'b000011

`define ALU_BEQ 6'b000100
`define ALU_BNE 6'b000101
`define ALU_BLT 6'b000110
`define ALU_BGE 6'b000111
`define ALU_BLTU  6'b001000
`define ALU_BGEU  6'b001001

`define ALU_ADDI  6'b001010
`define ALU_SLTI  6'b001011
`define ALU_SLTIU 6'b001100
`define ALU_XORI  6'b001101
`define ALU_ORI   6'b001110
`define ALU_ANDI  6'b001111
`define ALU_SLLI   6'b010000
`define ALU_SRLI   6'b010001
`define ALU_SRAI   6'b010010

`define ALU_ADD    6'b010011
`define ALU_SUB    6'b010100
`define ALU_SLT    6'b010101
`define ALU_SLTU   6'b010110
`define ALU_XOR    6'b010111
`define ALU_SRL    6'b011000
`define ALU_SRA    6'b011001
`define ALU_OR     6'b011010
`define ALU_AND    6'b011011
`define ALU_MUL    6'b011100
`define ALU_MULH   6'b011101
`define ALU_MULHSU 6'b011110
`define ALU_MULHU  6'b011111
`define ALU_DIV    6'b100000
`define ALU_DIVU   6'b100001
`define ALU_REM    6'b100010
`define ALU_REMU   6'b100011

`define ALU_SLL    6'b100100    //unutmusum :(

`define ALU_MEM 6'b100101


//-------------------------------------------------------------------------------------
//---------------------------------BRANCHING OPERATIONS---------------------------------
//-------------------------------------------------------------------------------------
`define BRA_BEQ 3'b000
`define BRA_BNE 3'b001
`define BRA_BLT 3'b010
`define BRA_BGE 3'b011

`define BRA_BLTU 3'b100
`define BRA_BGEU 3'b101


//-------------------------------------------------------------------------------------
//----------------------------------MEMORY OPERATIONS----------------------------------
//-------------------------------------------------------------------------------------
`define MEM_LB  3'b000
`define MEM_LH  3'b001
`define MEM_LW  3'b010
`define MEM_LBU 3'b011

`define MEM_LHU 3'b100
`define MEM_SB  3'b101
`define MEM_SH  3'b110
`define MEM_SW  3'b111


//-------------------------------------------------------------------------------------
//------------------------------------AI OPERATIONS------------------------------------
//-------------------------------------------------------------------------------------
`define AI_CONV_LD_X  3'b000
`define AI_CONV_LD_W  3'b001
`define AI_CONV_CLR_X 3'b010
`define AI_CONV_CLR_W 3'b011
`define AI_CONV_RUN   3'b100

//-------------------------------------------------------------------------------------
//----------------------------------CRYPTO OPERATIONS----------------------------------
//-------------------------------------------------------------------------------------
`define CRY_HMDST 3'b000
`define CRY_PKG   3'b001
`define CRY_SLADD 3'b010
`define CRY_RVRS  3'b011
`define CRY_CNTZ  3'b100
`define CRY_CNTP  3'b101
