module br_risc01_regfile (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic [4:0]  rs1_i,
  input  logic [4:0]  rs2_i,
  output logic [63:0] rs1_o,
  output logic [63:0] rs2_o,
  input  logic        we_i,
  input  logic [4:0]  rd_i,
  input  logic [63:0] wd_i
);
  logic [63:0] regs [1:31];
  integer i;

  assign rs1_o = (rs1_i == 5'd0) ? 64'd0 : regs[rs1_i];
  assign rs2_o = (rs2_i == 5'd0) ? 64'd0 : regs[rs2_i];

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      for (i = 1; i < 32; i = i + 1)
        regs[i] <= 64'd0;
    end else if (we_i && (rd_i != 5'd0)) begin
      regs[rd_i] <= wd_i;
    end
  end
endmodule
