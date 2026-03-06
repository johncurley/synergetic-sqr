#ifndef SPU_LATTICE_LOCK_HPP
#define SPU_LATTICE_LOCK_HPP

#include "spu/SynergeticsMath.hpp"

namespace Synergetics {
namespace Security {

struct LatticeLock {
    static inline Quadray4 Lock(Quadray4 data, int curvature_key) {
        return Quadray4::_spu_sperm_x4(data, curvature_key % 4);
    }
    static inline Quadray4 Unlock(Quadray4 locked_data, int curvature_key) {
        int key = curvature_key % 4;
        int reciprocal_key = (key == 1) ? 2 : (key == 2) ? 1 : key;
        return Quadray4::_spu_sperm_x4(locked_data, reciprocal_key);
    }
};

} // namespace Security
} // namespace Synergetics

#endif
