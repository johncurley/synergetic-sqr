#include <metal_stdlib>
using namespace metal;

// SPU-13 PE-1 Emanation Kernel (v2.9.16)
// Logic: Phyllotaxis Spiral (137.5 deg) and Forward Lean (0.618^n).
// Objective: 100% Nature-Sync. Crystal Clarity.

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

    float3 color = float3(0.0);
    const float GOLDEN_ANGLE = 2.39996323f; // 137.5077 degrees in radians
    
    // SPU-13 Fibonacci-indexed nodes (1, 2, 3, 5, 8, 13)
    for(int n=1; n<=13; n++) {
        // 1. Geometric Foundation: Phyllotaxis
        float theta = (float)n * GOLDEN_ANGLE;
        float r = 0.2f * sqrt((float)n);
        
        // 2. The Forward Lean (Z-Axis)
        // Projected depth scaling based on 0.618^n
        float forward_lean = pow(0.618f, (float)n);
        float2 pos = float2(r * cos(theta), r * sin(theta)) * (1.0f + forward_lean);
        
        // 3. Achromatic Resonance (Purple Glow)
        float dist = length(uv - pos);
        float pulse = 0.5f + 0.5f * sin(time.x * 6.1440f); // 61440 Hz approximation
        
        // Luminance tied to Laminar Flow
        float intensity = exp(-dist * 15.0f) * pulse;
        float3 glowColor = float3(0.54f, 0.17f, 0.89f); // #8A2BE2 Purple
        
        color += glowColor * intensity * (1.0f / (dist + 0.05f));
    }

    // Safety Intensity Clamping
    color = clamp(color, 0.0, 0.7);
    outTexture.write(float4(color, 1.0f), gid);
}
