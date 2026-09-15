# BR-RISC01 / BR-NET01 Security Principles

## Threat-model direction

The project is intended to minimize opaque trust, undocumented execution paths and unnecessary privileged components. It must not make an absolute claim that silicon is free of backdoors or vulnerabilities.

## Design rules

1. BR-RISC01 RTL remains inspectable and reviewable.
2. No undocumented auxiliary processor may execute privileged code inside the CPU design.
3. Debug access must have an explicit production lifecycle and lock mechanism before silicon deployment.
4. BR-NET01 must treat Wi-Fi/radio modules and other DMA-capable external devices as untrusted.
5. DMA access should be constrained by an IOMMU or dedicated DMA firewall.
6. Secure boot should begin from a minimal immutable root and authenticate subsequent mutable stages.
7. Secret storage, device identity and entropy generation require dedicated threat modeling and physical implementation review.
8. Build inputs, tool versions and generated artifacts should be recorded for reproducibility.
9. ASIC flow should include equivalence and post-synthesis/post-layout checks.
10. Third-party IP must be inventoried with source, license, version and security rationale.

## Future work

A dedicated threat model will enumerate assets, trust boundaries, attackers, lifecycle states, debug/test interfaces, supply-chain assumptions and fabrication verification limits.
