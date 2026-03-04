#ifndef SPU_LATTICE_LOCK_HPP
#define SPU_LATTICE_LOCK_HPP

#include "spu/SynergeticsMath.hpp"

namespace Synergetics {
namespace Security {

/**
 * LatticeLock: Geometric Encryption via Isotropic Basis Folding.
 * Encrypts data by 'folding' it into a specific prime-axis manifold.
 */
struct LatticeLock {
    
    /**
     * Lock: Folds a spatial coordinate into an encrypted high-D state.
     */
    static inline Quadray4 Lock(Quadray4 data, int curvature_key) {
        return Quadray4::_spu_sperm_x4(data, curvature_key % 4);
    }

    /**
     * Unlock: Unfolds the data using the explicit reciprocal basis.
     * Reciprocity Mapping:
     * 0 (P1) -> 0
     * 1 (P3) -> 2 (P5)
     * 2 (P5) -> 1 (P3)
     * 3 (P7) -> 3 (Self-Reciprocal)
     */
    static inline Quadray4 Unlock(Quadray4 locked_data, int curvature_key) {
        int key = curvature_key % 4;
        int reciprocal_key = 0;
        if (key == 1) reciprocal_key = 2;
        else if (key == 2) reciprocal_key = 1;
        else if (key == 3) reciprocal_key = 3;
        
        return Quadray4::_spu_sperm_x4(locked_data, reciprocal_key);
    }
};

} // namespace Security
} // namespace Synergetics

#endif
