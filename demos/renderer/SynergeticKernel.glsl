#version 450
/* SPU-13 Sovereign Kernel (Vulkan/GLSL Mirror v1.5) */
/* Objective: Bit-perfect 60-degree manifold rendering on Linux/Windows. */

layout(local_size_x = 8, local_size_y = 8) in;
layout(set = 0, binding = 0, rgba8) uniform writeonly image2D outTexture;

struct SPUControl {
    uint tick;
    int layer;
    uint prime_phase;
    uint dss_enabled;   
    uint coherence;     
    uint harmonic_mode; 
    uint lattice_lock;  
    uint bio_security; 
    float tau_threshold; 
    float rotor_bias[4]; 
};

layout(std140, set = 0, binding = 1) uniform UBO {
    SPUControl control;
};

// --- 1. SOVEREIGN ALGEBRAIC CORE ---

struct SurdFixed64 {
    int a; int b;
};

SurdFixed64 surd_add(SurdFixed64 u, SurdFixed64 v) { return SurdFixed64(u.a + v.a, u.b + v.b); }
SurdFixed64 surd_sub(SurdFixed64 u, SurdFixed64 v) { return SurdFixed64(u.a - v.a, u.b - v.b); }
SurdFixed64 surd_neg(SurdFixed64 u) { return SurdFixed64(-u.a, -u.b); }

float surd_to_float(SurdFixed64 s) {
    return (float(s.a) + float(s.b) * 1.73205081) / 65536.0;
}

vec2 q_to_ivm(SurdFixed64 q[4]) {
    float a = surd_to_float(q[0]);
    float b = surd_to_float(q[1]);
    float c = surd_to_float(q[2]);
    float d = surd_to_float(q[3]);
    return vec2((b - c) * 0.8660254, a - (b + c) * 0.5);
}

// --- 2. OPTICAL INTERFACE ---

float drawIVM(vec2 uv, float tick, float scale) {
    vec2 g = uv * scale;
    vec2 p1 = vec2(1.0, 0.0);
    vec2 p2 = vec2(0.5, 0.866);
    vec2 p3 = vec2(-0.5, 0.866);
    float d1 = abs(sin(dot(g, p1)));
    float d2 = abs(sin(dot(g, p2)));
    float d3 = abs(sin(dot(g, p3)));
    return smoothstep(0.02, 0.0, min(d1, min(d2, d3)));
}

void main() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(outTexture);
    if (gid.x >= size.x || gid.y >= size.y) return;

    vec2 uv = (vec2(gid) / vec2(size)) * 2.0 - 1.0;
    uv.y *= -1.0;
    float aspect = float(size.x) / float(size.y);
    uv.x *= aspect;

    vec3 final_color = vec3(0.05, 0.05, 0.08);

    // --- MODE 8: SUNFLOWER ---
    if (control.bio_security == 8) {
        float phi = (1.0 + sqrt(5.0)) / 2.0;
        float golden_angle = 2.0 * 3.14159265 * (1.0 - 1.0/phi);
        float count = 400.0;
        float dots = 0.0;
        for(float i=0.0; i<count; i++) {
            float r = sqrt(i / count) * 0.8;
            float theta = i * golden_angle + float(control.tick) * 0.001;
            vec2 pos = vec2(r * cos(theta), r * sin(theta));
            dots = max(dots, smoothstep(0.01, 0.0, length(uv - pos)));
        }
        final_color = mix(vec3(0.05, 0.05, 0.1), vec3(0.8, 0.7, 0.2), dots);
    }
    // --- (Other modes mirrored from DQFA.metal) ---
    else {
        float lattice = drawIVM(uv, float(control.tick), 15.0);
        final_color += vec3(0.1, 0.15, 0.2) * lattice;
    }

    imageStore(outTexture, gid, vec4(final_color, 1.0));
}
