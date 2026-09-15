`timescale 1ns/1ps
module tb_br_risc01_core;
  logic clk = 0;
  logic rst_n = 0;
  logic [63:0] imem_addr;
  logic [31:0] imem_rdata;
  logic [63:0] dmem_addr, dmem_wdata, dmem_rdata;
  logic [7:0] dmem_wstrb;
  logic dmem_we, illegal;
  logic [31:0] rom [0:31];
  logic [7:0] ram [0:255];
  integer i;

  always #5 clk = ~clk;
  assign imem_rdata = rom[imem_addr[6:2]];
  assign dmem_rdata = {ram[{dmem_addr[7:3],3'b111}], ram[{dmem_addr[7:3],3'b110}],
                       ram[{dmem_addr[7:3],3'b101}], ram[{dmem_addr[7:3],3'b100}],
                       ram[{dmem_addr[7:3],3'b011}], ram[{dmem_addr[7:3],3'b010}],
                       ram[{dmem_addr[7:3],3'b001}], ram[{dmem_addr[7:3],3'b000}]};

  always_ff @(posedge clk) begin
    if (dmem_we) begin
      for (i = 0; i < 8; i = i + 1)
        if (dmem_wstrb[i]) ram[{dmem_addr[7:3],3'b000} + i] <= dmem_wdata[i*8 +: 8];
    end
  end

  br_risc01_core dut (
    .clk_i(clk), .rst_ni(rst_n), .imem_addr_o(imem_addr), .imem_rdata_i(imem_rdata),
    .dmem_addr_o(dmem_addr), .dmem_wdata_o(dmem_wdata), .dmem_wstrb_o(dmem_wstrb),
    .dmem_we_o(dmem_we), .dmem_rdata_i(dmem_rdata), .illegal_o(illegal)
  );

  initial begin
    for (i = 0; i < 32; i = i + 1) rom[i] = 32'h00000013;
    for (i = 0; i < 256; i = i + 1) ram[i] = 8'h00;

    rom[0]  = 32'h00500093; // addi x1,x0,5
    rom[1]  = 32'h00700113; // addi x2,x0,7
    rom[2]  = 32'h002081b3; // add  x3,x1,x2 = 12
    rom[3]  = 32'h40118233; // sub  x4,x3,x1 = 7
    rom[4]  = 32'h00108463; // beq  x1,x1,+8 (skip next)
    rom[5]  = 32'h06300213; // addi x4,x0,99 (must be skipped)
    rom[6]  = 32'h008002ef; // jal  x5,+8 (x5 gets PC+4 = 28)
    rom[7]  = 32'h06300313; // addi x6,x0,99 (must be skipped)
    rom[8]  = 32'h00303023; // sd   x3,0(x0)
    rom[9]  = 32'h00003303; // ld   x6,0(x0) = 12
    rom[10] = 32'h123453b7; // lui  x7,0x12345

    #20 rst_n = 1;
    #140;

    if (dut.u_regfile.regs[1] !== 64'd5) $fatal(1, "x1 failed");
    if (dut.u_regfile.regs[2] !== 64'd7) $fatal(1, "x2 failed");
    if (dut.u_regfile.regs[3] !== 64'd12) $fatal(1, "x3 failed");
    if (dut.u_regfile.regs[4] !== 64'd7) $fatal(1, "branch failed");
    if (dut.u_regfile.regs[5] !== 64'd28) $fatal(1, "jal link failed");
    if (dut.u_regfile.regs[6] !== 64'd12) $fatal(1, "load/store failed");
    if (dut.u_regfile.regs[7] !== 64'h0000_0000_1234_5000) $fatal(1, "lui failed");

    $display("BR-RISC01 control-flow/memory smoke test PASS");
    $finish;
  end
endmodule
