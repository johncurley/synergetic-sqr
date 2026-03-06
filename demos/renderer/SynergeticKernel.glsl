#version 450
// SPU-13 PE-1 "Sunflower" GLSL Kernel (v3.1.4)
// Logic: 144-Node High-Resolution Bloom (Fibonacci Scale).
// Parity: 100% Match with SynergeticKernelFinal.metal.

layout(local_size_x = 8, local_size_y = 8) in;
layout(rgba32f, binding = 0) uniform image2D outTexture;

layout(push_constant) uniform Control {
    uint tick;
    int layer;
    uint phase;
    uint dss;
} control;

const float GOLDEN_ANGLE = 2.39996323; 

vec3 barycentricProject(int n, float mix_factor) {
    float theta = float(n) * GOLDEN_ANGLE;
    float r = 0.1 * sqrt(float(n));
    float forward_lean = pow(0.618, float(n % 13)) * mix_factor;
    float x = r * cos(theta) * (1.0 + forward_lean);
    float y = r * sin(theta) * (1.0 + forward_lean);
    return vec3(x, y, forward_lean);
}

void main() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(outTexture);
    if (gid.x >= size.x || gid.y >= size.y) return;

    vec2 uv = (vec2(gid) / vec2(size)) * 2.0 - 1.0;
    uv.y *= -1.0;
    float aspect = float(size.x) / float(size.y);
    uv.x *= aspect;

    float time = float(control.tick) * 0.016;
    float mix_factor = 0.5 + 0.5 * sin(time * 0.5);
    vec3 color = vec3(0.0);

    for(int n=1; n<=144; n++) {
        vec3 p = barycentricProject(n, mix_factor);
        float dist = length(uv - p.xy);
        float intensity = exp(-dist * 25.0) * (1.0 / (dist + 0.02));
        vec3 nodeColor = vec3(0.54, 0.17, 0.89); // Purple Glow
        color += nodeColor * intensity * 0.05;
    }

    color = clamp(color, 0.0, 0.7);
    imageStore(outTexture, gid, vec4(color, 1.0));
}
