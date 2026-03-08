#version 450

/* * Synergetic-SQR: Laminar Rotation Kernel (v3.1.41)
 * Optimized for Bit-Exact Quadray Manifolds (Vulkan/GLSL)
 * Status: Coherence-Safe (Implementing Safety Rails).
 */

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(std430, binding = 0) buffer VertexBuffer {
    vec4 vertices[];
};

layout(push_constant) uniform PushConstants {
    vec3 fgh;
    uint tick;
    uint harmonic_mode;
    uint lattice_lock;
};

// Rational Parabolic Oscillator
float rationalPulse(uint tick) {
    float t = (float(tick % 1000) / 1000.0) * 2.0 - 1.0; 
    return 1.0 - (t * t); 
}

// Harmonic Spiral Projection
vec3 harmonicProject(uint n, float mix_factor, uint tick) {
    uint octave = (n / 12) % 8;
    uint note = n % 12;
    
    // Safety Rail 1: Laminar Buffer (Quadrance-based Falloff)
    float falloff = (octave > 4) ? exp(-(float(octave) - 4.0)) : 1.0;
    
    // Safety Rail 2: Phase-Shift Jitter (Intentional Breathing)
    float breathing = sin(float(tick) * 0.001) * 0.01;
    
    float radius = (0.8 - float(octave) * 0.1) * falloff;
    float angle = (float(note) / 12.0) * 6.2831853 + breathing;
    
    // Safety Rail 3: Torsional Release
    if (octave > 6 && (tick % 2000 > 1000)) {
        angle += 0.523598; // 30 degrees
    }
    
    float x = radius * cos(angle) * (0.5 + 0.5 * mix_factor);
    float y = radius * sin(angle) * (0.5 + 0.5 * mix_factor);
    return vec3(x, y, radius);
}

void main() {
    uint id = gl_GlobalInvocationID.x;
    vec4 current_pos = vertices[id];
    
    float mix_factor = rationalPulse(tick);
    
    if (harmonic_mode == 1) {
        vec3 p = harmonicProject(id, mix_factor, tick);
        current_pos.xyz = p;
    }

    // If lattice locked, snap vertices to the nearest grid point
    if (lattice_lock == 1) {
        current_pos.xy = floor(current_pos.xy * 20.0) / 20.0;
    }

    vertices[id] = current_pos; 
}
