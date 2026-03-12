#include <metal_stdlib>
using namespace metal;

// --- 1. SOVEREIGN ALGEBRAIC CONSTANTS ---
#define SURD_SHIFT 16
#define SURD_ONE   (1 << 16)

// --- 2. SOVEREIGN ALGEBRAIC CORE ---

struct SurdFixed64 {
    int a; 
    int b; 
};

struct SurdVector3 {
    SurdFixed64 x, y, z;
};

struct Quadray4 {
    SurdFixed64 q[4];
};

struct SPUControl {
    uint tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    uint32_t bio_security; 
    float    tau_threshold; 
    float    rotor_bias[4]; 
};

// --- 3. ALGEBRAIC PRIMITIVES (C-Style for Compatibility) ---

inline SurdFixed64 surd_add(SurdFixed64 v1, SurdFixed64 v2) {
    return (SurdFixed64){ v1.a + v2.a, v1.b + v2.b };
}

inline SurdFixed64 surd_sub(SurdFixed64 v1, SurdFixed64 v2) {
    return (SurdFixed64){ v1.a - v2.a, v1.b - v2.b };
}

inline SurdFixed64 surd_neg(SurdFixed64 v) {
    return (SurdFixed64){ -v.a, -v.b };
}

inline SurdVector3 q_to_cartesian(Quadray4 qv) {
    SurdVector3 res;
    // x = a - b - c + d
    res.x = surd_add(surd_sub(surd_sub(qv.q[0], qv.q[1]), qv.q[2]), qv.q[3]);
    // y = -a + b - c + d
    res.y = surd_add(surd_sub(surd_add(surd_neg(qv.q[0]), qv.q[1]), qv.q[2]), qv.q[3]);
    // z = -a - b + c + d
    res.z = surd_add(surd_add(surd_add(surd_neg(qv.q[0]), surd_neg(qv.q[1])), qv.q[2]), qv.q[3]);
    return res;
}

inline float surd_to_float(SurdFixed64 s) {
    return (float(s.a) + float(s.b) * 1.73205081f) / 65536.0f;
}

// --- 4. OPTICAL INTERFACE ---

namespace Display {
    static float drawIVM(float2 uv, float tick, float scale) {
        float2 g = uv * scale;
        float2 p1 = float2(1.0, 0.0);
        float2 p2 = float2(0.5, 0.866);
        float2 p3 = float2(-0.5, 0.866);
        float d1 = abs(sin(dot(g, p1)));
        float d2 = abs(sin(dot(g, p2)));
        float d3 = abs(sin(dot(g, p3)));
        return smoothstep(0.02, 0.0, min(d1, min(d2, d3)));
    }

    static float drawEdge(float2 uv, float2 a, float2 b, float tension) {
        float2 pa = uv - a, ba = b - a;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        float2 vibration = float2(sin(uv.y * 50.0 + tension) * 0.002, 0.0);
        float d = length(pa - ba * h + vibration);
        return smoothstep(0.01 + tension * 0.01, 0.005, d);
    }

    static float drawCloud(float2 uv, float2 pos, float precision) {
        float d = length(uv - pos);
        return exp(-d * d * (1.0 / (0.01 + precision * 0.1)));
    }
}

// --- 5. THE MASTER KERNEL ---

