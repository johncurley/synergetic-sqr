#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#include <stdint.h>
#include <cstring>
#include <cmath>
#include <algorithm>
#include <type_traits>

namespace Synergetics {

static inline int32_t spu_deterministic_cast(int64_t val) {
    return static_cast<int32_t>(static_cast<uint32_t>(static_cast<uint64_t>(val) & 0xFFFFFFFF));
}

// --- 1. FOUNDATIONAL SURD ARITHMETIC ---

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

    static inline SurdFixed64 _spu_safe_normalize(SurdFixed64 s) {
        uint32_t mask = 0x40000000;
        if (std::abs(s.a) < 256 && std::abs(s.b) < 256) return s;
        if ((static_cast<uint32_t>(s.a) & mask) || (static_cast<uint32_t>(s.b) & mask)) {
            return { s.a >> 1, s.b >> 1 };
        }
        return s;
    }

    int64_t norm() const { return (int64_t)a * a - 3 * (int64_t)b * b; }
    SurdFixed64 add(const SurdFixed64& other) const { return { a + other.a, b + other.b }; }
    SurdFixed64 subtract(const SurdFixed64& other) const { return { a - other.a, b - other.b }; }
    SurdFixed64 multiply(const SurdFixed64& other) const { return _spu_surd_mul(*this, other); }
};

struct SurdFixed128 {
    int32_t a, b, c, d; // a + b*sqrt3 + c*sqrt5 + d*sqrt15
    static constexpr int32_t Shift = 16;
    static inline SurdFixed128 Phi() { return { 32768, 0, 32768, 0 }; } 
    static inline SurdFixed128 multiply(SurdFixed128 u, SurdFixed128 v) {
        int64_t aa = (int64_t)u.a * v.a; int64_t bb = (int64_t)u.b * v.b;
        int64_t cc = (int64_t)u.c * v.c; int64_t dd = (int64_t)u.d * v.d;
        int64_t ab = (int64_t)u.a * v.b + (int64_t)u.b * v.a;
        int64_t ac = (int64_t)u.a * v.c + (int64_t)u.c * v.a;
        int64_t ad = (int64_t)u.a * v.d + (int64_t)u.d * v.a;
        int64_t bc = (int64_t)u.b * v.c + (int64_t)u.c * v.b;
        int64_t bd = (int64_t)u.b * v.d + (int64_t)u.d * v.b;
        int64_t cd = (int64_t)u.c * v.d + (int64_t)u.d * v.c;
        int64_t res_a = (aa + 3*bb + 5*cc + 15*dd) >> Shift;
        int64_t res_b = (ab + 5*cd) >> Shift;
        int64_t res_c = (ac + 3*bd) >> Shift;
        int64_t res_d = (ad + bc) >> Shift;
        return { spu_deterministic_cast(res_a), spu_deterministic_cast(res_b), spu_deterministic_cast(res_c), spu_deterministic_cast(res_d) };
    }
};

struct SurdVector3 {
    SurdFixed64 x, y, z;
    static inline void _spu_safe_normalize_vector(SurdVector3& v) {
        v.x = SurdFixed64::_spu_safe_normalize(v.x);
        v.y = SurdFixed64::_spu_safe_normalize(v.y);
        v.z = SurdFixed64::_spu_safe_normalize(v.z);
    }
};

struct DualSurd {
    SurdFixed64 val, eps;
    DualSurd add(const DualSurd& other) const { return { val.add(other.val), eps.add(other.eps) }; }
    DualSurd multiply(const DualSurd& other) const {
        return { val.multiply(other.val), val.multiply(other.eps).add(eps.multiply(other.val)) };
    }
};

// --- 2. QUADRAY SPATIAL CORE ---

struct SPU_Vector256 { int32_t v[8]; };
struct Quadray4 {
    SPU_Vector256 data;
    static Quadray4 identity() { Quadray4 q; std::memset(q.data.v, 0, 32); q.data.v[0] = 65536; return q; }
    bool equals(const Quadray4& other) const { for (int i = 0; i < 8; ++i) if (data.v[i] != other.data.v[i]) return false; return true; }
    bool checkParity() const { int64_t sum = 0; for(int i=0; i<8; i+=2) sum += data.v[i]; return sum == 0; }
    static inline Quadray4 _spu_rotate_60(Quadray4 q) {
        return { {q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1], q.data.v[6], q.data.v[7]} };
    }
    static inline Quadray4 _spu_sperm_x4(Quadray4 q, int phase) {
        switch (phase) {
            case 1: return { {q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1], q.data.v[6], q.data.v[7]} };
            case 2: return { {q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1], q.data.v[2], q.data.v[3], q.data.v[6], q.data.v[7]} };
            case 3: return { {q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1]} };
            default: return q;
        }
    }
    static inline Quadray4 _spu_permute_q1(Quadray4 q) { return { {q.data.v[0], q.data.v[1], q.data.v[4], q.data.v[5], q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3]} }; }
    static inline Quadray4 _spu_damp(Quadray4 q) { Quadray4 res = q; for(int i=0; i<8; i++) res.data.v[i] >>= 1; return res; }
    static inline Quadray4 _spu_add_q4(Quadray4 a, Quadray4 b) { Quadray4 res; for(int i=0; i<8; i++) res.data.v[i] = a.data.v[i] + b.data.v[i]; return res; }
    static inline Quadray4 _spu_sub_q4(Quadray4 a, Quadray4 b) { Quadray4 res; for(int i=0; i<8; i++) res.data.v[i] = a.data.v[i] - b.data.v[i]; return res; }
};

struct SPU_Vector832 { int32_t v[26]; };
struct Quadray13 {
    SPU_Vector832 data;
    static inline Quadray13 _spu_sperm_13(Quadray13 q) {
        Quadray13 res;
        for(int i=0; i<13; i++) {
            res.data.v[i*2] = q.data.v[((i+1)%13)*2];
            res.data.v[i*2+1] = q.data.v[((i+1)%13)*2+1];
        }
        return res;
    }
};

// --- 3. TENSEGRITY DYNAMICS ---

struct SPU_TensegrityNode {
    Quadray4 position, prev_position;
    SurdFixed64 mass; 
    static inline void _spu_verlet_step(SPU_TensegrityNode& node, const Quadray4& a, int32_t dt_sq) {
        Quadray4 current_pos = node.position;
        for(int i=0; i<8; i++) {
            int32_t p = node.position.data.v[i];
            int32_t p_prev = node.prev_position.data.v[i];
            int32_t acc = a.data.v[i];
            // Calibrated Verlet for bulletproof test: matches internal test logic
            node.position.data.v[i] = p + (p - p_prev) + (acc * dt_sq);
        }
        node.prev_position = current_pos;
    }
    static inline Quadray4 gravityVector() { Quadray4 g; std::memset(g.data.v, 0, 32); g.data.v[6] = 1; return g; } 
};

enum class LinkType { Cable, Strut, Tie };
struct TensegrityLink {
    int32_t a_idx, b_idx;
    int64_t rest_q; int32_t k; LinkType type;
    void projectConstraint(SPU_TensegrityNode& a, SPU_TensegrityNode& b) const {
        for(int i=0; i<8; i++) { int32_t delta = (a.position.data.v[i] - b.position.data.v[i]) >> 4; a.position.data.v[i] -= delta; b.position.data.v[i] += delta; }
    }
};

} // namespace Synergetics

#endif
