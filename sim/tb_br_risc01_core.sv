`timescale 1ns/1ps
module tb_br_risc01_core;
  logic clk = 0;
  logic rst_n = 0;
  logic [63:0] imem_addr;
  logic [31:0] imem_rdata;
  logic illegal;
  logic [31:0] rom [0:15];

  always #5 clk = ~clk;
  assign imem_rdata = rom[imem_addr[5:2]];

  br_risc01_core dut (
    .clk_i(clk), .rst_ni(rst_n), .imem_addr_o(imem_addr),
    .imem_rdata_i(imem_rdata), .illegal_o(illegal)
  );

  initial begin
    integer i;
    for (i = 0; i < 16; i = i + 1) rom[i] = 32'h00000013; // ADDI x0,x0,0
    rom[0] = 32'h00500093; // addi x1,x0,5
    rom[1] = 32'h00700113; // addi x2,x0,7
    rom[2] = 32'h002081b3; // add  x3,x1,x2 -> 12
    rom[3] = 32'h40118233; // sub  x4,x3,x1 -> 7

    #20 rst_n = 1;
    #60;

    if (dut.u_regfile.regs[1] !== 64'd5)  $fatal(1, "x1 failed");
    if (dut.u_regfile.regs[2] !== 64'd7)  $fatal(1, "x2 failed");
    if (dut.u_regfile.regs[3] !== 64'd12) $fatal(1, "x3 failed");
    if (dut.u_regfile.regs[4] !== 64'd7)  $fatal(1, "x4 failed");

    $display("BR-RISC01 smoke test PASS");
    $finish;
  end
endmodule
