#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// 1. Data Structures (Matching the 16-byte aligned CPU/Metal structs)
struct Surd {
    int divisor;
    int a;
    int b;
    int pad;
};

struct SurdRotor {
    Surd w, x, y, z;
    ivec4 janus; // janus.x is the polarity bit
};

float surdToFloat(Surd s) {
    if (s.divisor == 0) return 0.0;
    return (float(s.a) + float(s.b) * 1.73205081) / float(s.divisor);
}

// 2. Bindings
layout(rgba8, binding = 0) writeonly uniform image2D outTexture;

layout(std430, binding = 1) buffer TimeBuffer { vec4 time; };
layout(std430, binding = 2) buffer RotorBuffer { SurdRotor rotor; };

// 3. Rasterization Helpers
float cross2D(vec2 a, vec2 b, vec2 p) {
    return (p.x - a.x) * (b.y - a.y) - (p.y - a.y) * (b.x - a.x);
}

bool isInsideTriangle(vec2 p, vec2 v0, vec2 v1, vec2 v2) {
    float d0 = cross2D(v0, v1, p);
    float d1 = cross2D(v1, v2, p);
    float d2 = cross2D(v2, v0, p);
    return (d0 >= 0 && d1 >= 0 && d2 >= 0) || (d0 <= 0 && d1 <= 0 && d2 <= 0);
}

bool isInsideSquare(vec2 p, vec2 v0, vec2 v1, vec2 v2, vec2 v3) {
    float d0 = cross2D(v0, v1, p);
    float d1 = cross2D(v1, v2, p);
    float d2 = cross2D(v2, v3, p);
    float d3 = cross2D(v3, v0, p);
    return (d0 >= 0 && d1 >= 0 && d2 >= 0 && d3 >= 0) || (d0 <= 0 && d1 <= 0 && d2 <= 0 && d3 <= 0);
}

void main() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(outTexture);
    if (gid.x >= size.x || gid.y >= size.y) return;

    vec2 uv = (vec2(gid) / vec2(size)) * 2.0 - 1.0;
    uv.y *= -1.0;
    float aspect = float(size.x) / float(size.y);
    uv.x *= aspect;

    // SURD COEFFICIENTS
    float sw = surdToFloat(rotor.w);
    float sx = surdToFloat(rotor.x);
    float ct = sw*sw - sx*sx;
    float st = 2.0 * sw * sx * float(rotor.janus.x);
    
    float F = (2.0 * ct + 1.0) / 3.0;
    float G = (2.0 * (ct * -0.5 + st * 0.8660254) + 1.0) / 3.0;
    float H = (2.0 * (ct * -0.5 - st * 0.8660254) + 1.0) / 3.0;

    // JITTERBUG GEOMETRY
    vec3 v_base[12] = vec3[](
        vec3(1,1,0), vec3(1,-1,0), vec3(-1,1,0), vec3(-1,-1,0),
        vec3(1,0,1), vec3(1,0,-1), vec3(-1,0,1), vec3(-1,0,-1),
        vec3(0,1,1), vec3(0,1,-1), vec3(0,-1,1), vec3(0,-1,-1)
    );
    
    float mix_factor = (sin(time.x * 0.4) * 0.5 + 0.5);
    float scale = mix(2.5, 1.8, mix_factor);

    vec2 proj[12];
    vec3 rotated_v[12];
    for(int i=0; i<12; i++) {
        vec3 p = v_base[i] * scale;
        vec3 rv;
        rv.x = p.x * F + p.y * H + p.z * G;
        rv.y = p.x * G + p.y * F + p.z * H;
        rv.z = p.x * H + p.y * G + p.z * F;
        rotated_v[i] = rv;
        proj[i] = rv.xy / (15.0 - rv.z) * 4.0;
    }

    // FACES
    int tris[24] = int[]( 0,4,8, 0,5,9, 1,4,10, 1,5,11, 2,6,8, 2,7,9, 3,6,10, 3,7,11 );
    int quads[24] = int[]( 0,1,5,4, 2,3,7,6, 0,2,9,8, 1,3,11,10, 4,6,8,10, 5,7,9,11 );

    vec3 color = vec3(0.0, 0.0, 0.01);
    float maxZ = -1e10;
    bool hit = false;
    int hitFace = -1;

    for(int i=0; i<8; i++) {
        if(isInsideTriangle(uv, proj[tris[i*3]], proj[tris[i*3+1]], proj[tris[i*3+2]])) {
            float avgZ = (rotated_v[tris[i*3]].z + rotated_v[tris[i*3+1]].z + rotated_v[tris[i*3+2]].z) / 3.0;
            if(avgZ > maxZ) { maxZ = avgZ; hit = true; hitFace = i; }
        }
    }
    for(int i=0; i<6; i++) {
        if(isInsideSquare(uv, proj[quads[i*4]], proj[quads[i*4+1]], proj[quads[i*4+2]], proj[quads[i*4+3]])) {
            float avgZ = (rotated_v[quads[i*4]].z + rotated_v[quads[i*4+1]].z + rotated_v[quads[i*4+2]].z + rotated_v[quads[i*4+3]].z) / 4.0;
            if(avgZ > maxZ) { maxZ = avgZ; hit = true; hitFace = i + 8; }
        }
    }

    if(hit) {
        vec3 light = normalize(vec3(1, 1, -1));
        vec3 faceColor = (hitFace >= 8) ? vec3(1.0, 0.8, 0.2) : vec3(0.8, 0.2, 1.0);
        color = faceColor * (0.5 + 0.5 * (maxZ / 3.0)) + 0.1;
    }

    imageStore(outTexture, gid, vec4(color, 1.0));
}