kernel void renderDQFA_v1_5(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant SPUControl& control [[buffer(0)]],
    constant int4& dummy [[buffer(1)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
    uv.y *= -1.0f;
    float aspect = float(width) / float(height);
    uv.x *= aspect;

    float3 final_color = float3(0.05, 0.05, 0.08);

    // --- MODE 3: PROBABILITY MANIFOLD ---
    if (control.bio_security == 3) {
        float cloud = 0.0;
        float precision = 1.0 - control.tau_threshold;
        
        struct SurdFixed64 one = { SURD_ONE, 0 };
        struct SurdFixed64 zero = { 0, 0 };
        
        struct Quadray4 v_base[4];
        v_base[0] = (struct Quadray4){{ one, zero, zero, zero }};
        v_base[1] = (struct Quadray4){{ zero, one, zero, zero }};
        v_base[2] = (struct Quadray4){{ zero, zero, one, zero }};
        v_base[3] = (struct Quadray4){{ zero, zero, zero, one }};

        for(int i=0; i<4; i++) {
            struct Quadray4 qv = v_base[i];
            for(int j=0; j<4; j++) qv.q[j].a += int(control.rotor_bias[j] * 65536.0f);
            SurdVector3 sv = q_to_cartesian(qv);
            float2 pos = float2(surd_to_float(sv.x), surd_to_float(sv.y)) * 2.0;
            cloud += Display::drawCloud(uv, pos, precision);
        }
        final_color = mix(final_color, float3(0.8, 0.6, 0.2), cloud);
    }

    // --- MODE 1: LAMINAR MEDITATION ---
    else if (control.bio_security == 1) {
        float pulse = (sin(float(control.tick) * 0.02) + 1.0) * 0.5;
        float lattice = Display::drawIVM(uv, float(control.tick), 10.0);
        final_color = mix(final_color, float3(0.2, 0.6, 0.4), lattice * pulse * 0.3);
    }

    // --- MODE 2: BIOLOGICAL AUTOPHAGY ---
    else if (control.bio_security == 2) {
        float noise = fract(sin(dot(uv + float(control.tick)*0.001, float2(12.9898, 78.233))) * 43758.5453);
        if (noise > 0.98) {
            float2 grid_pos = floor(uv * 20.0);
            if (fmod(grid_pos.x + grid_pos.y, 2.0) == 0.0) {
                final_color += float3(0.8, 0.2, 0.1) * noise;
            }
        }
    }

    // --- MODE 0: STANDARD GEOMETRY ---
    else {
        float lattice = Display::drawIVM(uv, float(control.tick), 15.0);
        final_color += float3(0.1, 0.15, 0.2) * lattice;

        struct SurdFixed64 one = { SURD_ONE, 0 };
        struct SurdFixed64 zero = { 0, 0 };
        struct SurdFixed64 neg_one = { -SURD_ONE, 0 };

        struct Quadray4 v_base[12];
        v_base[0] = (struct Quadray4){{ one, one, zero, zero }};
        v_base[1] = (struct Quadray4){{ one, zero, one, zero }};
        v_base[2] = (struct Quadray4){{ one, zero, zero, one }};
        v_base[3] = (struct Quadray4){{ zero, one, one, zero }};
        v_base[4] = (struct Quadray4){{ zero, one, zero, one }};
        v_base[5] = (struct Quadray4){{ zero, zero, one, one }};
        v_base[6] = (struct Quadray4){{ neg_one, neg_one, zero, zero }};
        v_base[7] = (struct Quadray4){{ neg_one, zero, neg_one, zero }};
        v_base[8] = (struct Quadray4){{ neg_one, zero, zero, neg_one }};
        v_base[9] = (struct Quadray4){{ zero, neg_one, neg_one, zero }};
        v_base[10] = (struct Quadray4){{ zero, neg_one, zero, neg_one }};
        v_base[11] = (struct Quadray4){{ zero, zero, neg_one, neg_one }};
        
        float tension = 0.0;
        for(int i=0; i<4; i++) tension += abs(control.rotor_bias[i]);

        float2 proj[12];
        for(int i=0; i<12; i++) {
            struct Quadray4 qv = v_base[i];
            for(int j=0; j<4; j++) qv.q[j].a += int(control.rotor_bias[j] * 65536.0f);
            SurdVector3 sv = q_to_cartesian(qv);
            float3 pf = float3(surd_to_float(sv.x), surd_to_float(sv.y), surd_to_float(sv.z)) * 3.0f;
            proj[i] = pf.xy / (20.0f - pf.z) * 6.0f;
        }

        int edges[48] = { 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,5, 2,4, 2,5, 3,4, 3,5, 4,5, 
                          6,7, 6,8, 6,9, 6,10, 7,8, 7,9, 7,11, 8,10, 8,11, 9,10, 9,11, 10,11 };

        float wire = 0.0;
        for(int i=0; i<24; i++) {
            wire = max(wire, Display::drawEdge(uv, proj[edges[i*2]], proj[edges[i*2+1]], tension - 1.0f));
        }

        float3 wire_color = (control.coherence == 0) ? float3(0.8, 0.7, 0.2) : float3(1.0, 0.2, 0.1);
        final_color += wire_color * wire;
    }

    outTexture.write(float4(final_color, 1.0f), gid);
}
