#version 450

/* * Synergetic-SQR: Laminar Rotation Kernel (v3.1.42)
 * Optimized for Bit-Exact Quadray Manifolds (Vulkan/GLSL)
 * Status: Pure Geometry Enabled (Mode D).
 */

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(std430, binding = 0) buffer VertexBuffer {
    vec4 vertices[];
};

layout(push_constant) uniform PushConstants {
    vec3 fgh;
    uint tick;
    int  layer;
    uint harmonic_mode;
    uint lattice_lock;
};

// IVM Lattice Grid Function
float ivmGrid(vec2 uv) {
    vec2 q_uv;
    q_uv.x = uv.x * 1.73205081 - uv.y;
    q_uv.y = uv.y * 2.0;
    vec2 grid = abs(fract(q_uv * 10.0) - 0.5);
    float line = min(grid.x, grid.y);
    return smoothstep(0.02, 0.0, line);
}

void main() {
    uint id = gl_GlobalInvocationID.x;
    vec4 current_pos = vertices[id];
    
    // If layer is -1, skip vertex processing (Pure IVM Mode)
    if (layer == -1) {
        return;
    }

    // If lattice locked, snap vertices to the nearest grid point
    if (lattice_lock == 1) {
        current_pos.xy = floor(current_pos.xy * 20.0) / 20.0;
    }

    vertices[id] = current_pos; 
}
