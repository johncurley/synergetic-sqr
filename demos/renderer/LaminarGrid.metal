#include <metal_stdlib>
using namespace metal;

// SPU-13 IVM Grid Shader (v1.0)
// Objective: Visualize the 60-degree Isotropic Vector Matrix.
// Result: The background of the Sovereign Workspace.

kernel void fragment_laminar_grid(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float2 &resolution [[buffer(0)]],
    constant float &time [[buffer(1)]]
) {
    if (gid.x >= uint(resolution.x) || gid.y >= uint(resolution.y)) return;

    float2 uv = (float2(gid) - 0.5 * resolution) / min(resolution.y, resolution.x);
    
    // Hexagonal / Tetrahedral Lattice Logic
    float2 s = float2(1.0, 1.7320508); // sqrt(3)
    float2 a = fmod(uv * s, s) - s * 0.5;
    float2 b = fmod((uv - s * 0.5) * s, s) - s * 0.5;
    
    float d = min(dot(a, a), dot(b, b));
    float thickness = 0.005 * (sin(time * 0.6144) * 0.5 + 1.5);
    
    float3 color = float3(0.0, 0.614, 0.45); // SPU-13 Teal
    float mask = smoothstep(thickness, 0.0, sqrt(d));
    
    outTexture.write(float4(color * mask, 1.0f), gid);
}
