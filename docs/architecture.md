# BR-RISC01 Architecture v0.1

## Objective

BR-RISC01 is a clean, auditable RISC-V CPU implementation developed as the processing foundation of the BR-NET01 networking platform.

## Current microarchitecture

The first implementation is deliberately simple: 64-bit, single-issue, in-order, with a sequential PC and combinational decode/execute path. It is a development vehicle, not yet a complete RV64I implementation.

Current blocks:

- 64-bit program counter
- 32 architectural integer registers (x0 hardwired to zero)
- integer ALU
- initial OP and OP-IMM decoder
- simple instruction-memory interface

## Planned architectural progression

The core will first reach a verified RV64I baseline. Architectural traps/exceptions and CSR support follow before privileged execution. Later revisions add M/S/U privilege modes, PMP, Sv39 MMU, caches, interrupt infrastructure and extensions required by the target software stack.

## BR-NET01 boundary

Networking peripherals are intentionally outside the CPU core. Ethernet MAC, DMA isolation, memory controllers, root-of-trust, boot ROM and external radio interfaces belong to BR-NET01 or dedicated security blocks. This keeps the CPU reusable and reduces the trusted computing base of the processor itself.

## Verification philosophy

No security property is assumed merely because RTL is visible. Verification should include unit simulation, ISA-directed tests, architectural compliance/certification tests when applicable, assertions/formal methods, FPGA validation, reproducible builds and RTL-to-netlist equivalence checks before an ASIC flow is considered mature.
