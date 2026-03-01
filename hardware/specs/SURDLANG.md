# SurdLang Language Specification (v1.10)
## The Language of Deterministic Spatial Computation

### 1. Introduction
SurdLang is a domain-specific instruction set architecture (ISA) designed for the **SPU-1** (Synergetic Processing Unit). It provides a bit-exact, hardware-realizable framework for spatial transformations over the quadratic field $\mathbb{Q}(\sqrt{3})$.

### 2. Machine Model
The SPU-1 is a 256-bit SIMD architecture. Its state is defined by a bank of high-width registers, each capable of holding a single 4-axis Quadray coordinate.

#### 2.1 The Quadray Register
A standard SPU register is 256 bits wide, divided into four 64-bit **Lanes**. Each lane stores a `SurdFixed64` element.

| Lane | Bits | Basis Axis |
| :--- | :--- | :--- |
| **L0** | [63:0] | $Q_1$ |
| **L1** | [127:64] | $Q_2$ |
| **L2** | [191:128] | $Q_3$ |
| **L3** | [255:192] | $Q_4$ |

#### 2.2 The `SurdFixed64` Lane Format
Each 64-bit lane is a pair of signed 32-bit integers $[a, b]$, representing the value:
$$v = \frac{a + b\sqrt{3}}{2^{16}}$$

### 3. Instruction Set Architecture (ISA)

#### 3.1 Arithmetic Instructions
| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0x01` | **`SADD`** | $R_d \leftarrow R_{s1} + R_{s2}$ | SIMD parallel integer addition of all 8 sub-components. |
| `0x02` | **`SSUB`** | $R_d \leftarrow R_{s1} - R_{s2}$ | SIMD parallel integer subtraction. |
| `0x03` | **`SMUL`** | $R_d \leftarrow R_{s1} \otimes R_{s2}$ | Pipelined surd multiplication with 16-bit shift-normalization. |

#### 3.2 Geometric Instructions
| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0x10` | **`SPERM`** | $R_d \leftarrow \text{Shuffle}(R_{s1})$ | 60° rotation implemented as a Zero-Gate register permutation. |
| `0x11` | **`JINV`** | $R_d \leftarrow \text{XOR}(R_{s1}, \text{SignBit})$ | Janus bit toggle; inverts the sign of the surd component $b$. |

#### 3.3 System Instructions
| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0xF0` | **`SNORM`** | $R_d \leftarrow \text{Normalize}(R_{s1})$ | Fixed-point scaling; arithmetic right-shift if 30th bit is set. |
| `0xFF` | **`HALT`** | Stop execution | Terminate current SPU pipeline cycle. |

### 4. Mathematical Behavior (Semantics)

#### 4.1 SMUL Detail
The multiplication of two lanes $u[a_1, b_1]$ and $v[a_2, b_2]$ is defined as:
1.  $temp\_a = (a_1 \cdot a_2) + 3(b_1 \cdot b_2)$
2.  $temp\_b = (a_1 \cdot b_2) + (b_1 \cdot a_2)$
3.  $res\_a = \text{Truncate32}(temp\_a \gg 16)$
4.  $res\_b = \text{Truncate32}(temp\_b \gg 16)$

#### 4.2 SPERM Detail (Q4-Axis Rotation)
A 60° rotation around the $Q_4$ axis is a direct wire-swap:
*   $L0_{out} = L1_{in}$
*   $L1_{out} = L2_{in}$
*   $L2_{out} = L0_{in}$
*   $L3_{out} = L3_{in}$

### 5. Deterministic Contract
All SurdLang implementations must guarantee:
1.  **Bit-Exact Parity:** The output of `spu-verify` must be identical on all platforms.
2.  **Overflow Wrap:** Signed integer overflow must follow 2's complement wrapping.
3.  **Normalization Invariance:** `SNORM` must preserve the rational ratio $a/b$ within 1 bit of precision.

---
*Status: FORMALIZED. Verified by DQFA Identity 0x10000.*
