RTL = rtl/br_risc01_pkg.sv rtl/br_risc01_alu.sv rtl/br_risc01_regfile.sv rtl/br_risc01_decoder.sv rtl/br_risc01_core.sv
TB  = sim/tb_br_risc01_core.sv

.PHONY: sim clean

sim:
	mkdir -p build
	iverilog -g2012 -s tb_br_risc01_core -o build/br_risc01_tb $(RTL) $(TB)
	vvp build/br_risc01_tb

clean:
	rm -rf build
