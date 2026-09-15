# BR-RISC01

**Brazilian Auditable RISC-V Processor — InovaNext**

BR-RISC01 is an experimental, auditable 64-bit RISC-V processor project intended as the CPU foundation for the future **BR-NET01** networking SoC.

## Project principles

- Auditable RTL with no intentionally opaque execution blocks.
- Small, understandable, in-order implementation before performance optimization.
- Verification is a first-class requirement.
- External radios and DMA-capable devices are treated as untrusted in the future BR-NET01 SoC.
- Security claims must be evidence-based: this project aims to reduce opaque trust and attack surface; it does not claim absolute absence of backdoors or vulnerabilities.

## v0.1 scope

The first milestone targets a simple RV64I execution core. The repository currently contains the initial ALU, register file, decoder/control logic, core integration and simulation testbench. Later milestones will add missing RV64I functionality, exceptions/CSRs, privileged modes, PMP, MMU/Sv39 and the extensions needed for Linux/OpenWrt.

## Structure

```text
rtl/        Synthesizable SystemVerilog RTL
sim/        Simulation testbenches
docs/       Architecture and security documentation
```

## Status

Early development / research RTL. **Not production silicon and not yet RISC-V conformant.**

## Roadmap

1. Complete and verify RV64I integer ISA.
2. Add architectural exception handling and Zicsr.
3. Add M/A extensions as required.
4. Add Machine/Supervisor/User privilege support and PMP.
5. Add Sv39 MMU and caches.
6. Boot a minimal software stack and Linux.
7. Integrate into BR-NET01 and prototype on FPGA.
8. ASIC-oriented verification and implementation flow.

Copyright (c) 2026 InovaNext. Licensing will be explicitly defined before external reuse or contribution.
