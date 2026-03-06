# The Janus-Bit Manifesto
## Field Reciprocation and the Sign of the Surd

### 1. The Dual Nature of the Field
In the SPU-1 architecture, every spatial coordinate is an element of the quadratic field extension $\mathbb{Q}(\sqrt{3})$. This is represented as a rational pair $(a + b\sqrt{3}) / d$. While standard computing treats these as a single magnitude, the SPU-1 recognizes them as two distinct but reciprocating components.

### 2. The Janus Bit (J-Bit)
The **Janus Bit** is a hardware-level control primitive that toggles the sign of the surd component ($b$). 
*   **Operation:** $	ext{Janus}(a, b) ightarrow (a, -b)$
*   **Hardware Implementation:** A single XOR gate applied to the sign-bit of the surd register.

### 3. Geometric Reciprocation
Following the insights of Ken Wheeler and the geometry of the hyperboloid, the Janus Bit represents the reciprocation between the **Dielectric (Centripetal)** and **Magnetic (Centrifugal)** aspects of the field.
*   **Positive Surd:** Projective expansion toward the tetrahedral vertices.
*   **Negative Surd:** Reflective contraction toward the isotropic center.

### 4. Algebraic Closure
The Janus Bit is not just a physical metaphor; it is an algebraic requirement for **Involution**. Applying the Janus flip twice returns the system to its exact starting bitmask. This ensures that the engine can model reflections and "inside-out" transitions (like the Jitterbug) without losing bit-exact identity.

### 5. Why it Matters
By isolating the "Sign of the Surd" into a dedicated hardware bit, the SPU-1 achieves:
1.  **Zero-Drift Reflection:** Mirrored states are bit-identical to their sources.
2.  **Field Polarity Control:** Instantaneous switching between expansive and contractive states.
3.  **Projective Determinism:** The ability to move "through" the origin (the Janus Point) with absolute precision.

---
*Status: FORMALIZED. The field is in balance.*
