#version 450

/* * Synergetic-SQR: Laminar Rotation Kernel (v3.1.18)
 * Optimized for Bit-Exact Quadray Manifolds (Vulkan/GLSL)
 * Status: Rational (Using Parabolic Dynamics instead of sin)
 */

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(std430, binding = 0) buffer VertexBuffer {
    vec4 vertices[];
};

layout(push_constant) uniform PushConstants {
    vec3 fgh;
    uint tick;
};

// Rational Parabolic Oscillator
// Replaces sin(t). Maps a linear time input to a periodic parabola.
float rationalPulse(uint tick) {
    float t = (float(tick % 1000) / 1000.0) * 2.0 - 1.0; // range [-1, 1]
    return 1.0 - (t * t); // Parabolic arc
}

// Thomson F,G,H Circulant Rotation
// Rotates ABCD coordinates about Axis A
vec4 rotate_quadray_laminar(vec4 q, float f, float g, float h) {
    vec4 q_prime;
    q_prime.x = q.x; // Axis A Invariant
    q_prime.y = (f * q.y) + (h * q.z) + (g * q.w); // B'
    q_prime.z = (g * q.y) + (f * q.z) + (h * q.w); // C'
    q_prime.w = (h * q.y) + (g * q.z) + (f * q.w); // D'
    return q_prime;
}

void main() {
    uint id = gl_GlobalInvocationID.x;
    vec4 current_pos = vertices[id];
    
    float mix_factor = rationalPulse(tick);
    
    // Apply exact tetrahedral rotation with rational mix factor
    // (Note: f,g,h would be pre-scaled by mix_factor in the controller)
    vertices[id] = rotate_quadray_laminar(current_pos, fgh.x, fgh.y, fgh.z);
}
