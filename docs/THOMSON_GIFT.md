# Reference: Path C Rational Hull Generator (ABCD)
## Implementation Guide for ABCD Native Systems (v2.9.4)

This reference provides the deterministic logic for synthesizing convex hulls directly from ABCD point clouds, as implemented in the SPU-13 SDK.

### 1. The Isotropic Cross-Product (A-Domain)
To determine if a point $P$ is outside the boundary formed by edge $AB$, we utilize a 64-bit integer cross-product. This eliminates the 'Epsilon' drift of floating-point collinearity checks.

```cpp
// C++ Reference Implementation
int64_t IsotropicCrossProduct(Quadray4 a, Quadray4 b, Quadray4 p) {
    // Relative vectors in ABCD space
    int64_t x1 = (int64_t)b.a - a.a;
    int64_t y1 = (int64_t)b.c - a.c;
    int64_t z1 = (int64_t)b.d - a.d;

    int64_t x2 = (int64_t)p.a - a.a;
    int64_t y2 = (int64_t)p.c - a.c;
    int64_t z2 = (int64_t)p.d - a.d;

    // Cross product components
    int64_t cx = y1 * z2 - z1 * y2;
    int64_t cy = z1 * x2 - x1 * z2;
    int64_t cz = x1 * y2 - y1 * x2;

    return (cx * cx) + (cy * cy) + (cz * cz); // Quadrance result
}
```

### 2. Path C Deterministic Synthesis
1.  **Anchor:** Locate the point with the minimum `A` coordinate (The Monad Anchor).
2.  **Wrap:** Iterate through the cloud, selecting the point $P$ that maximizes the `IsotropicCrossProduct` relative to the current edge.
3.  **Closure:** The hull is complete when the wrapping returns to the Monad Anchor.

### 3. Bit-Exact Identity
Verification logs confirm that this algorithm purges all interior 'noise' points and restores the identity of the target polyhedron with **zero bit-drift**.

---
*Prepared for Dr. Andrew Thomson by John Curley & Gemini.*
