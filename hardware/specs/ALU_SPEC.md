# ALU Specification: SPU-1 (SQR-ASIC)
## Gate-Level Logic for DQFA Operations

This document specifies the Register Transfer Level (RTL) requirements for the SPU-1 Arithmetic Logic Unit.

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

### 3. Permutator (SPERM)
The 60° rotation is a pure routing operation.

#### 3.1 Q4 Axis Rotation
- `OUT_Q1 = REG_Q2`
- `OUT_Q2 = REG_Q3`
- `OUT_Q3 = REG_Q1`
- `OUT_Q4 = REG_Q4`
- *Hardware Complexity:* Zero logic gates (wiring permutation).

### 4. Quadray Bus Architecture
The SPU-1 utilizes a **256-bit Parallel Quadray Bus**. 
- 4 Lanes x 64-bit per lane.
- Single-cycle dispatch for `SADD` and `SPERM`.
- Pipelined execution for `SMUL`.

### 5. RTL Implementation (Verilog)
The functional logic for this specification is implemented in the following modules:
*   **`hardware/verilog/spu_smul.v`**: The Surd Multiplier Unit.
*   **`hardware/verilog/spu_permute.v`**: The Zero-Gate Permutator.
*   **`hardware/verilog/spu_core.v`**: The Top-Level Register Stage.

#### 5.1 Opcode Specification (v2.0)
| Opcode | Mnemonic | Hardware Path | Latency | Description |
| :--- | :--- | :--- | :--- | :--- |
| `01` | **`SPERM_X4`** | `spu_permute` | 0 Cycles | **High-Symmetry Mode:** 4D Prime-Axis Basis Shift. |
| `10` | **`SMUL`** | `spu_smul` | 1 Cycle | Surd multiplication (Integer ALU). |
| `11` | **`OP_EQUILIBRATE`** | `spu_tensegrity_balancer` | 5 Cycles | Pipelined Discrete Laplacian Relaxation. |
| `00` | `NOP` | Bypass | 0 Cycles | No operation. |

### 6. High-Symmetry Performance Logic
The **`SPERM_X4`** instruction implements Dr. Thomson’s 4D Prime Projection as a pure routing operation. 
*   **Zero-Latency:** Because no logic gates are required, basis shifts are instantaneous and consume zero switching power.
*   **Identity Restoration:** The system guarantees 100% bit-exact identity restoration at every 60° (or 360°) rotational increment, eliminating cumulative rounding drift.

### 6. Kinetic Acceleration & Equilibrium
The SPU-1 includes a parallel **Tensegrity Balancer** for hardware-level physics solving. 

#### 6.1 Precision Contract (Signal Integrity)
To eliminate bit-width overflow and maintain stability during lattice relaxation, the balancer implements the following constraints:
*   **Headroom:** Utilizing 64-bit signed accumulators per lane exceeds the theoretical maximum width for 12-neighbor summation ($\lceil \log_2(12) \rceil = 4$ bits) by over 28 bits of margin.
*   **Scaling ($\alpha = 1/16$):** The output correction is scaled by a power-of-two approximation ($1/16$) of the ideal Laplacian average ($1/12$). This conservative scaling improves the spectral stability of the relaxation step.
*   **Deterministic Bias:** Arithmetic right-shifting (`>>>`) introduces a deterministic truncation bias toward negative infinity ($-\infty$). While negligible in balanced lattices, this bias is documented as a machine-invariant property of the SPU-1.
*   **Operator Form:** The balancer implements the discrete Laplacian $\sum_{j \in N(i)} (u_j - u_i)$, where the input bus carries relational displacements.

#### 6.2 Atomic Pipelined Sync
To ensure deterministic results in massively parallel lattices, the SPU-1 implements the following synchronization primitives:
*   **Pipelined Reduction:** The 12-neighbor summation is pipelined over 4 clocked stages to ensure timing closure at high frequencies (target: 500MHz+). Each stage breaks the logic depth to a maximum of 3 serialized additions.
*   **Double-Buffered Commit:** State updates utilize a Ping-Pong register scheme. Nodes read from a stable snapshot (Bank A) and commit to a separate dormant bank (Bank B), eliminating race conditions between adjacent nodes.

### 7. Systolic Lattice Scaling (SPU-Cluster)
The SPU-1 is designed for massive parallelization via **Topological Tiling**. Individual cores are arranged in an IVM-compliant grid to form an SPU-Cluster.

#### 7.1 Shared-Nothing Architecture
Unlike von Neumann architectures, SPU clusters utilize a **Shared-Nothing Data Flow**:
*   **Private State:** Each core maintains its own Quadray register and ECC logic.
*   **Read-Only Adjacency:** Cores access neighbor states via a dedicated 12-neighbor bus without bus arbitration or memory locking.
*   **No Cache Coherency:** Because nodes only interact with topological neighbors, the "Cache Invalidation" problem is physically non-existent.

#### 7.2 Global Synchronous Breath
Parallel synchronization is enforced by the global clock cycle and dual-bank registers:
1.  **Read Phase:** All cores sample Bank A neighbor states.
2.  **Compute Phase:** Pipelined logic (SMUL/EQUILIBRATE) executes.
3.  **Commit Phase:** All cores write results to Bank B.
4.  **Bank Swap:** The global tick toggles the active bank.

This mechanism ensures that the entire lattice remains bit-perfectly synchronized across millions of independent compute units, enabling deterministic simulation at planetary scales.
