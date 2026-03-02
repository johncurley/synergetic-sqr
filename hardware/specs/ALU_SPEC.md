# ALU Specification: SPU-1 (SQR-ASIC)
## Gate-Level Logic for DQFA Operations (v2.3.3)

This document specifies the Register Transfer Level (RTL) requirements for the SPU-1 Arithmetic Logic Unit and its High-Dimensional extensions.

### 1. Surd Multiplier Unit (SMUL)
The `SMUL` unit calculates the product of two elements in $\mathbb{Q}(\sqrt{3})$.

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

#### 3.2 SPERM_11 (11D Topological Folding)
- **Mapping:** 11-axis cyclic shuffle $\{Q_1..Q_{11}\} \rightarrow \{Q_2..Q_{11}, Q_1\}$.
- **Hardware Path:** `hardware/verilog/spu_permute_11.v`

### 4. Quadray Bus Architecture
The SPU-1 architecture supports two primary bus widths:
*   **Spatial Bus (256-bit):** 4 Lanes x 64-bit. Optimized for 3D/4D spatial transforms.
*   **High-Dimensional Bus (704-bit):** 11 Lanes x 64-bit. Optimized for Prime-11 symmetry and topological data folding.

### 5. RTL Implementation (Verilog)
The functional logic for this specification is implemented in the following modules:
*   **`hardware/verilog/spu_smul.v`**: The Surd Multiplier Unit.
*   **`hardware/verilog/spu_permute.v`**: The SPERM_X4 Unit.
*   **`hardware/verilog/spu_permute_11.v`**: The SPERM_11 Unit.
*   **`hardware/verilog/spu_tensegrity_balancer.v`**: The Lattice Relaxation Unit.
*   **`hardware/verilog/spu_damper.v`**: The Rational Damper (A-Domain Step-Down).
*   **`hardware/verilog/spu_ecc.v`**: SECDED ECC Protection.
*   **`hardware/verilog/spu_core.v`**: The Integrated SPU-1 Unit.

#### 5.1 Opcode Specification (v2.3.3)
| Opcode | Mnemonic | Hardware Path | Latency | Description |
| :--- | :--- | :--- | :--- | :--- |
| `001` | **`SPERM_X4`** | `spu_permute` | 0 Cycles | 4D Prime-Axis Basis Shift. |
| `010` | **`SMUL`** | `spu_smul` | 1 Cycle | Surd multiplication (Integer ALU). |
| `011` | **`EQUILIBRATE`** | `spu_tensegrity_balancer` | 5 Cycles | Pipelined Discrete Laplacian Relaxation. |
| `100` | **`OP_DAMP`** | `spu_damper` | 1 Cycle | Rational Damper (A-Domain Step-Down). |
| `101` | **`OP_CLAMP`** | `spu_core` | 0 Cycles | Dimension-Clamp safety gate. |
| `110` | **`SPERM_11`** | `spu_permute_11` | 0 Cycles | 11-Axis Topological Folding. |
| `000` | `NOP` | Bypass | 0 Cycles | No operation. |

### 6. Kinetic Acceleration & Equilibrium
The SPU-1 includes a parallel **Tensegrity Balancer** for hardware-level physics solving. 

#### 6.1 Precision Contract (Signal Integrity)
To eliminate bit-width overflow and maintain stability during lattice relaxation, the balancer implements the following constraints:
*   **Headroom:** 64-bit signed accumulators per lane (28-bit safety margin).
*   **Scaling ($\alpha = 1/16$):** Power-of-two stability approximation.
*   **Deterministic Bias:** Arithmetic right-shifting rounds toward $-\infty$.

#### 6.2 Atomic Pipelined Sync
*   **Pipelined Reduction:** 4 clocked stages for high-frequency timing closure.
*   **Double-Buffered Commit:** Ping-Pong registers for lock-free parallel execution.

### 7. Reliability & Self-Healing
The core includes **SECDED ECC** protection for all 32-bit lane coefficients. High-dimensional lattices (SPU-11) enable **Lattice-Native Error Correction** by utilizing the high packing density of the 11D symmetry to identify and correct bit corruption.

---
*Status: FORMALIZED. Verified for Prime-11 High-Dimensional Parity.*
