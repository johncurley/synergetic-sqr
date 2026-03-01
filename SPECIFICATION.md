# SPU-1 Architecture Specification (v1.7)
## Deterministic Synergetic Processing Unit

### 1. Architectural Overview
The SPU-1 is a virtual processor specification designed for bit-exact spatial computation. It rejects IEEE-754 floating-point approximations in favor of **Deterministic Quadratic Field Arithmetic (DQFA)**. The architecture is centered around 4-axis tetrahedral coordinates (Quadrays) and algebraic field extensions.

### 2. Register Specification
The SPU-1 defines 256-bit wide registers, each subdivided into four 64-bit algebraic "Lanes."

| Register Component | Width | Format | Description |
| :--- | :--- | :--- | :--- |
| **Q1 - Q4** | 64-bit | $SF_{32.16}$ | 4-Axis Quadray basis |
| **Lane Sub-Format** | 32-bit (x2) | `int32_t` | $[a, b]$ where $v = (a + b\sqrt{3}) / 2^{16}$ |

#### 2.1 Fixed-Point Format ($SF_{32.16}$)
Each lane represents a value in the quadratic field extension $\mathbb{Q}(\sqrt{3})$:
$$X = \frac{a + b\sqrt{3}}{2^{16}}$$
Where $a, b \in \mathbb{Z} \cap [-2^{31}, 2^{31}-1]$.

### 3. Instruction Set Architecture (ISA)

#### 3.1 Arithmetic Instructions
*   **`SADD` (Surd Add):** Vector addition of two 256-bit registers. Bit-exact parallel integer addition of all 8 sub-components ($a_i, b_i$).
*   **`SMUL` (Surd Multiply):** Multiplies two surd elements. Uses 64-bit intermediates to prevent overflow before bit-shifting.
    - $A_{out} = (a_1 a_2 + 3 b_1 b_2) \gg 16$
    - $B_{out} = (a_1 b_2 + b_1 a_2) \gg 16$
    - *Optimization:* Multiplication by 3 is implemented as $(x \ll 1) + x$.
*   **`SNORM` (Surd Normalize):** Monitors the 30th bit of coefficients. If triggered, performs a simultaneous arithmetic right-shift (`>> 1`) on $a$ and $b$ to preserve rational ratios within 32-bit bounds. 
    - *Precision Floor:* A hardware-level safeguard (threshold: 256) prevents normalization if precision would be lost, ensuring state stability under repeated scaling.
    - *Vector/Matrix Lanes:* Normalization propagates across all lanes in 256-bit registers to maintain structural symmetry.

#### 3.2 Geometric Instructions
*   **`SPERM` (SQR Permute):** Implements 60° rotations as zero-cycle register shuffles.
    - Rotation around $Q_4$ axis: $\{Q_1, Q_2, Q_3, Q_4\} ightarrow \{Q_2, Q_3, Q_1, Q_4\}$.
*   **`JINV` (Janus Involution):** Performs a sign-bit XOR on the surd component $b$, toggling the projective polarity.

### 4. Deterministic Contract
To ensure machine-invariant results across all implementations, the SPU-1 enforces the following constraints:
1.  **Two's Complement:** All signed integer arithmetic must follow two's complement behavior.
2.  **Deterministic Downcasting:** 64-to-32 bit conversion must use bitwise wrapping (truncation) rather than saturation or implementation-defined behavior.
3.  **Field Invariant:** The quadratic norm $N(a, b) = a^2 - 3b^2$ must be preserved under rotation (subject to scaling factors).

### 5. Compliance Verification
Implementations are considered SPU-1 compliant only if they pass the **Rigorous Verification Suite**, which mandates bit-exact identity after $10^8$ operations and consistent normalization across 11+ cycles.

---
*Status: FORMALIZED. Verified by DQFA Identity 0x10000.*
