#include <metal_stdlib>
using namespace metal;

// SPU-13 PE-1 "Sunflower" Kernel (v3.1.37)
// Skeletal Restoration: Core IVM 13-Node Logic.
// Status: Coherence-Aware (Visualizing the Presence of the One).

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

struct SPUControl {
    uint tick;
    int layer;
    uint phase;
    uint dss;
    uint coherence; // 0=Absence, 1=Presence
};

float surdToFloat(Surd s) {
    if (s.divisor == 0) return 0.0f;
    return (float(s.a) + float(s.b) * 1.73205081f) / float(s.divisor);
}

float3 barycentricProject(int n, float scale, float mix_factor) {
    const float GOLDEN_ANGLE = 2.39996323f; 
    float theta = (float)n * GOLDEN_ANGLE;
    float r = 0.12f * sqrt((float)n); // Tighter radius
    float forward_lean = pow(0.618f, (float)(n % 13)) * mix_factor;
    float x = r * cos(theta) * (1.0f + forward_lean);
    float y = r * sin(theta) * (1.0f + forward_lean);
    return float3(x, y, forward_lean);
}

kernel void renderSynergeticV9_Master(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant SPUControl& control [[buffer(0)]],
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
    float time = float(control.tick) * 0.016f;

    // 1. ISOTROPIC ROTATION
    float sw = surdToFloat(rotor.w);
    float sx = surdToFloat(rotor.x);
    float ct = sw*sw - sx*sx;
    float st = 2.0f * sw * sx * (float)rotor.janus.x;
    float F = (2.0f * ct + 1.0f) / 3.0f;
    float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
    float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;

    // 2. ISOTROPIC BLOOM / SKELETON
    bool isSkeletal = (control.layer == 1);
    int nodeCount = isSkeletal ? 13 : 144;
    
    // High-Contrast Calibration (DSS/Damper influence)
    float sharpness = (control.dss == 1) ? 18.0f : 45.0f;
    
    // Coherence Pulse: If "The One" is absent, the nodes dim.
    float coherence_mult = (control.coherence == 1) ? 1.0f : 0.2f;
    float brightness = (isSkeletal ? 0.06f : 0.04f) * coherence_mult;
    
    float3 nodeColor = isSkeletal ? float3(1.0f) : float3(0.54f, 0.17f, 0.89f);

    for(int n=1; n<=nodeCount; n++) {
        float3 p = barycentricProject(n, 2.0f, 0.5f + 0.5f * sin(time * 0.5f));
        float3 rv;
        rv.x = p.x * F + p.y * H + p.z * G;
        rv.y = p.x * G + p.y * F + p.z * H;
        rv.z = p.x * H + p.y * G + p.z * F;

        float dist = length(uv - rv.xy);
        float intensity = exp(-dist * sharpness) * (1.0f / (dist + 0.05f));
        color += nodeColor * intensity * brightness;
    }

    color = clamp(color, 0.0, 0.9);
    outTexture.write(float4(color, 1.0f), gid);
}
