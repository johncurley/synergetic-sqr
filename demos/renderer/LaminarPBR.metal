#include <metal_stdlib>
using namespace metal;

// SPU-13 Laminar PBR Kernel (v1.0)
// Objective: Resonant lighting via 60-degree axis coherence.
// Logic: Light intensity = Dot product of Quadray axes (no cosines).

struct SPUControl {
    uint tick;
    float4 light_pos; // Vector A,B,C,D
    float  coherence; // Metallic
    float  dissonance; // Roughness
};

kernel void render_laminar_pbr(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant SPUControl& control [[buffer(0)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
    
    // 1. Calculate Surface Normal in IVM Space
    float3 normal = normalize(float3(uv, sqrt(max(0.0, 1.0 - dot(uv, uv)))));
    
    // 2. Light Alignment (Axis Coherence)
    float3 L = normalize(control.light_pos.xyz);
    float align = max(0.0, dot(normal, L));
    
    // 3. Resonant Reflection (The 'Shine')
    float3 R = reflect(-L, normal);
    float3 V = float3(0, 0, 1);
    float specular = pow(max(0.0, dot(R, V)), 1.0 / (0.01 + control.dissonance));
    
    // 4. Laminar Color Composition
    float3 base_color = float3(0.1, 0.4, 0.6); // Cobalt Baseline
    float3 light_color = float3(1.0, 0.9, 0.7) * align;
    
    float3 final_color = mix(base_color * light_color, light_color, control.coherence);
    final_color += specular * float3(1.0); // Resonant highlight

    outTexture.write(float4(final_color, 1.0f), gid);
}
