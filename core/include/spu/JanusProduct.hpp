#ifndef SPU_JANUS_PRODUCT_HPP
#define SPU_JANUS_PRODUCT_HPP

#include "spu/SynergeticsMath.hpp"

namespace Synergetics {
namespace Core {

/**
 * JanusProduct: The Primary Isotropic Rotor for Q(sqrt5).
 * Implements the reciprocal field pairing required for zero-drift rotation.
 */
struct JanusProduct {
    
    /**
     * Compute: Performs the Janus-reciprocal multiplication.
     * Logic: Pairing the Phi-field with its Galois conjugate (Psi).
     */
    static inline SurdFixed128 Compute(SurdFixed128 state, SurdFixed128 rotor) {
        // 1. Forward Transformation (Phenomena)
        SurdFixed128 forward = SurdFixed128::multiply(state, rotor);
        
        // 2. Reciprocal Alignment (Agnosia)
        SurdFixed128 reciprocal = rotor.janusFlip();
        
        // 3. Henosis: Restoration of Identity
        return SurdFixed128::multiply(forward, reciprocal);
    }
};

} // namespace Core
} // namespace Synergetics

#endif
