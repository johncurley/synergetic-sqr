# ALU Specification: SPU-1 (SQR-ASIC)
## Gate-Level Logic for DQFA Operations (v2.9.9)

This document specifies the Register Transfer Level (RTL) requirements for the SPU-1 Arithmetic Logic Unit and its High-Dimensional extensions.

[... Sections 1-14 remain active and verified ...]

### 15. Hysteresis-Zero Power Management (Steinmetz-Native)
To eliminate the "Hysteresis Tax" (thermal entropy) inherent in cubic switching, the SPU-13 utilizes resonant field dynamics initiated via the **Anabasis Routine (see docs/BOOT_SPEC.md)**.

#### 15.1 Henosis State (Peak Efficiency)
Steady-state execution is reached when the chip achieves **Henosis**—a state of perfect synchronization between the silicon gates and the dielectric field. In this state, 13D shuffles occur with zero-latency identity preservation and no detectable thermal residue.

#### 15.2 Orbital Bit-Logic
Standard CPUs utilize square-wave switching, forcing 180° magnetic domain flips that generate heat.
*   **Mechanism:** SPU-13 utilizes **85° Phase Rotations** to "orbit" bit-states.
*   **Result:** Collapses the Hysteresis Loop into a single, resonant line. Logic is implemented as a vectorial rotation rather than a binary flip, achieving near-zero heat dissipation during steady-state shuffles.

#### 15.3 Dielectric Counter-Space (Field-Centric)
The SPU-13 architecture prioritizes the **Dielectric Field** (potential energy in the vacuum between gates) over standard magnetic current flow.
*   **Laminar Dispatch:** Power is distributed via the **Hexagonal Power Mesh** to maintain dielectric equilibrium.
*   **Energy Recycling:** The "Hysteresis-Zero" equations allow the chip to recapture the field-energy from completed shuffles, utilizing the magnetic memory of the silicon as a resonant tank circuit.

#### 15.4 Field-Strength Sensitivity
The optimized SQR vector algorithm is designed to operate at the **Dielectric Limit**. High-velocity shuffles may produce a dielectric discharge (The "Purple Glow") at the clip-plane boundary, representing the successful synchronization of the silicon with the Etheric reality-substrate.

#### 15.5 Opcode Specification (v2.9.9)
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
[... Existing Section 16 ...]

---
*Status: ASCENDED. The Anabasis sequence is primary.*
