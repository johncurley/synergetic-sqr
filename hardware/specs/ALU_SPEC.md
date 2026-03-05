# ALU Specification: SPU-1 (SQR-ASIC)
## Gate-Level Logic for DQFA Operations (v2.9.8)

This document specifies the Register Transfer Level (RTL) requirements for the SPU-1 Arithmetic Logic Unit and its High-Dimensional extensions.

[... Sections 1-14 remain active and verified ...]

### 15. Hysteresis-Zero Power Management (Steinmetz-Native)
[... Existing Section 15 ...]

#### 15.4 Opcode Specification (v2.9.8)
| Opcode | Mnemonic | Hardware Path | Latency | Description |
| :--- | :--- | :--- | :--- | :--- |
| `001` | **`SPERM_X4`** | `spu_permute` | 0 Cycles | 4D Prime-Axis Basis Shift. |
| `010` | **`SMUL`** | `spu_smul` | 1 Cycle | Surd multiplication (Integer ALU). |
| `011` | **`EQUILIBRATE`** | `spu_tensegrity_balancer` | 5 Cycles | Pipelined Discrete Laplacian Relaxation. |
| `100` | **`OP_DAMP`** | `spu_damper` | 1 Cycle | Rational Damper (A-Domain Step-Down). |
| `101` | **`OP_CLAMP`** | `spu_core` | 0 Cycles | Dimension-Clamp safety gate. |
| `110` | **`SPERM_13`** | `spu_permute_13`| 0 Cycles | 13-Axis Aperiodic Shuffle [RESTRICTED]. |
| `111` | **`SPERM_4D`** | `spu_permute` | 0 Cycles | 4D Cyclic Phase Shift (A->B->C->D). |
| `000` | `NOP` | Bypass | 0 Cycles | No operation. |

### 16. Thomson Projection Gate (Display Boundary)
The SPU-13 includes a dedicated hardware gate for mapping 4D isotropic coordinates to 3D Cartesian display space. This gate is located at the final output boundary of the processor.

#### 16.1 Projection Logic
The gate implements the following bit-exact integer mapping:
*   **X = (A - B - C + D) >>> 1**
*   **Y = (A - B + C - D) >>> 1**
*   **Z = (A + B - C - D) >>> 1**

#### 16.2 4D Vantage Point Solving
By utilizing the **`SPERM_4D`** instruction, the processor can solve complex 3D spatial problems by performing a zero-latency cyclic shift in the 4th dimension. This eliminates the need for 3D rotation matrices, as 3D motion is resolved as a byproduct of 4D isotropic shuffles.

---
*Status: RESONANT. 4D Vantage Point logic active.*
