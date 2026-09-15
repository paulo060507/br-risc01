module br_risc01_decoder import br_risc01_pkg::*; (
  input  logic [31:0] instr_i,
  output logic        reg_we_o,
  output logic        alu_imm_o,
  output alu_op_e     alu_op_o,
  output logic [63:0] imm_o,
  output logic        branch_o,
  output logic        jal_o,
  output logic        jalr_o,
  output logic        load_o,
  output logic        store_o,
  output logic        lui_o,
  output logic        auipc_o,
  output logic [2:0]  funct3_o,
  output logic        illegal_o
);
  logic [6:0] opcode, funct7;
  logic [2:0] funct3;

  assign opcode   = instr_i[6:0];
  assign funct3   = instr_i[14:12];
  assign funct7   = instr_i[31:25];
  assign funct3_o = funct3;

  always_comb begin
    reg_we_o  = 1'b0;
    alu_imm_o = 1'b0;
    alu_op_o  = ALU_ADD;
    imm_o     = 64'b0;
    branch_o  = 1'b0;
    jal_o     = 1'b0;
    jalr_o    = 1'b0;
    load_o    = 1'b0;
    store_o   = 1'b0;
    lui_o     = 1'b0;
    auipc_o   = 1'b0;
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
      7'b0010011: begin // OP-IMM
        reg_we_o  = 1'b1;
        alu_imm_o = 1'b1;
        imm_o = {{52{instr_i[31]}}, instr_i[31:20]};
        unique case (funct3)
          3'b000: alu_op_o = ALU_ADD;
          3'b010: alu_op_o = ALU_SLT;
          3'b011: alu_op_o = ALU_SLTU;
          3'b100: alu_op_o = ALU_XOR;
          3'b110: alu_op_o = ALU_OR;
          3'b111: alu_op_o = ALU_AND;
          3'b001: begin
            alu_op_o = ALU_SLL;
            if (instr_i[31:26] != 6'b000000) illegal_o = 1'b1;
          end
          3'b101: begin
            if (instr_i[31:26] == 6'b000000) alu_op_o = ALU_SRL;
            else if (instr_i[31:26] == 6'b010000) alu_op_o = ALU_SRA;
            else illegal_o = 1'b1;
          end
          default: illegal_o = 1'b1;
        endcase
      end
      7'b1100011: begin // BRANCH
        branch_o = 1'b1;
        imm_o = {{51{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        if (!(funct3 inside {3'b000,3'b001,3'b100,3'b101,3'b110,3'b111})) illegal_o = 1'b1;
      end
      7'b1101111: begin // JAL
        jal_o = 1'b1; reg_we_o = 1'b1;
        imm_o = {{43{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
      end
      7'b1100111: begin // JALR
        jalr_o = 1'b1; reg_we_o = 1'b1; alu_imm_o = 1'b1;
        imm_o = {{52{instr_i[31]}}, instr_i[31:20]};
        if (funct3 != 3'b000) illegal_o = 1'b1;
      end
      7'b0000011: begin // LOAD
        load_o = 1'b1; reg_we_o = 1'b1; alu_imm_o = 1'b1;
        imm_o = {{52{instr_i[31]}}, instr_i[31:20]};
        if (!(funct3 inside {3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110})) illegal_o = 1'b1;
      end
      7'b0100011: begin // STORE
        store_o = 1'b1; alu_imm_o = 1'b1;
        imm_o = {{52{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        if (!(funct3 inside {3'b000,3'b001,3'b010,3'b011})) illegal_o = 1'b1;
      end
      7'b0110111: begin // LUI
        lui_o = 1'b1; reg_we_o = 1'b1;
        imm_o = {{32{instr_i[31]}}, instr_i[31:12], 12'b0};
      end
      7'b0010111: begin // AUIPC
        auipc_o = 1'b1; reg_we_o = 1'b1;
        imm_o = {{32{instr_i[31]}}, instr_i[31:12], 12'b0};
      end
      default: illegal_o = 1'b1;
    endcase

    if (illegal_o) begin
      reg_we_o = 1'b0; branch_o = 1'b0; jal_o = 1'b0; jalr_o = 1'b0;
      load_o = 1'b0; store_o = 1'b0; lui_o = 1'b0; auipc_o = 1'b0;
    end
  end
endmodule
