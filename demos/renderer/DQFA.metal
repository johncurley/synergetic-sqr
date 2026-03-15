#include <metal_stdlib>
using namespace metal;

// --- 1. SOVEREIGN ALGEBRAIC CORE ---

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

    // toIVM : Directly maps 4D Quadray to 2D 60-degree screen point
    float2 toIVM() const {
        float a = (float(q[0].a) + float(q[0].b) * 1.73205081f) / 65536.0f;
        float b = (float(q[1].a) + float(q[1].b) * 1.73205081f) / 65536.0f;
        float c = (float(q[2].a) + float(q[2].b) * 1.73205081f) / 65536.0f;
        // float d = (float(q[3].a) + float(q[3].b) * 1.73205081f) / 65536.0f; // Unused
        // Project onto IVM grid (A=Up, B=120deg, C=240deg, D=Origin)
        return float2((b - c) * 0.8660254f, a - (b + c) * 0.5f);
    }
};

struct SPUControl {
    uint tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    uint32_t bio_security;  // 0=Std, 1=Med, 2=Auto, 3=Prob, 4=Heatmap, 5=Stress, 6=IVMDirect, 7=LatticeLock, 8=Sunflower, 9=Energy
    uint32_t is_cartesian_display; // NEW: Knot-Breaker Toggle
    float    tau_threshold; 
    float    rotor_bias[4]; 
};

// --- 2. OPTICAL INTERFACE ---

// Sub-Pixel Prime Weights (RGB-Aware)
constant float3 r_weights = float3(0.699, 0.231, 0.066); // 179, 59, 17
constant float3 g_weights = float3(0.231, 0.699, 0.231); // 59, 179, 59
constant float3 b_weights = float3(0.066, 0.231, 0.699); // 17, 59, 179

struct DisplayCorner {
    static float2 getUV(uint2 gid, uint width, uint height) {
        float2 uv = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
        uv.y *= -1.0f;
        uv.x *= (float(width) / float(height));
        return uv;
    }

    static float getMode9Energy(float2 uv, SPUControl control) {
        float t = float(control.tick) * 0.02;
        float2 axes[3] = { float2(1.0, 0.0), float2(0.5, 0.866), float2(-0.5, 0.866) };
        float offsets[3] = { sin(t) * 0.1, sin(t + 2.0) * 0.1, sin(t + 4.0) * 0.1 };
        float exposure = 0.0;
        float step_size = 0.15;
        for(int a=0; a<3; a++) {
            float2 n = axes[a];
            float offset = offsets[a];
            for(float i=-5.0; i<=5.0; i+=1.0) {
                float d_line = i * step_size + offset;
                float dist = abs(dot(uv, n) - d_line);
                exposure += exp(-dist * dist * 800.0);
            }
        }
        return exposure;
    }

