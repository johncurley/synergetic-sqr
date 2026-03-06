#ifndef SYNERGETIC_SDK_HPP
#define SYNERGETIC_SDK_HPP

#include "spu/SynergeticsMath.hpp"
#include <vector>
#include <algorithm>

namespace Synergetics {
namespace SDK {

struct PathC_Hull {
    static inline int64_t IsotropicCrossProduct(Quadray4 a, Quadray4 b, Quadray4 p) {
        int64_t x1 = (int64_t)b.data.v[0] - a.data.v[0];
        int64_t y1 = (int64_t)b.data.v[2] - a.data.v[2];
        int64_t z1 = (int64_t)b.data.v[4] - a.data.v[4];
        int64_t x2 = (int64_t)p.data.v[0] - a.data.v[0];
        int64_t y2 = (int64_t)p.data.v[2] - a.data.v[2];
        int64_t z2 = (int64_t)p.data.v[4] - a.data.v[4];
        int64_t cx = y1 * z2 - z1 * y2;
        int64_t cy = z1 * x2 - x1 * z2;
        int64_t cz = x1 * y2 - y1 * x2;
        return (cx * cx) + (cy * cy) + (cz * cz);
    }
    static std::vector<Quadray4> GenerateHull(const std::vector<Quadray4>& cloud) {
        if (cloud.size() <= 4) return cloud;
        std::vector<Quadray4> hull;
        auto anchor = *std::min_element(cloud.begin(), cloud.end(), [](const Quadray4& a, const Quadray4& b) { return a.data.v[0] < b.data.v[0]; });
        hull.push_back(anchor);
        Quadray4 last = anchor;
        bool closed = false;
        while (!closed) {
            Quadray4 next = cloud[0];
            for (const auto& p : cloud) {
                if (p.equals(last)) continue;
                if (IsotropicCrossProduct(last, next, p) > 0) next = p;
            }
            if (next.equals(anchor)) closed = true;
            else { hull.push_back(next); last = next; }
            if (hull.size() > cloud.size()) break;
        }
        return hull;
    }
};

struct PhiNode {
    SurdFixed128 coordinate;
    static PhiNode Create(int32_t a, int32_t b, int32_t c, int32_t d) { return { {a, b, c, d} }; }
    void GrowthStep(const PhiNode& other) { coordinate = SurdFixed128::multiply(coordinate, other.coordinate); }
};

struct ArticulatedJoint {
    Quadray4 local_pos;
    int phase; 
    void Rotate(int steps) { phase = (phase + steps) % 4; local_pos = Quadray4::_spu_sperm_x4(local_pos, phase); }
};

struct KinematicChain {
    std::vector<ArticulatedJoint> joints;
    void AddJoint(Quadray4 offset) { joints.push_back({ offset, 0 }); }
    Quadray4 CalculateEndEffector() {
        Quadray4 result = { {0, 0, 0, 0, 0, 0, 0, 0} };
        for (const auto& j : joints) result = Quadray4::_spu_add_q4(result, j.local_pos);
        return result;
    }
};

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
