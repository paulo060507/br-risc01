module br_risc01_core import br_risc01_pkg::*; (
  input  logic        clk_i,
  input  logic        rst_ni,
  output logic [63:0] imem_addr_o,
  input  logic [31:0] imem_rdata_i,
  output logic        illegal_o
);
  logic [63:0] pc_q;
  logic [4:0] rs1, rs2, rd;
  logic [63:0] rs1_data, rs2_data, alu_b, alu_result, imm;
  logic reg_we, alu_imm;
  alu_op_e alu_op;

  assign rs1 = imem_rdata_i[19:15];
  assign rs2 = imem_rdata_i[24:20];
  assign rd  = imem_rdata_i[11:7];
  assign imem_addr_o = pc_q;
  assign alu_b = alu_imm ? imm : rs2_data;

  br_risc01_decoder u_decoder (
    .instr_i(imem_rdata_i), .reg_we_o(reg_we), .alu_imm_o(alu_imm),
    .alu_op_o(alu_op), .imm_o(imm), .illegal_o(illegal_o)
  );

  br_risc01_regfile u_regfile (
    .clk_i(clk_i), .rst_ni(rst_ni), .rs1_i(rs1), .rs2_i(rs2),
    .rs1_o(rs1_data), .rs2_o(rs2_data), .we_i(reg_we),
    .rd_i(rd), .wd_i(alu_result)
  );

  br_risc01_alu u_alu (
    .a_i(rs1_data), .b_i(alu_b), .op_i(alu_op), .result_o(alu_result)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_ni)
      pc_q <= 64'd0;
    else
      pc_q <= pc_q + 64'd4;
  end
endmodule
