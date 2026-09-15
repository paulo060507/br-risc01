module br_risc01_decoder import br_risc01_pkg::*; (
  input  logic [31:0] instr_i,
  output logic        reg_we_o,
  output logic        alu_imm_o,
  output alu_op_e     alu_op_o,
  output logic [63:0] imm_o,
  output logic        illegal_o
);
  logic [6:0] opcode, funct7;
  logic [2:0] funct3;

  assign opcode = instr_i[6:0];
  assign funct3 = instr_i[14:12];
  assign funct7 = instr_i[31:25];

  always_comb begin
    reg_we_o  = 1'b0;
    alu_imm_o = 1'b0;
    alu_op_o  = ALU_ADD;
    imm_o     = {{52{instr_i[31]}}, instr_i[31:20]};
    illegal_o = 1'b0;

    unique case (opcode)
      7'b0110011: begin // OP
        reg_we_o = 1'b1;
        unique case (funct3)
          3'b000: alu_op_o = funct7[5] ? ALU_SUB : ALU_ADD;
          3'b001: alu_op_o = ALU_SLL;
          3'b010: alu_op_o = ALU_SLT;
          3'b011: alu_op_o = ALU_SLTU;
          3'b100: alu_op_o = ALU_XOR;
          3'b101: alu_op_o = funct7[5] ? ALU_SRA : ALU_SRL;
          3'b110: alu_op_o = ALU_OR;
          3'b111: alu_op_o = ALU_AND;
          default: illegal_o = 1'b1;
        endcase
      end
      7'b0010011: begin // OP-IMM subset
        reg_we_o  = 1'b1;
        alu_imm_o = 1'b1;
        unique case (funct3)
          3'b000: alu_op_o = ALU_ADD;  // ADDI
          3'b010: alu_op_o = ALU_SLT;  // SLTI
          3'b011: alu_op_o = ALU_SLTU; // SLTIU
          3'b100: alu_op_o = ALU_XOR;  // XORI
          3'b110: alu_op_o = ALU_OR;   // ORI
          3'b111: alu_op_o = ALU_AND;  // ANDI
          default: illegal_o = 1'b1;    // shifts added in next milestone
        endcase
      end
      default: illegal_o = 1'b1;
    endcase

    if (illegal_o)
      reg_we_o = 1'b0;
  end
endmodule
