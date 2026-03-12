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
    uint32_t bio_security;  // NEW: 0=Standard, 1=Meditation, 2=Autophagy
    float    tau_threshold; 
    float    rotor_bias[4]; 
};

struct DisplayCorner {
    static float drawIVM(float2 uv, float tick, float scale) {
        float2 g = uv * scale;
        float2 p1 = float2(1.0, 0.0);
        float2 p2 = float2(0.5, 0.866);
        float2 p3 = float2(-0.5, 0.866);
        
        float d1 = abs(sin(dot(g, p1) + tick * 0.05));
        float d2 = abs(sin(dot(g, p2) + tick * 0.05));
        float d3 = abs(sin(dot(g, p3) + tick * 0.05));
        
        return smoothstep(0.02, 0.0, min(d1, min(d2, d3)));
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

    float3 final_color = float3(0.05, 0.05, 0.08); // Deep Space Baseline

    // --- 1. LAMINAR MEDITATION MODE ---
    if (control.bio_security == 1) {
        float pulse = (sin(float(control.tick) * 0.02) + 1.0) * 0.5;
        float lattice = DisplayCorner::drawIVM(uv, float(control.tick), 10.0);
        final_color = mix(final_color, float3(0.2, 0.6, 0.4), lattice * pulse * 0.3);
    }

    // --- 2. BIOLOGICAL AUTOPHAGY MODE (Shedding the Cubic) ---
    if (control.bio_security == 2) {
        float noise = fract(sin(dot(uv + float(control.tick)*0.001, float2(12.9898, 78.233))) * 43758.5453);
        if (noise > 0.98) {
            float2 grid_pos = floor(uv * 20.0);
            if (fmod(grid_pos.x + grid_pos.y, 2.0) == 0.0) {
                final_color += float3(0.8, 0.2, 0.1) * noise; // Red "Cubic Dander"
            }
        }
    }

    // --- 3. STANDARD GEOMETRY (The Jitterbug) ---
    if (control.bio_security == 0) {
        // ... existing Quadray/IVM rendering ...
        float lattice = DisplayCorner::drawIVM(uv, float(control.tick), 15.0);
        final_color += float3(0.8, 0.7, 0.2) * lattice;
    }

    outTexture.write(float4(final_color, 1.0f), gid);
}
