#ifndef SYNERGETIC_SDK_HPP
#define SYNERGETIC_SDK_HPP

#include "spu/SynergeticsMath.hpp"
#include <vector>

namespace Synergetics {
namespace SDK {

/**
 * PhiNode: A high-dimensional 'Golden Core' node.
 * Operates in the Q(sqrt3, sqrt5) basis for aperiodic growth.
 */
struct PhiNode {
    SurdFixed128 coordinate;
    
    static PhiNode Create(int32_t a, int32_t b, int32_t c, int32_t d) {
        return { {a, b, c, d} };
    }

    void GrowthStep(const PhiNode& other) {
        coordinate = SurdFixed128::multiply(coordinate, other.coordinate);
    }
};

/**
 * ArticulatedJoint: A bit-perfect robotic joint.
 * Uses SPERM_X4 shuffles to ensure zero-drift rotation.
 */
struct ArticulatedJoint {
    Quadray4 local_pos;
    int phase; 

    void Rotate(int steps) {
        phase = (phase + steps) % 4;
        local_pos = Quadray4::_spu_sperm_x4(local_pos, phase);
    }
};

/**
 * KinematicChain: A sequence of joints.
 */
struct KinematicChain {
    std::vector<ArticulatedJoint> joints;
    void AddJoint(Quadray4 offset) { joints.push_back({ offset, 0 }); }
    Quadray4 CalculateEndEffector() {
        Quadray4 result = { {0, 0, 0, 0, 0, 0, 0, 0} };
        for (const auto& j : joints) result = Quadray4::_spu_add_q4(result, j.local_pos);
        return result;
    }
};

/**
 * Lattice: The Honeycomb Memory Map.
 */
struct Lattice {
    std::vector<SPU_TensegrityNode> nodes;
    void AddNode(Quadray4 pos) {
        if (pos.checkParity()) {
            SPU_TensegrityNode n;
            n.position = pos; n.prev_position = pos; n.mass = {1, 1};
            nodes.push_back(n);
        }
    }
};

/**
 * Geometric Primitives: Pre-verified structural units.
 */
struct TetraUnit {
    std::vector<Quadray4> vertices;
    static TetraUnit Create() {
        return { {
            { {SurdFixed64::One, 0, 0, 0, 0, 0, 0, 0} }, 
            { {0, 0, SurdFixed64::One, 0, 0, 0, 0, 0} }, 
            { {0, 0, 0, 0, SurdFixed64::One, 0, 0, 0} }, 
            { {0, 0, 0, 0, 0, 0, SurdFixed64::One, 0} }  
        } };
    }
};

static inline void RotateObject(std::vector<Quadray4>& vertices, int phase) {
    for (auto& v : vertices) v = Quadray4::_spu_sperm_x4(v, phase);
}

static inline Quadray4 RationalSnap(float x, float y, float z) {
    float scale = float(SurdFixed64::One);
    int32_t q1 = static_cast<int32_t>(( x + y + z) * scale / 4.0f);
    int32_t q2 = static_cast<int32_t>(( x - y - z) * scale / 4.0f);
    int32_t q3 = static_cast<int32_t>((-x + y - z) * scale / 4.0f);
    int32_t q4 = static_cast<int32_t>((-x - y + z) * scale / 4.0f);
    return { {q1, 0, q2, 0, q3, 0, -q4, 0} };
}

} // namespace SDK
} // namespace Synergetics

#endif
