#include <metal_stdlib>
using namespace metal;

// SPU-13 Laminar Massage Shader (v1.0)
// Objective: Break the 'Square Eye' lock via 60-degree scanning patterns.
// Vibe: Visual De-Cuber / Neurological Physical Therapy.

kernel void compute_massage(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float &time [[buffer(0)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = float2(gid) / float2(width, height);
    float aspect = float(width) / float(height);
    uv.x *= aspect;

    // Moving 60-degree vectors
    float2 p1 = float2(cos(time*0.5), sin(time*0.5));
    float2 p2 = float2(cos(time*0.5 + 2.094), sin(time*0.5 + 2.094)); // +120 deg
    float2 p3 = float2(cos(time*0.5 + 4.188), sin(time*0.5 + 4.188)); // +240 deg

    float d1 = abs(dot(uv - 0.5, p1));
    float d2 = abs(dot(uv - 0.5, p2));
    float d3 = abs(dot(uv - 0.5, p3));

    float intensity = smoothstep(0.01, 0.0, min(d1, min(d2, d3)));
    float3 color = float3(0.2, 0.8, 0.5) * intensity; // Emerald Flow

    outTexture.write(float4(color, 1.0f), gid);
}
