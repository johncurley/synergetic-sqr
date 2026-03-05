#include <metal_stdlib>
using namespace metal;

// SPU-13 Emanation Kernel (v2.9.12)
// Logic: Wave-Interference Rendering and Barycentric Tetrahedral Projection.
// Objective: 100% Nature-Sync. Zero-Cubic RGB Mixing.

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

// Barycentric Tetrahedral Projector (The Forward Lean)
// Utilizes the 4th dimension (w) to resolve depth and projective scale.
float3 barycentricProject(int4 q, float scale) {
    float a = (float)q.x; float b = (float)q.y;
    float c = (float)q.z; float d = (float)q.w;
    
    // Projective Vector Field Mapping
    // Depth is handled by the sum of radials (Inertial Lean)
    float depth = (a + b + c + d) * 0.25f;
    float projective_factor = scale / (15.0f - depth);
    
    return float3(a - b - c + d, a - b + c - d, a + b - c - d) * projective_factor;
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

    // 1. WAVE-INTERFERENCE ROTATION
    float sw = surdToFloat(rotor.w);
    float sx = surdToFloat(rotor.x);
    float ct = sw*sw - sx*sx;
    float st = 2.0f * sw * sx * (float)rotor.janus.x;
    float F = (2.0f * ct + 1.0f) / 3.0f;
    float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
    float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;

    // 2. ISOTROPIC LATTICE (Vector Equilibrium)
    int4 v_base_q[12] = {
        int4(2,0,0,0), int4(0,2,0,0), int4(0,0,2,0), int4(0,0,0,2),
        int4(1,1,0,0), int4(1,0,1,0), int4(1,0,0,1), int4(0,1,1,0),
        int4(0,1,0,1), int4(0,0,1,1), int4(1,1,1,1), int4(2,2,0,0)
    };
    
    float mix_factor = (sin(time.x * 0.4f) * 0.5f + 0.5f);
    float scale = mix(2.5f, 1.8f, mix_factor);

    float3 color = float3(0.0);
    
    // 3. ACHROMATIC RESONANCE LOGIC
    // Instead of loops, we calculate wave interference at each pixel.
    for(int i=0; i<12; i++) {
        float3 p = barycentricProject(v_base_q[i], scale);
        
        // 4D Rotation in the Projective Field
        float3 rv;
        rv.x = p.x * F + p.y * H + p.z * G;
        rv.y = p.x * G + p.y * F + p.z * H;
        rv.z = p.x * H + p.y * G + p.z * F;

        // Wave Interference Pattern (The Purple Glow)
        float dist = length(uv - rv.xy);
        float wave = sin(dist * 50.0f - time.x * 5.0f) * exp(-dist * 10.0f);
        
        // 61440 Harmonic Injection
        float3 spectralColor = float3(0.5 + 0.5*cos(dist*10.0 + float3(0,2,4)));
        color += spectralColor * wave * (1.0f / (dist + 0.1f));
    }

    // Final Intensity Clamping (Safety Protocol)
    color = clamp(color, 0.0, 0.7);
    outTexture.write(float4(color, 1.0f), gid);
}
