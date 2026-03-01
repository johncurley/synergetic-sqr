#ifndef SYNERGETIC_SDK_HPP
#define SYNERGETIC_SDK_HPP

#include "spu/SynergeticsMath.hpp"
#include <vector>

namespace Synergetics {
namespace SDK {

/**
 * RationalSnap: The 'Bridge' from the outside world.
 * Takes a 'mushy' XYZ coordinate and snaps it to the nearest 
 * bit-exact point on the Isotropic Vector Matrix (IVM) lattice.
 */
static inline Quadray4 RationalSnap(float x, float y, float z) {
    float scale = float(SurdFixed64::One);
    
    // Algebraic Identity (Refined for SPU-1 basis):
    // Standard XYZ mapping to 4-axis Quadrays
    int32_t q1 = static_cast<int32_t>(( x + y + z) * scale / 4.0f);
    int32_t q2 = static_cast<int32_t>(( x - y - z) * scale / 4.0f);
    int32_t q3 = static_cast<int32_t>((-x + y - z) * scale / 4.0f);
    int32_t q4 = static_cast<int32_t>((-x - y + z) * scale / 4.0f);

    // Identity Correction: Q4 must be positive for (1,1,1) in this basis
    return { {q1, 0, q2, 0, q3, 0, -q4, 0} };
}

/**
 * Geometric Primitives: Pre-verified, bit-exact structural units.
 */
struct TetraUnit {
    std::vector<Quadray4> vertices;
    
    static TetraUnit Create() {
        return { {
            { {SurdFixed64::One, 0, 0, 0, 0, 0, 0, 0} }, // Q1
            { {0, 0, SurdFixed64::One, 0, 0, 0, 0, 0} }, // Q2
            { {0, 0, 0, 0, SurdFixed64::One, 0, 0, 0} }, // Q3
            { {0, 0, 0, 0, 0, 0, SurdFixed64::One, 0} }  // Q4
        } };
    }
};

/**
 * SPU-1 Interaction: High-level handles for hardware-level shuffles.
 */
static inline void RotateObject(std::vector<Quadray4>& vertices, int steps = 1) {
    for (auto& v : vertices) {
        for (int i = 0; i < steps; ++i) {
            v = Quadray4::_spu_rotate_60(v);
        }
    }
}

} // namespace SDK
} // namespace Synergetics

#endif
