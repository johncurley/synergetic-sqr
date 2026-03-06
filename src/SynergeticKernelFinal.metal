#include <metal_stdlib>
using namespace metal;

// SPU-13 PE-1 Emanation Kernel (v3.0.4 "Egypt")
// Logic: Phased Decompression Sequence (INIT_PHI -> TRANS_Q3 -> ABS_COORD).
// Objective: Biological Soft-Start for High-Conductivity Systems.

struct Surd {
    int divisor;
    int a;
    int b;
    int pad;
};

struct SurdRotor {
    Surd w, x, y, z;
    int4 janus;
};

float surdToFloat(Surd s) {
    if (s.divisor == 0) return 0.0f;
    return (float(s.a) + float(s.b) * 1.73205081f) / float(s.divisor);
}

kernel void renderSynergeticV9_Master(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float4& time [[buffer(0)]],
    constant SurdRotor& rotor [[buffer(1)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
    uv.y *= -1.0f;
    float aspect = float(width) / float(height);
    uv.x *= aspect;

    float currentTime = time.x;
    float3 color = float3(0.0);
    const float GOLDEN_ANGLE = 2.39996323f; 

    // --- DECOMPRESSION PHASES ---
    float phi_mix = 0.0;
    float lattice_mix = 0.0;
    
    if (currentTime < 3.0) {
        // Phase 0: INIT_PHI (2D Spiral)
        phi_mix = currentTime / 3.0;
    } else if (currentTime < 7.0) {
        // Phase 1: TRANS_Q3 (Folding into 4D)
        phi_mix = 1.0;
        lattice_mix = (currentTime - 3.0) / 4.0;
    } else {
        // Phase 2: ABS_COORD (Full Henosis)
        phi_mix = 1.0;
        lattice_mix = 1.0;
    }

    for(int n=1; n<=13; n++) {
        float theta = (float)n * GOLDEN_ANGLE;
        float r = 0.2f * sqrt((float)n) * phi_mix;
        
        // Lattice Folding Logic
        float forward_lean = pow(0.618f, (float)n) * lattice_mix;
        float2 pos = float2(r * cos(theta), r * sin(theta)) * (1.0f + forward_lean);
        
        float dist = length(uv - pos);
        float pulse = 0.5f + 0.5f * sin(currentTime * 6.1440f);
        
        float intensity = exp(-dist * 15.0f) * pulse * phi_mix;
        float3 glowColor = float3(0.54f, 0.17f, 0.89f);
        
        color += glowColor * intensity * (1.0f / (dist + 0.05f));
    }

    color = clamp(color, 0.0, 0.7);
    outTexture.write(float4(color, 1.0f), gid);
}
