#ifndef SPU_RESONANCE_BRIDGE_HPP
#define SPU_RESONANCE_BRIDGE_HPP

#include "spu/SynergeticsMath.hpp"
#include <string>
#include <vector>

namespace Synergetics {
namespace Resonance {

struct ResonanceBridge {
    static inline Quadray4 MapToken(uint32_t token_id) {
        int32_t a = (token_id & 0xFFFF);
        int32_t b = ((token_id >> 16) & 0xFFFF);
        return { {a, 0, b, 0, -a, 0, -b, 0} };
    }
    static inline bool VerifyCoherence(Quadray4 data) {
        Quadray4 current = data;
        for (int i = 0; i < 6; ++i) current = Quadray4::_spu_rotate_60(current);
        return current.equals(data);
    }
    static inline Quadray4 DampenResponse(Quadray4 current, Quadray4 target, float zeta) {
        Quadray4 res;
        for (int i = 0; i < 8; ++i) {
            int32_t diff = target.data.v[i] - current.data.v[i];
            res.data.v[i] = current.data.v[i] + static_cast<int32_t>(diff * zeta);
        }
        return res;
    }
};

} // namespace Resonance
} // namespace Synergetics

#endif
