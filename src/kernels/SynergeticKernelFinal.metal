#include <metal_stdlib>
using namespace metal;

// SPU-13 PE-1 "Sunflower" Kernel (v3.1.43)
// Skeletal Restoration: Core IVM 13-Node Logic.
// Status: IVM Ground Dominant (Default Mode D).

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
    uint coherence; 
    uint harmonic_mode;
    uint lattice_lock;
};

float surdToFloat(Surd s) {
    if (s.divisor == 0) return 0.0f;
    return (float(s.a) + float(s.b) * 1.73205081f) / float(s.divisor);
}

float rationalPulse(uint tick) {
    float t = (float(tick % 1000) / 1000.0f) * 2.0f - 1.0f; 
    return 1.0f - (t * t); 
}

float3 barycentricProject(int n, float scale, float mix_factor) {
    const float GOLDEN_ANGLE = 2.39996323f; 
    float theta = (float)n * GOLDEN_ANGLE;
    float r = 0.12f * sqrt((float)n); 
    float forward_lean = pow(0.618f, (float)(n % 13)) * mix_factor;
    float x = r * cos(theta) * (1.0f + forward_lean);
    float y = r * sin(theta) * (1.0f + forward_lean);
    return float3(x, y, forward_lean);
}

float3 harmonicProject(int n, float mix_factor, uint tick) {
    int octave = (n / 12) % 8;
    int note = n % 12;
    float falloff = (octave > 4) ? exp(-(float)(octave - 4)) : 1.0f;
    float breathing = sin((float)tick * 0.001f) * 0.01f;
    float radius = (0.8f - (float)octave * 0.1f) * falloff;
    float angle = ((float)note / 12.0f) * 6.2831853f + breathing;
    if (octave > 6 && (tick % 2000 > 1000)) angle += 0.523598f; 
    float x = radius * cos(angle) * (0.5f + 0.5f * mix_factor);
    float y = radius * sin(angle) * (0.5f + 0.5f * mix_factor);
    return float3(x, y, radius);
}

// IVM Lattice Grid Function
// Renders a high-contrast 60-degree vector matrix background.
float ivmGrid(float2 uv) {
    float2 q_uv;
    q_uv.x = uv.x * 1.73205081f - uv.y;
    q_uv.y = uv.y * 2.0f;
    float2 grid = abs(fract(q_uv * 10.0f) - 0.5f);
    float line = min(grid.x, grid.y);
    return smoothstep(0.025f, 0.0f, line); // Sharper grid
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
    
    // 1. IVM Grid: Dominant Layer if locked
    if (control.lattice_lock == 1) {
        color += float3(0.2f, 0.3f, 0.4f) * ivmGrid(uv); // Higher contrast blue-grey
    }

    // 2. Node Suppression: Mode D (Pure Geometry)
    if (control.layer == -1) {
        outTexture.write(float4(color, 1.0f), gid);
        return;
    }

    float mix_factor = rationalPulse(control.tick);

    float sw = surdToFloat(rotor.w);
    float sx = surdToFloat(rotor.x);
    float ct = sw*sw - sx*sx;
    float st = 2.0f * sw * sx * (float)rotor.janus.x;
    float F = (2.0f * ct + 1.0f) / 3.0f;
    float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
    float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;

    int nodeCount = (control.layer == 1) ? 13 : 144;
    if (control.harmonic_mode == 1) nodeCount = 96; 
    
    float sharpness = (control.dss == 1) ? 18.0f : 45.0f;
    float coherence_mult = (control.coherence == 1) ? 1.0f : 0.2f;
    
    // Subtler brightness for non-skeletal modes
    float brightness = (control.layer == 1 ? 0.06f : 0.025f) * coherence_mult;
    
    for(int n=1; n<=nodeCount; n++) {
        float3 p;
        float3 nodeColor;
        if (control.harmonic_mode == 1) {
            p = harmonicProject(n, mix_factor, control.tick);
            nodeColor = float3(0.0f, 0.8f, 0.6f); // Subtler Harmonic Cyan
        } else {
            p = barycentricProject(n, 2.0f, mix_factor);
            nodeColor = (control.layer == 1) ? float3(1.0f) : float3(0.44f, 0.12f, 0.79f); // Damped Flora
        }

        float3 rv;
        rv.x = p.x * F + p.y * H + p.z * G;
        rv.y = p.x * G + p.y * F + p.z * H;
        rv.z = p.x * H + p.y * G + p.z * F;

        if (control.lattice_lock == 1) {
            rv.xy = floor(rv.xy * 20.0f) / 20.0f;
        }

        float dist = length(uv - rv.xy);
        float intensity = exp(-dist * sharpness) * (1.0f / (dist + 0.05f));
        color += nodeColor * intensity * brightness;
    }

    color = clamp(color, 0.0, 0.9);
    outTexture.write(float4(color, 1.0f), gid);
}
