# ALU Specification: SPU-1 (SQR-ASIC)
## Gate-Level Logic for DQFA Operations (v2.4.3)

This document specifies the Register Transfer Level (RTL) requirements for the SPU-1 Arithmetic Logic Unit and its High-Dimensional extensions.

### 1. Surd Multiplier Unit (SMUL)
The `SMUL` unit calculates the product of two elements in $\mathbb{Q}(\sqrt{3})$ or $\mathbb{Q}(\sqrt{3}, \sqrt{5})$.

#### 1.1 Inputs
- `Lane A [31:0]`: Coefficient $a_1$
- `Lane B [31:0]`: Coefficient $b_1$
- `Lane C [31:0]`: Coefficient $a_2$
- `Lane D [31:0]`: Coefficient $b_2$

#### 1.2 Intermediate Logic (64-bit)
1.  `P1 = Lane A * Lane C` (Signed 32x32 -> 64)
2.  `P2 = Lane B * Lane D` (Signed 32x32 -> 64)
3.  `P3 = Lane A * Lane D` (Signed 32x32 -> 64)
4.  `P4 = Lane B * Lane C` (Signed 32x32 -> 64)
5.  `SURD_TERM = (P2 << 1) + P2` (Multiplying $b_1 b_2$ by 3 via shift-and-add)

#### 1.3 Output Stage (Shift-Normalization)
- `RES_A [31:0] = (P1 + SURD_TERM) >> 16`
- `RES_B [31:0] = (P3 + P4) >> 16`

### 2. Normalization Gate (SNORM)
The `SNORM` gate provides overflow protection by monitoring register state.

#### 2.1 Trigger Logic
- `TRIGGER = (REG_A[30] ^ REG_A[31]) | (REG_B[30] ^ REG_B[31])`
- *Explanation:* Triggers if the 30th bit differs from the sign bit (indicating value exceeds $2^{29}$).

#### 2.2 Operation
- `IF TRIGGER == 1`:
    - `REG_A_OUT = REG_A >> 1`
    - `REG_B_OUT = REG_B >> 1`
- `ELSE`:
    - `REG_A_OUT = REG_A`
    - `REG_B_OUT = REG_B`

### 3. High-Symmetry Permutators (SPERM)
The SPU-1 implements basis shifts as zero-latency wire-swaps.

#### 3.1 SPERM_X4 (4D Prime Projection)
- **Mapping:** $\{Q_1, Q_2, Q_3, Q_4\}$ basis shifts based on Dr. Thomson's v2.0 table.
- **Hardware Path:** `hardware/verilog/spu_permute.v`

#### 3.2 SPERM_13 (13D Aperiodic Growth) [RESTRICTED]
- **Mapping:** 13-axis cyclic shuffle $\{Q_1..Q_{13}\} \rightarrow \{Q_2..Q_{13}, Q_1\}$.
- **Hardware Path:** `hardware/restricted/spu_permute_11.v` (Expandable to 13).
- **Safety Note:** This instruction is air-gapped from the primary spatial core.

### 4. Quadray Bus Architecture
The SPU-1 architecture supports three primary bus widths:
*   **Spatial Bus (256-bit):** 4 Lanes x 64-bit. Optimized for 3D/4D spatial transforms.
*   **High-Dimensional Bus (704-bit):** 11 Lanes x 64-bit. (SPU-11).
*   **Phi-Core Bus (832-bit):** 13 Lanes x 64-bit. (SPU-13).

### 5. RTL Implementation (Verilog)
The functional logic for this specification is implemented in the following modules:
*   **`hardware/verilog/spu_smul.v`**: The Surd Multiplier Unit.
*   **`hardware/verilog/spu_permute.v`**: The SPERM_X4 Unit.
*   **`hardware/verilog/spu_tensegrity_balancer.v`**: The Lattice Relaxation Unit.
*   **`hardware/verilog/spu_damper.v`**: The Rational Damper (A-Domain Step-Down).
*   **`hardware/verilog/spu_ecc.v`**: SECDED ECC Protection.
*   **`hardware/verilog/spu_core.v`**: The Integrated SPU-1 Unit.

#### 5.1 Opcode Specification (v2.4.3)
| Opcode | Mnemonic | Hardware Path | Latency | Description |
| :--- | :--- | :--- | :--- | :--- |
| `001` | **`SPERM_X4`** | `spu_permute` | 0 Cycles | 4D Prime-Axis Basis Shift. |
| `010` | **`SMUL`** | `spu_smul` | 1 Cycle | Surd multiplication (Integer ALU). |
| `011` | **`EQUILIBRATE`** | `spu_tensegrity_balancer` | 5 Cycles | Pipelined Discrete Laplacian Relaxation. |
| `100` | **`OP_DAMP`** | `spu_damper` | 1 Cycle | Rational Damper (A-Domain Step-Down). |
| `101` | **`OP_CLAMP`** | `spu_core` | 0 Cycles | Dimension-Clamp safety gate. |
| `110` | **`SPERM_13`** | `spu_permute_13`| 0 Cycles | 13-Axis Aperiodic Shuffle [RESTRICTED]. |
| `000` | `NOP` | Bypass | 0 Cycles | No operation. |

### 6. Kinetic Acceleration & Equilibrium
... (existing content) ...

### 11. High-Dimensional Extension (SPU-13)
The SPU-1 architecture is extensible to the **Prime-13 basis**, aligning hardware logic gates with 13-dimensional topological symmetries and aperiodic growth.

#### 11.1 SPU-13 Register Map (832-bit)
A single SPU-13 register packs 13 symmetric axes into a 832-bit block, optimized for high-dimensional data folding and biological simulation.

#### 11.2 Dimension-Clamp (OP_CLAMP)
Default State = `CLAMP 4`. Restricts active pathways to the 4-axis spatial basis ($Q_1 \dots Q_4$) to prevent cognitive load and high-velocity switching noise.

### 12. Mandatory Physical Safety (Hardware-Level)
To ensure the protection of both the hardware fabric and the human observer, all SPU-13 compliant implementations MUST include the following physical safeguards.

#### 12.1 Optical Safety Governor
All high-dimensional projections (7D+) sent to an optical display MUST be processed by a non-optional **16x Anti-Aliasing (DSS)** and **Motion Blur** stage. This ensures that the infinite sharpness of the algebraic core is perceptually dampened to prevent neurological disorientation.

#### 12.2 Display Dimensionality Cap
The hardware must implement a hard-wired **DISPLAY_CLAMP**. While the core may compute in 13 dimensions, the optical output boundary is physically restricted to a maximum projection of 7 axes. 13D visualization is strictly prohibited in real-time hardware.

#### 12.3 Thermal Runaway Detection
Operating in 13D Prime-Axis mode creates significant switching activity. The silicon must include integrated thermal sensors that trigger a global **ASIC_HALT** if temperature or power-draw exceed pre-defined safety envelopes.

#### 12.4 Physical Kill-Switch
Compliant SPU-13 hardware must provide an external, high-priority **GPIO Interrupt (Panic Button)**. This physical switch bypasses all software control to force an immediate `HALT` and register zero-out.
