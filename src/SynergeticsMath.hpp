#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#include <simd/simd.h>
#include <cmath>
#include <iostream>
#include <stdint.h>
#include <cstring>

namespace Synergetics {

// --- ARCHITECTURAL CONTRACT ---
static_assert(sizeof(int32_t) == 4, "SPU-1 requires 32-bit int32_t");
static_assert(sizeof(int64_t) == 8, "SPU-1 requires 64-bit int64_t");

// --- DISPLAY ADAPTER (Cartesian Corner - Estimations Allowed) ---
namespace DisplayAdapter {
    static constexpr float SQRT3_ESTIMATE = 1.73205081f;
}

// --- SOVEREIGN CORE (Algebraic Identity - Integer Only) ---

static inline int32_t spu_deterministic_cast(int64_t val) {
    return static_cast<int32_t>(static_cast<uint32_t>(static_cast<uint64_t>(val) & 0xFFFFFFFF));
}

struct SurdFixed64 {
    int32_t a, b; 
    static constexpr int32_t Shift = 16;
    static constexpr int32_t One = 1 << Shift;

    static inline SurdFixed64 _spu_surd_mul(SurdFixed64 u, SurdFixed64 v) {
        int64_t prod_bb = (int64_t)u.b * v.b;
        int64_t surd_term = (prod_bb << 1) + prod_bb; 
        int64_t res_a = ((int64_t)u.a * v.a + surd_term) >> Shift;
        int64_t res_b = ((int64_t)u.a * v.b + (int64_t)u.b * v.a) >> Shift;
        return { spu_deterministic_cast(res_a), spu_deterministic_cast(res_b) };
    }

    static inline SurdFixed64 _spu_normalize(SurdFixed64 s) {
        uint32_t mask = 0x40000000;
        if ((static_cast<uint32_t>(s.a) & mask) || (static_cast<uint32_t>(s.b) & mask)) {
            return { s.a >> 1, s.b >> 1 };
        }
        return s;
    }

    int64_t norm() const {
        int64_t la = a; int64_t lb = b;
        return la * la - 3 * lb * lb;
    }

    SurdFixed64 add(const SurdFixed64& other) const { return { a + other.a, b + other.b }; }
    SurdFixed64 subtract(const SurdFixed64& other) const { return { a - other.a, b - other.b }; }
    SurdFixed64 multiply(const SurdFixed64& other) const { return _spu_surd_mul(*this, other); }
    float toFloat() const { return (float(a) + float(b) * DisplayAdapter::SQRT3_ESTIMATE) / float(One); }
};

struct SPU_Vector256 {
    int32_t v[8];
    static inline SPU_Vector256 add(const SPU_Vector256& u, const SPU_Vector256& v) {
        SPU_Vector256 res;
#if defined(__APPLE__) && defined(__arm64__)
        union { int32_t arr[4]; int32x4_t vec; } lu1, lu2, lv1, lv2, lr1, lr2;
        std::memcpy(lu1.arr, &u.v[0], 16); std::memcpy(lu2.arr, &u.v[4], 16);
        std::memcpy(lv1.arr, &v.v[0], 16); std::memcpy(lv2.arr, &v.v[4], 16);
        lr1.vec = vaddq_s32(lu1.vec, lv1.vec); lr2.vec = vaddq_s32(lu2.vec, lv2.vec);
        std::memcpy(&res.v[0], lr1.arr, 16); std::memcpy(&res.v[4], lr2.arr, 16);
#else
        for (int i = 0; i < 8; ++i) res.v[i] = u.v[i] + v.v[i];
#endif
        return res;
    }
    static inline SPU_Vector256 rotate60(const SPU_Vector256& q) {
        return { q.v[2], q.v[3], q.v[4], q.v[5], q.v[0], q.v[1], q.v[6], q.v[7] };
    }
};

struct alignas(32) Quadray4 {
    SPU_Vector256 data;
    static Quadray4 identity() { return { {SurdFixed64::One, 0, 0, 0, 0, 0, 0, 0} }; }
    static inline Quadray4 _spu_add_q4(Quadray4 u, Quadray4 v) { return { SPU_Vector256::add(u.data, v.data) }; }
    static inline Quadray4 _spu_rotate_60(Quadray4 q) { return { SPU_Vector256::rotate60(q.data) }; }
    static inline int64_t _spu_quadrance(Quadray4 u, Quadray4 v) {
        int64_t total = 0;
        for (int i = 0; i < 4; ++i) {
            int64_t da = (int64_t)u.data.v[i*2] - v.data.v[i*2];
            int64_t db = (int64_t)u.data.v[i*2+1] - v.data.v[i*2+1];
            total += (da * da) + (db * db * 3);
        }
        return total;
    }
    bool equals(const Quadray4& other) const {
        for (int i = 0; i < 8; ++i) if (data.v[i] != other.data.v[i]) return false;
        return true;
    }
};

// --- TENSEGRITY DYNAMICS (v1.8 Kinetic Logic) ---

struct SPU_Mass { int64_t num, den; };

struct SPU_TensegrityNode {
    Quadray4 position;
    Quadray4 prev_position; 
    SPU_Mass mass;

