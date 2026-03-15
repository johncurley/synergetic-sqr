#include <metal_stdlib>
using namespace metal;

// SPU-13 LUT Heatmap Visualizer (v1.0)
// Objective: Visualize the metabolic activity of the FPGA logic fabric.
// Logic: Map utilization reports to a 3D silicon model.

kernel void render_lut_heatmap(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float &tick [[buffer(0)]],
    constant float4 &utilization [[buffer(1)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = float2(gid) / float2(width, height);
    
    // Simulate silicon chip layout
    float2 silicon = floor(uv * 64.0);
    float activity = fract(sin(dot(silicon, float2(12.9898, 78.233))) * 43758.5453 + tick * 0.01);
    
    float3 color;
    if (activity > utilization.x) { // Over-threshold: Cubic bottleneck
        color = float3(1.0, 0.2, 0.1); 
    } else {
        color = float3(0.1, 0.8, 0.4) * activity; // Emerald: Laminar resonance
    }

    outTexture.write(float4(color, 1.0f), gid);
}