    static float3 getColor(float2 uv, SPUControl control) {
        float3 final_color = float3(0.05, 0.05, 0.08);

        // --- MODE 8: SUNFLOWER (Phyllotaxis Resonance) ---
        if (control.bio_security == 8) {
            float phi = (1.0 + sqrt(5.0)) / 2.0;
            float golden_angle = 2.0 * 3.14159265 * (1.0 - 1.0/phi);
            float count = 400.0;
            float dots = 0.0;
            for(float i=0.0; i<count; i++) {
                float theta = i * golden_angle + float(control.tick) * 0.001;
                float2 pos = float2(sqrt(i / count) * 0.8 * cos(theta), sqrt(i / count) * 0.8 * sin(theta));
                dots = max(dots, smoothstep(0.01, 0.0, length(uv - pos)));
            }
            final_color = mix(float3(0.05, 0.05, 0.1), float3(0.8, 0.7, 0.2), dots);
        }

        // --- MODE 7: LATTICE LOCK ---
        else if (control.bio_security == 7) {
            float2 macro_uv = floor(uv * 40.0) / 40.0;
            float2 hex_uv = macro_uv;
            hex_uv.x *= 1.1547;
            hex_uv.y += (fmod(floor(uv.x * 40.0), 2.0) == 0.0 ? 0.0 : 0.5) / 40.0;
            float lattice = drawIVM(uv, 0.0, 40.0);
            float2 target = float2(0.0); 
            float dist = length(macro_uv - target);
            final_color = mix(float3(0.1, 0.1, 0.15), float3(0.0, 0.8, 0.4), lattice);
            if (dist < 0.05) final_color += float3(0.8, 0.6, 0.0);
        }

        // --- MODE 6: DIRECT IVM PROJECTION ---
        else if (control.bio_security == 6) {
            float lattice = drawIVM(uv, float(control.tick), 20.0);
            final_color += float3(0.1, 0.2, 0.3) * lattice;
            struct SurdFixed64 one = { SurdFixed64::One, 0 };
            struct SurdFixed64 zero = { 0, 0 };
            struct Quadray4 v_base[7];
            v_base[0] = (struct Quadray4){{ one, one, zero, zero }};
            v_base[1] = (struct Quadray4){{ one, zero, one, zero }};
            v_base[2] = (struct Quadray4){{ one, zero, zero, one }};
            v_base[3] = (struct Quadray4){{ zero, one, one, zero }};
            v_base[4] = (struct Quadray4){{ zero, one, zero, one }};
            v_base[5] = (struct Quadray4){{ zero, zero, one, one }};
            v_base[6] = (struct Quadray4){{ zero, zero, zero, zero }};
            float2 proj[7];
            for(int i=0; i<7; i++) {
                struct Quadray4 qv = v_base[i];
                for(int j=0; j<4; j++) qv.q[j].a += int(control.rotor_bias[j] * 65536.0f);
                proj[i] = qv.toIVM() * 0.5f;
            }
            float wire = 0.0;
            int edges[12] = { 0,1, 1,3, 3,4, 4,0, 0,2, 2,5 };
            for(int i=0; i<6; i++) wire = max(wire, drawEdge(uv, proj[edges[i*2]], proj[edges[i*2+1]], 0.0));
            final_color += float3(0.0, 1.0, 0.6) * wire;
        }

        // --- MODE 4: LUT HEATMAP ---
        else if (control.bio_security == 4) {
            float2 silicon = floor(uv * 64.0);
            float activity = fract(sin(dot(silicon, float2(12.9898, 78.233))) * 43758.5453 + float(control.tick) * 0.01);
            final_color = (activity > 0.7) ? float3(1.0, 0.2, 0.1) : float3(0.1, 0.8, 0.4) * activity;
        }

        // --- MODE 5: LATTICE STRESS MAP ---
        else if (control.bio_security == 5) {
            float cubic = abs(sin(uv.x * 50.0)) * abs(sin(uv.y * 50.0));
            float laminar = abs(sin(uv.x * 50.0 + uv.y * 28.8));
            float dissonance = abs(cubic - laminar);
            final_color = mix(float3(0.0, 0.5, 0.8), float3(1.0, 0.2, 0.1), dissonance);
        }

        // --- MODE 3: PROBABILITY MANIFOLD ---
        else if (control.bio_security == 3) {
            float cloud = 0.0;
            float precision = 1.0 - control.tau_threshold;
            struct SurdFixed64 one = { SurdFixed64::One, 0 };
            struct SurdFixed64 zero = { 0, 0 };
            struct Quadray4 v_base[4];
            v_base[0] = (struct Quadray4){{ one, zero, zero, zero }};
            v_base[1] = (struct Quadray4){{ zero, one, zero, zero }};
            v_base[2] = (struct Quadray4){{ zero, zero, one, zero }};
            v_base[3] = (struct Quadray4){{ zero, zero, zero, one }};
            for(int i=0; i<4; i++) {
                struct Quadray4 qv = v_base[i];
                for(int j=0; j<4; j++) qv.q[j].a += int(control.rotor_bias[j] * 65536.0f);
                SurdVector3 sv = qv.toCartesian();
                float2 pos = float2(toFloat(sv.x), toFloat(sv.y)) * 2.0;
                cloud += drawCloud(uv, pos, precision);
            }
            final_color = mix(final_color, float3(0.8, 0.6, 0.2), cloud);
        }

        // --- MODE 1: LAMINAR MEDITATION ---
        else if (control.bio_security == 1) {
            float pulse = (sin(float(control.tick) * 0.02) + 1.0) * 0.5;
            float lattice = drawIVM(uv, float(control.tick), 10.0);
            final_color = mix(final_color, float3(0.2, 0.6, 0.4), lattice * pulse * 0.3);
        }

        // --- MODE 2: BIOLOGICAL AUTOPHAGY ---
        else if (control.bio_security == 2) {
            float noise = fract(sin(dot(uv + float(control.tick)*0.001, float2(12.9898, 78.233))) * 43758.5453);
            if (noise > 0.98) {
                float2 grid_pos = floor(uv * 20.0);
                if (fmod(grid_pos.x + grid_pos.y, 2.0) == 0.0) final_color += float3(0.8, 0.2, 0.1) * noise;
            }
        }
        
        // --- MODE 9: PURE 2D HIGH-DIM EXPOSURE ---
        else if (control.bio_security == 9) {
            float exposure = getMode9Energy(uv, control);
            final_color = mix(float3(0.05, 0.05, 0.1), float3(0.0, 1.0, 0.8), exposure);
            float cross_mask = smoothstep(0.005, 0.0, abs(uv.x) * step(abs(uv.y), 0.05)) +
                               smoothstep(0.005, 0.0, abs(uv.y) * step(abs(uv.x), 0.05));
            final_color += float3(1.0) * cross_mask;
        }

        // --- MODE 0: STANDARD GEOMETRY ---
        else {
            float lattice = drawIVM(uv, float(control.tick), 15.0);
            final_color += float3(0.1, 0.15, 0.2) * lattice;
            struct SurdFixed64 one = { SurdFixed64::One, 0 };
            struct SurdFixed64 zero = { 0, 0 };
            struct SurdFixed64 neg_one = { -SurdFixed64::One, 0 };
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
                SurdVector3 sv = qv.toCartesian();
                float3 pf = float3(toFloat(sv.x), toFloat(sv.y), toFloat(sv.z)) * 3.0f;
                proj[i] = pf.xy / (20.0f - pf.z) * 6.0f;
            }
            int edges[48] = { 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,5, 2,4, 2,5, 3,4, 3,5, 4,5, 
                              6,7, 6,8, 6,9, 6,10, 7,8, 7,9, 7,11, 8,10, 8,11, 9,10, 9,11, 10,11 };
            float wire = 0.0;
            for(int i=0; i<24; i++) wire = max(wire, drawEdge(uv, proj[edges[i*2]], proj[edges[i*2+1]], tension - 1.0f));
            float3 wire_color = (control.coherence == 0) ? float3(0.8, 0.7, 0.2) : float3(1.0, 0.2, 0.1);
            final_color += wire_color * wire;
            if (control.prime_phase < 4) {
                float pearl = drawPearl(uv, proj[control.prime_phase], float(control.tick));
                final_color = mix(final_color, float3(1.0, 1.0, 1.0), pearl);
            }
        }
        return final_color;
    }

    static float toFloat(SurdFixed64 s) {
        return (float(s.a) + float(s.b) * 1.73205081f) / 65536.0f;
    }

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

    static float drawPearl(float2 uv, float2 pos, float tick) {
        float d = length(uv - pos);
        float pulse = (sin(tick * 0.1) + 1.0) * 0.5;
        return smoothstep(0.02 + pulse * 0.01, 0.0, d) * pulse;
    }
};

