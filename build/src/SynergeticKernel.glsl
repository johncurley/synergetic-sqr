#version 450
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : require

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// 1. Data Structures (Mirroring our Surd logic)
struct Surd {
    int64_t a;
    int64_t b;
    int64_t divisor;
};

struct SurdRotor {
    Surd w, x, y, z;
    int64_t janus;
};

// 2. Surd Arithmetic
Surd multiplySurd(Surd n1, Surd n2) {
    return Surd(
        (n1.a * n2.a + 3 * n1.b * n2.b),
        (n1.a * n2.b + n1.b * n2.a),
        n1.divisor * n2.divisor
    );
}

float surdToFloat(Surd s) {
    return (float(s.a) + float(s.b) * 1.73205081) / float(s.divisor);
}

// 3. Bindings
layout(rgba8, binding = 0) writeonly uniform image2D outTexture;

layout(std430, binding = 1) buffer TimeBuffer {
    vec4 time;
};

layout(std430, binding = 2) buffer RotorBuffer {
    SurdRotor rotor;
};

layout(std430, binding = 3) buffer VEBuffer {
    float ve_verts[];
};

layout(std430, binding = 4) buffer OctBuffer {
    float oct_verts[];
};

layout(std430, binding = 5) buffer EdgeBuffer {
    int edges[];
};

// 4. Geometry Helpers
const vec3 Q1 = vec3( 1.0,  1.0,  1.0);
const vec3 Q2 = vec3( 1.0, -1.0, -1.0);
const vec3 Q3 = vec3(-1.0,  1.0, -1.0);
const vec3 Q4 = vec3(-1.0, -1.0,  1.0);

vec3 toCartesian(vec4 q) {
    return (Q1 * q.x) + (Q2 * q.y) + (Q3 * q.z) + (Q4 * q.w);
}

float dfSegment2D(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void main() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(outTexture);
    if (gid.x >= size.x || gid.y >= size.y) return;

    vec2 pixelPos = (vec2(gid) / vec2(size)) * 2.0 - 1.0;
    pixelPos.y *= -1.0;
    float aspect = float(size.x) / float(size.y);
    pixelPos.x *= aspect;

    // Jitterbug mix factor
    float mix_factor = (sin(time.x * 0.4) * 0.5 + 0.5);
    
    // SURD-BASED SQR (Vulkan/GLSL Port)
    Surd w = rotor.w;
    Surd s = rotor.x; 
    
    Surd ww = multiplySurd(w, w);
    Surd ss = multiplySurd(s, s);
    
    // ct = ww - ss (Exact algebraic subtraction)
    Surd ct_surd = Surd(ww.a - ss.a, ww.b - ss.b, ww.divisor);
    
    // st = 2 * w * s * janus
    Surd ws = multiplySurd(w, s);
    Surd st_surd = Surd(ws.a * 2 * rotor.janus, ws.b * 2 * rotor.janus, ws.divisor);

    float ct = surdToFloat(ct_surd);
    float st = surdToFloat(st_surd);
    
    float F = (2.0 * ct + 1.0) / 3.0;
    float G = (2.0 * (ct * -0.5 + st * 0.8660254) + 1.0) / 3.0;
    float H = (2.0 * (ct * -0.5 - st * 0.8660254) + 1.0) / 3.0;

    vec2 proj_verts[12];
    for (int i = 0; i < 12; ++i) {
        vec4 q1 = vec4(ve_verts[i*4], ve_verts[i*4+1], ve_verts[i*4+2], ve_verts[i*4+3]);
        vec4 q2 = vec4(oct_verts[i*4], oct_verts[i*4+1], oct_verts[i*4+2], oct_verts[i*4+3]);
        vec4 q = mix(q1, q2, mix_factor);
        
        vec4 rq;
        rq.x = q.x;
        rq.y = q.y * F + q.z * H + q.w * G;
        rq.z = q.y * G + q.z * F + q.w * H;
        rq.w = q.y * H + q.z * G + q.w * F;

        vec3 p = toCartesian(rq);
        float z_dist = 6.0 - p.z;
        proj_verts[i] = p.xy / (z_dist * 0.4);
    }

    vec3 color = (rotor.janus > 0) ? vec3(0.01, 0.01, 0.03) : vec3(0.03, 0.01, 0.01);

    float min_edge = 1e10;
    for (int i = 0; i < 24; ++i) {
        min_edge = min(min_edge, dfSegment2D(pixelPos, proj_verts[edges[i*2]], proj_verts[edges[i*2+1]]));
    }
    color += vec3(0.0, 0.7, 1.0) * smoothstep(0.03, 0.0, min_edge);
    color += vec3(1.0, 1.0, 1.0) * smoothstep(0.008, 0.0, min_edge);

    imageStore(outTexture, gid, vec4(color, 1.0));
}