    static inline void _spu_verlet_step(SPU_TensegrityNode& node, const Quadray4& a, int32_t dt_sq) {
        Quadray4 temp = node.position;
        Quadray4 twice_pos = { {node.position.data.v[0] << 1, node.position.data.v[1] << 1, 
                                 node.position.data.v[2] << 1, node.position.data.v[3] << 1,
                                 node.position.data.v[4] << 1, node.position.data.v[5] << 1,
                                 node.position.data.v[6] << 1, node.position.data.v[7] << 1} };
        Quadray4 neg_prev = { {-node.prev_position.data.v[0], -node.prev_position.data.v[1],
                               -node.prev_position.data.v[2], -node.prev_position.data.v[3],
                               -node.prev_position.data.v[4], -node.prev_position.data.v[5],
                               -node.prev_position.data.v[6], -node.prev_position.data.v[7]} };
        Quadray4 accel = { {a.data.v[0] * dt_sq, a.data.v[1] * dt_sq, a.data.v[2] * dt_sq, a.data.v[3] * dt_sq,
                            a.data.v[4] * dt_sq, a.data.v[5] * dt_sq, a.data.v[6] * dt_sq, a.data.v[7] * dt_sq} };
        node.position = Quadray4::_spu_add_q4(twice_pos, Quadray4::_spu_add_q4(neg_prev, accel));
        node.prev_position = temp;
    }
    static inline Quadray4 gravityVector() { return { {0, 0, 0, 0, 0, 0, SurdFixed64::One, 0} }; }
};

enum class LinkType { Cable, Strut, Tie };

struct TensegrityLink {
    int32_t nodeA_idx, nodeB_idx;
    int64_t rest_quadrance; 
    int32_t stiffness;      
    LinkType type;

    void projectConstraint(SPU_TensegrityNode& a, SPU_TensegrityNode& b) const {
        int64_t current_q = Quadray4::_spu_quadrance(a.position, b.position);
        if (type == LinkType::Cable && current_q <= rest_quadrance) return;
        if (type == LinkType::Strut && current_q >= rest_quadrance) return;
        int64_t diff = current_q - rest_quadrance;
        if (std::abs(diff) < 16) return; 
        for (int i = 0; i < 8; ++i) {
            int32_t delta = (a.position.data.v[i] - b.position.data.v[i]) >> 4;
            if (diff > 0) { a.position.data.v[i] -= delta; b.position.data.v[i] += delta; }
            else { a.position.data.v[i] += delta; b.position.data.v[i] -= delta; }
        }
    }
};

// --- END SOVEREIGN CORE ---

// --- LEGACY SUPPORT ---
struct RationalSurd {
    int64_t a, b, divisor;
    static RationalSurd zero() { return {0, 0, 1}; }
    static RationalSurd one() { return {1, 0, 1}; }
    static RationalSurd fromInt(int64_t val) { return {val, 0, 1}; }
    RationalSurd multiply(const RationalSurd& other) const {
        __int128_t res_a = (__int128_t)a * other.a + (__int128_t)3 * b * other.b;
        __int128_t res_b = (__int128_t)a * other.b + (__int128_t)b * other.a;
        return { (int64_t)res_a, (int64_t)res_b, divisor * other.divisor };
    }
    bool equals(const RationalSurd& other) const { return a * other.divisor == other.a * divisor && b * other.divisor == other.b * divisor; }
    float toFloat() const { return (float(a) + float(b) * DisplayAdapter::SQRT3_ESTIMATE) / float(divisor); }
};

} // namespace Synergetics

#endif
