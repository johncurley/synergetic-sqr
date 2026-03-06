#ifndef SPU_TROJAN_CORE_HPP
#define SPU_TROJAN_CORE_HPP

#include "spu/SynergeticsMath.hpp"

namespace Synergetics {
namespace Trojan {

enum class CoordMode { XYZ_Legacy, R6_Native };

struct TrojanCore {
    static inline Quadray4 Resolve(Quadray4 native_r6, CoordMode active_mode, double& tax_out) {
        if (active_mode == CoordMode::XYZ_Legacy) { tax_out += 0.0000001; return native_r6; }
        else { tax_out = 0.0; return native_r6; }
    }
    static inline double GetVd(double tax) { return 1.0 - tax; }
};

} // namespace Trojan
} // namespace Synergetics

#endif