// --- 3. THE MASTER KERNEL ---

kernel void renderDQFA_v1_5(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant SPUControl& control [[buffer(0)]],
    constant int4& dummy [[buffer(1)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    // 1. SAMPLE THE NEIGHBORHOOD (Laminar Sub-Pixel Energy)
    float3 c_left   = DisplayCorner::getColor(DisplayCorner::getUV(uint2(max(0, (int)gid.x - 1), gid.y), width, height), control);
    float3 c_center = DisplayCorner::getColor(DisplayCorner::getUV(gid, width, height), control);
    float3 c_right  = DisplayCorner::getColor(DisplayCorner::getUV(uint2(min(width - 1, gid.x + 1), gid.y), width, height), control);

    // 2. PROJECT ENERGY ACROSS THE STRIPES (Mode 9 Spatial Sealant)
    // Red leans center-right, Green is centered, Blue leans center-left
    float r = (c_left.r * r_weights.z) + (c_center.r * r_weights.x) + (c_right.r * r_weights.y);
    float g = (c_left.g * g_weights.x) + (c_center.g * g_weights.y) + (c_right.g * g_weights.z);
    float b = (c_left.b * b_weights.y) + (c_center.b * b_weights.z) + (c_right.b * b_weights.x);

    // 3. APPLY LINEARIZATION (Sovereign Inverse Gamma)
    // This kills the need for temporal dithering by stabilizing the energy field.
    float3 final_color = pow(float3(r, g, b), 1.0f / 2.2f);

    outTexture.write(float4(final_color, 1.0f), gid);
}
