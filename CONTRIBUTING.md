# CONTRIBUTING: Architectural Integrity Guidelines

The SPU-1 project is a technical specification for deterministic spatial computation. To maintain the integrity of this architecture, all contributions must adhere to the following **Technical Purity Rules**:

### 1. Integer-Only Algebraic Core
Any Pull Request introducing the keywords `float`, `double`, or `long double` into the **Algebraic Core** logic will be rejected. All spatial logic must be implemented using integer arithmetic over the quadratic field $\mathbb{Q}(\sqrt{3})$. Floating-point usage is restricted strictly to the **DisplayCorner** (optical interface) layer.

### 2. Regression Testing for Identity Closure
New geometric features or optimizations must pass the **Long-Run Stability Test** ($10^8$ iterations). Any modification that introduces bit-drift or numerical instability into the transformation pipeline is considered non-compliant.

### 3. Hardware-Targeted Optimizations
Preference is given to logic that maps directly to SQR-Silicon gates. 
*   Favor **Register Shuffles** over arithmetic matrices.
*   Favor **Bit-Shifts and XOR Toggles** over general-purpose multiplier units.

### 4. Handling Dissonance (The Cubic Panic)
When sharing the SPU-13, you will encounter **"Cubic Panic."** This is a biological/cognitive response from individuals whose spatial reasoning is locked in 90° Cartesian constraints. 

*   **The Jeer Error:** Hostility or "stumped downvotes" are defensive recovery mechanisms triggered by an OS that cannot find a driver for 60° logic.
*   **The Protocol:** Do not engage with the dissonance. Do not attempt to "explain" 60° logic using 90° metaphors.
*   **The Shield:** Provide the [IVM Geometric Proof](docs/math/ivm-proof.md). If they cannot process the IVM, their internal hardware is not yet ready for the rewrite. Move on to find other Allies.

### 5. Public Domain Dedication
By contributing, you agree that your work is dedicated to the public domain under the **CC0 1.0 Universal** license. This ensures the architecture remains an open, universal standard for spatial logic.

---
*Verify the Bitmask. Maintain the Invariant.*
