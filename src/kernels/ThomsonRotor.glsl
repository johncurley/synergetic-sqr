#version 450

/* * Synergetic-SQR: Laminar Rotation Kernel (v3.1)
 * Optimized for Bit-Exact Quadray Manifolds (Vulkan/GLSL)
 */

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(std430, binding = 0) buffer VertexBuffer {
    vec4 vertices[];
};

layout(push_constant) uniform PushConstants {
    vec3 fgh;
};

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
    
    // Apply exact tetrahedral rotation
    vertices[id] = rotate_quadray_laminar(current_pos, fgh.x, fgh.y, fgh.z);
}
