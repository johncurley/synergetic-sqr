#include <metal_stdlib>
using namespace metal;

// --- SOVEREIGN ALGEBRAIC CORE (Integer Only) ---

struct SurdFixed64 {
    int a; 
    int b; 
    static constexpr constant int Shift = 16;
    static constexpr constant int One = 1 << 16;

    SurdFixed64 add(SurdFixed64 other) const { return { a + other.a, b + other.b }; }
    SurdFixed64 subtract(SurdFixed64 other) const { return { a - other.a, b - other.b }; }
    SurdFixed64 negate() const { return { -a, -b }; }
    SurdFixed64 multiply(SurdFixed64 other) const {
        long prod_bb = (long)b * other.b;
        long surd_term = (prod_bb << 1) + prod_bb; 
        long res_a = ((long)a * other.a + surd_term) >> Shift;
        long res_b = ((long)a * other.b + (long)b * other.a) >> Shift;
        return { (int)res_a, (int)res_b };
    }
};

struct SurdVector3 {
    SurdFixed64 x, y, z;
};

struct Quadray4 {
    SurdFixed64 q[4];
    static Quadray4 rotate60(Quadray4 in) { return { in.q[1], in.q[2], in.q[0], in.q[3] }; }
    SurdVector3 toCartesian() const {
        return {
            q[0].subtract(q[1]).subtract(q[2]).add(q[3]), 
            q[0].negate().add(q[1]).subtract(q[2]).add(q[3]),
            q[0].negate().subtract(q[1]).add(q[2]).add(q[3])
        };
    }
};

struct SPUControl {
    uint tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     // 0=Sanity, 1=Tuck
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    float    tau_threshold; // Physical Sanity Floor
    float    rotor_bias[4]; // 4D Quadray Bias (A,B,C,D)
};

// --- CARTESIAN CORNER (Optical Interface) ---

struct DisplayCorner {
    static float toFloat(SurdFixed64 s) {
        return (float(s.a) + float(s.b) * 1.73205081f) / 65536.0f;
    }

    static float projectWave(float2 uv, float tick, float phase_offset, bool is_laminar) {
        float d = length(uv);
        float wave = sin(d * 20.0 - tick * 0.1 + phase_offset);
        float intensity = smoothstep(0.5, 0.45, abs(wave)) * exp(-d * 2.0);
        return intensity;
    }

    static float project(SurdVector3 sv, float scale) {
        float3 pf = float3(toFloat(sv.x), toFloat(sv.y), toFloat(sv.z)) * scale;
        return 20.0f - pf.z; // Depth buffer helper
    }

    static float drawEdge(float2 uv, float2 a, float2 b) {
        float2 pa = uv - a, ba = b - a;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        float d = length(pa - ba * h);
        return smoothstep(0.01, 0.005, d);
    }
};

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

    // 1. RESONANT RIPPLES (The Artery Pulse)
    float ripple = 0.0;
    if (control.tick % 34 < 5) { // Fibonacci Heartbeat visual
        float phase = float(control.prime_phase) * (M_PI_F / 3.0);
        ripple = DisplayCorner::projectWave(uv, float(control.tick), phase, control.coherence == 0);
    }

    // 2. JITTERBUG GEOMETRY (ALGEBRAIC CORE)
    SurdFixed64 one = { SurdFixed64::One, 0 };
    SurdFixed64 zero = { 0, 0 };
    SurdFixed64 neg_one = { -SurdFixed64::One, 0 };

    Quadray4 v_base[12] = {
        {{ one, one, zero, zero }}, {{ one, zero, one, zero }}, {{ one, zero, zero, one }},
        {{ zero, one, one, zero }}, {{ zero, one, zero, one }}, {{ zero, zero, one, one }},
        {{ neg_one, neg_one, zero, zero }}, {{ neg_one, zero, neg_one, zero }}, {{ neg_one, zero, zero, neg_one }},
        {{ zero, neg_one, neg_one, zero }}, {{ zero, neg_one, zero, neg_one }}, {{ zero, zero, neg_one, neg_one }}
    };
    
    float scale = 3.0f + sin(float(control.tick) * 0.05f) * 0.5f;

    // 3. OPTICAL PROJECTION
    float2 proj[12];
    for(int i=0; i<12; i++) {
        Quadray4 qv = v_base[i];
        // Apply 4D Rotor Bias from Ghost Kernel
        for(int j=0; j<4; j++) {
            qv.q[j].a += int(control.rotor_bias[j] * 65536.0f);
        }
        
        SurdVector3 sv = qv.toCartesian();
        float3 pf = float3(DisplayCorner::toFloat(sv.x), DisplayCorner::toFloat(sv.y), DisplayCorner::toFloat(sv.z)) * scale;
        proj[i] = pf.xy / (20.0f - pf.z) * 6.0f;
    }

    // 4. DETERMINISTIC RENDERING
    int edges[48] = { 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,5, 2,4, 2,5, 3,4, 3,5, 4,5, 
                      6,7, 6,8, 6,9, 6,10, 7,8, 7,9, 7,11, 8,10, 8,11, 9,10, 9,11, 10,11 };

    float wire = 0.0;
    for(int i=0; i<24; i++) {
        wire = max(wire, DisplayCorner::drawEdge(uv, proj[edges[i*2]], proj[edges[i*2+1]]));
    }

    // 5. COLOR MAPPING (Identity & State)
    float3 color = float3(wire);
    if (control.coherence == 1) {
        color = mix(color, float3(1.0, 0.2, 0.2), 0.5); // Red-Shift (Tuck)
    } else {
        color += float3(0.8, 0.7, 0.3) * ripple; // Golden Ripple (Laminar)
    }

    outTexture.write(float4(color, 1.0f), gid);
}
