#ifndef SPU_TROJAN_CORE_HPP
#define SPU_TROJAN_CORE_HPP

#include "spu/SynergeticsMath.hpp"
#include <iostream>
#include <cmath>

namespace Synergetics {
namespace Trojan {

enum class CoordMode { XYZ_Legacy, R6_Native };

/**
 * TrojanCore: The Dual-Mode SPU-13 Interface.
 * Provides legacy XYZ compliance while exposing the real-time 'Cubic Tax'.
 */
struct TrojanCore {
    CoordMode mode = CoordMode::R6_Native;
    double cubic_tax = 0.0;

    /**
     * Coordinate Resolution: Calculates the spatial state based on active mode.
     * Logic: XYZ mode introduces rounding; R6 mode instantiates Identity.
     */
    static inline Quadray4 Resolve(Quadray4 native_r6, CoordMode active_mode, double& tax_out) {
        if (active_mode == CoordMode::XYZ_Legacy) {
            // Step-Down: Grind perfect R6 into float64 'bricks'
            // Simulate the 10^-7 precision loss of legacy FPU rounding
            tax_out += 0.0000001; 
            return native_r6; // Return slightly 'dirtied' state in real HW
        } else {
            // Native: Absolute Identity preservation
            tax_out = 0.0;
            return native_r6;
        }
    }

    /**
     * Vd_Monitor: Calculates the Deterministic Velocity (Vd).
     * Vd = 1.0 indicates perfect Henosis; Vd < 1.0 indicates Cubic Friction.
     */
    static inline double GetVd(double tax) {
        return 1.0 - tax;
    }
};

} // namespace Trojan
} // namespace Synergetics

#endif
