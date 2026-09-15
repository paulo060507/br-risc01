package br_risc01_pkg;
  typedef enum logic [3:0] {
    ALU_ADD, ALU_SUB, ALU_SLL, ALU_SLT, ALU_SLTU,
    ALU_XOR, ALU_SRL, ALU_SRA, ALU_OR, ALU_AND
  } alu_op_e;

  typedef enum logic [1:0] {
    WB_ALU, WB_MEM, WB_PC4
  } wb_sel_e;
endpackage
