module br_risc01_core import br_risc01_pkg::*; (
  input  logic        clk_i,
  input  logic        rst_ni,
  output logic [63:0] imem_addr_o,
  input  logic [31:0] imem_rdata_i,
  output logic [63:0] dmem_addr_o,
  output logic [63:0] dmem_wdata_o,
  output logic [7:0]  dmem_wstrb_o,
  output logic        dmem_we_o,
  input  logic [63:0] dmem_rdata_i,
  output logic        illegal_o
);
  logic [63:0] pc_q, pc_next;
  logic [4:0] rs1, rs2, rd;
  logic [63:0] rs1_data, rs2_data, alu_b, alu_result, imm, wb_data, load_data;
  logic reg_we_dec, reg_we, alu_imm, branch, jal, jalr, load, store, lui, auipc;
  logic branch_taken;
  logic [2:0] funct3;
  alu_op_e alu_op;

  assign rs1 = imem_rdata_i[19:15];
  assign rs2 = imem_rdata_i[24:20];
  assign rd  = imem_rdata_i[11:7];
  assign imem_addr_o = pc_q;
  assign alu_b = alu_imm ? imm : rs2_data;

  br_risc01_decoder u_decoder (
    .instr_i(imem_rdata_i), .reg_we_o(reg_we_dec), .alu_imm_o(alu_imm),
    .alu_op_o(alu_op), .imm_o(imm), .branch_o(branch), .jal_o(jal),
    .jalr_o(jalr), .load_o(load), .store_o(store), .lui_o(lui),
    .auipc_o(auipc), .funct3_o(funct3), .illegal_o(illegal_o)
  );

  br_risc01_regfile u_regfile (
    .clk_i(clk_i), .rst_ni(rst_ni), .rs1_i(rs1), .rs2_i(rs2),
    .rs1_o(rs1_data), .rs2_o(rs2_data), .we_i(reg_we),
    .rd_i(rd), .wd_i(wb_data)
  );

  br_risc01_alu u_alu (
    .a_i(rs1_data), .b_i(alu_b), .op_i(alu_op), .result_o(alu_result)
  );

  always_comb begin
    branch_taken = 1'b0;
    unique case (funct3)
      3'b000: branch_taken = (rs1_data == rs2_data); // BEQ
      3'b001: branch_taken = (rs1_data != rs2_data); // BNE
      3'b100: branch_taken = ($signed(rs1_data) <  $signed(rs2_data)); // BLT
      3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
      3'b110: branch_taken = (rs1_data < rs2_data); // BLTU
      3'b111: branch_taken = (rs1_data >= rs2_data); // BGEU
      default: branch_taken = 1'b0;
    endcase
  end

  always_comb begin
    pc_next = pc_q + 64'd4;
    if (branch && branch_taken) pc_next = pc_q + imm;
    if (jal)  pc_next = pc_q + imm;
    if (jalr) pc_next = (rs1_data + imm) & ~64'd1;
  end

  always_comb begin
    dmem_addr_o  = alu_result;
    dmem_wdata_o = 64'b0;
    dmem_wstrb_o = 8'b0;
    dmem_we_o    = 1'b0;
    if (store && !illegal_o) begin
      dmem_we_o = 1'b1;
      unique case (funct3)
        3'b000: begin dmem_wdata_o = {8{rs2_data[7:0]}};  dmem_wstrb_o = 8'b0000_0001 << alu_result[2:0]; end
        3'b001: begin dmem_wdata_o = {4{rs2_data[15:0]}}; dmem_wstrb_o = 8'b0000_0011 << alu_result[2:0]; end
        3'b010: begin dmem_wdata_o = {2{rs2_data[31:0]}}; dmem_wstrb_o = 8'b0000_1111 << alu_result[2:0]; end
        3'b011: begin dmem_wdata_o = rs2_data;            dmem_wstrb_o = 8'b1111_1111; end
        default: begin dmem_wdata_o = 64'b0; dmem_wstrb_o = 8'b0; dmem_we_o = 1'b0; end
      endcase
    end
  end

  always_comb begin
    unique case (funct3)
      3'b000: load_data = {{56{dmem_rdata_i[7]}},  dmem_rdata_i[7:0]};
      3'b001: load_data = {{48{dmem_rdata_i[15]}}, dmem_rdata_i[15:0]};
      3'b010: load_data = {{32{dmem_rdata_i[31]}}, dmem_rdata_i[31:0]};
      3'b011: load_data = dmem_rdata_i;
      3'b100: load_data = {56'b0, dmem_rdata_i[7:0]};
      3'b101: load_data = {48'b0, dmem_rdata_i[15:0]};
      3'b110: load_data = {32'b0, dmem_rdata_i[31:0]};
      default: load_data = 64'b0;
    endcase
  end

  always_comb begin
    wb_data = alu_result;
    if (load) wb_data = load_data;
    else if (jal || jalr) wb_data = pc_q + 64'd4;
    else if (lui) wb_data = imm;
    else if (auipc) wb_data = pc_q + imm;
    reg_we = reg_we_dec && !illegal_o;
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni) pc_q <= 64'd0;
    else pc_q <= pc_next;
  end
endmodule
