#include <metal_stdlib>
using namespace metal;

// --- SOVEREIGN ALGEBRAIC CORE ---

struct SPUControl {
    uint tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    uint32_t bio_security;  // 0=Std, 1=Meditation, 2=Autophagy, 3=Probability
    float    tau_threshold; 
    float    rotor_bias[4]; 
};

struct DisplayCorner {
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
    
    // NEW: Probability Cloud renderer
    static float drawCloud(float2 uv, float2 pos, float precision) {
        float d = length(uv - pos);
        return exp(-d * d * (1.0 / (0.01 + precision * 0.1)));
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

    float3 final_color = float3(0.05, 0.05, 0.08);

    // --- 4. PROBABILITY MANIFOLD MODE (Sovereign Inference) ---
    if (control.bio_security == 3) {
        float cloud = 0.0;
        float precision = 1.0 - control.tau_threshold;
        
        // Render nodes as Probability Distributions
        SurdFixed64 one = { SurdFixed64::One, 0 };
        SurdFixed64 zero = { 0, 0 };
        Quadray4 v_base[4] = {
            {{ one, zero, zero, zero }}, {{ zero, one, zero, zero }},
            {{ zero, zero, one, zero }}, {{ zero, zero, zero, one }}
        };

        for(int i=0; i<4; i++) {
            for(int j=0; j<4; j++) v_base[i].q[j].a += int(control.rotor_bias[j] * 65536.0f);
            SurdVector3 sv = v_base[i].toCartesian();
            float2 pos = float3(DisplayCorner::toFloat(sv.x), DisplayCorner::toFloat(sv.y), 0.0).xy * 2.0;
            cloud += DisplayCorner::drawCloud(uv, pos, precision);
        }
        
        final_color = mix(final_color, float3(0.8, 0.6, 0.2), cloud);
        if (control.coherence == 1) final_color += float3(0.4, 0.1, 0.1) * (1.0 - cloud); // Dissonance Aura
    }

    // --- (Previous Modes 0, 1, 2) ---
    else if (control.bio_security == 1) {
        float pulse = (sin(float(control.tick) * 0.02) + 1.0) * 0.5;
        float lattice = DisplayCorner::drawIVM(uv, float(control.tick), 10.0);
        final_color = mix(final_color, float3(0.2, 0.6, 0.4), lattice * pulse * 0.3);
    }
    else if (control.bio_security == 2) {
        float noise = fract(sin(dot(uv + float(control.tick)*0.001, float2(12.9898, 78.233))) * 43758.5453);
        if (noise > 0.98) {
            float2 grid_pos = floor(uv * 20.0);
            if (fmod(grid_pos.x + grid_pos.y, 2.0) == 0.0) final_color += float3(0.8, 0.2, 0.1) * noise;
        }
    }
    else {
        float lattice = DisplayCorner::drawIVM(uv, float(control.tick), 15.0);
        final_color += float3(0.1, 0.15, 0.2) * lattice;
        // ... (existing Jitterbug rendering code) ...
    }

    outTexture.write(float4(final_color, 1.0f), gid);
}
