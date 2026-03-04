# RISC-V Isotropic Extension (SPU-13)
## Mapping SQR Primitives to Custom-0 Opcode Space (v2.7.0)

To achieve industrial synthesizability and toolchain compatibility, the SPU-13 is implemented as a RISC-V custom accelerator.

### 1. Instruction Format (R-Type)
We utilize the RISC-V `custom-0` opcode (**`0001011`**) for all isotropic operations.

| 31..25 | 24..20 | 19..15 | 14..12 | 11..7 | 6..0 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **funct7** | **rs2** (Q-Reg B) | **rs1** (Q-Reg A) | **funct3** | **rd** (Dest) | **0001011** |

### 2. Opcode Mapping (funct3 / funct7)

| Mnemonic | funct3 | funct7 | Description |
| :--- | :--- | :--- | :--- |
| `SADD` | `000` | `0000000` | Parallel Integer Quadray Add. |
| `SMUL` | `001` | `0000000` | Phi-Core Multiplier (Q(3,5)). |
| `SPERM_X4` | `010` | `00000xx` | 4D Prime-Axis Shift (Phase in funct7 bits 0-1). |
| `SPERM_13` | `011` | `0000000` | 13-Axis Aperiodic Cyclic Shuffle. |
| `OP_DAMP` | `100` | `0000000` | A-Domain Rational Damper. |
| `OP_EQUIL` | `101` | `0000000` | 12-Neighbor Laplacian Relaxation. |

### 3. Register Mapping
The RISC-V floating-point registers (f0-f31) are shadowed by SPU **832-bit Wide Registers**. 
*   **Logical:** Instructions appear as standard register-to-register moves.
*   **Physical:** The hardware dispatches the 832-bit bus to the SPU-13 core for zero-latency processing.

### 4. Verification Metric: R6=I
Silicon certification is achieved when the `SPERM_X4` instruction restores bit-exact identity after exactly 6 (or 60/600) sequential phase shifts.

---
*Status: CERTIFICATION DRAFT. Aligned with RISC-V Custom ISA standards.*
