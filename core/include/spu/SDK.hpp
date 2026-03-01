#ifndef SYNERGETIC_SDK_HPP
#define SYNERGETIC_SDK_HPP

#include "spu/SynergeticsMath.hpp"
#include <vector>
#include <map>

namespace Synergetics {
namespace SDK {

/**
 * Bond: A structural identity between two nodes.
 * Enforces the Isotropic Vector Matrix (IVM) connectivity.
 */
struct Bond {
    int32_t a_idx;
    int32_t b_idx;
    int64_t rest_quadrance;
};

/**
 * Lattice: The Honeycomb Memory Map.
 * Manages nodes and bonds with topological isolation.
 */
struct Lattice {
    std::vector<SPU_TensegrityNode> nodes;
    std::vector<Bond> bonds;

    void AddNode(Quadray4 pos) {
        if (pos.checkParity()) {
            nodes.push_back({ pos, pos, {1, 1} });
        }
    }

    void Bind(int32_t i, int32_t j) {
        int64_t q = Quadray4::_spu_quadrance(nodes[i].position, nodes[j].position);
        bonds.push_back({ i, j, q });
    }

    // Step: Performs one deterministic kinetic cycle
    void Step() {
        // 1. Resolve Bonds (Topology-native interaction)
        for (const auto& b : bonds) {
            TensegrityLink link = { b.a_idx, b.b_idx, b.rest_quadrance, 10, LinkType::Tie };
            link.projectConstraint(nodes[b.a_idx], nodes[b.b_idx]);
        }
        // 2. Integration (Verlet)
        Quadray4 g = SPU_TensegrityNode::gravityVector();
        for (auto& n : nodes) {
            SPU_TensegrityNode::_spu_verlet_step(n, g, 1);
        }
    }
};

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
