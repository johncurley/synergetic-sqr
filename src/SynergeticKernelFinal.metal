#include <metal_stdlib>
using namespace metal;

// MASTER RELEASE: 100% Clean Synergetic Visuals
struct Surd {
    int divisor;
    int a;
    int b;
    int pad;
};

struct SurdRotor {
    Surd w, x, y, z;
    int4 janus;
};

float surdToFloat(Surd s) {
    if (s.divisor == 0) return 0.0f;
    return (float(s.a) + float(s.b) * 1.73205081f) / float(s.divisor);
}

float cross2D(float2 a, float2 b, float2 p) {
    return (p.x - a.x) * (b.y - a.y) - (p.y - a.y) * (b.x - a.x);
}

bool isInsideTriangle(float2 p, float2 v0, float2 v1, float2 v2) {
    float d0 = cross2D(v0, v1, p);
    float d1 = cross2D(v1, v2, p);
    float d2 = cross2D(v2, v0, p);
    return (d0 >= 0 && d1 >= 0 && d2 >= 0) || (d0 <= 0 && d1 <= 0 && d2 <= 0);
}

bool isInsideSquare(float2 p, float2 v0, float2 v1, float2 v2, float2 v3) {
    float d0 = cross2D(v0, v1, p);
    float d1 = cross2D(v1, v2, p);
    float d2 = cross2D(v2, v3, p);
    float d3 = cross2D(v3, v0, p);
    return (d0 >= 0 && d1 >= 0 && d2 >= 0 && d3 >= 0) || (d0 <= 0 && d1 <= 0 && d2 <= 0 && d3 <= 0);
}

kernel void renderSynergeticV9_Master(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float4& time [[buffer(0)]],
    constant SurdRotor& rotor [[buffer(1)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
    uv.y *= -1.0f;
    float aspect = float(width) / float(height);
    uv.x *= aspect;

    // 1. SURD COEFFICIENTS
    float sw = surdToFloat(rotor.w);
    float sx = surdToFloat(rotor.x);
    float ct = sw*sw - sx*sx;
    float st = 2.0f * sw * sx * (float)rotor.janus.x;
    float F = (2.0f * ct + 1.0f) / 3.0f;
    float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
    float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;

    // 2. PROJECT VERTICES
    float3 v_base[12] = {
        float3(1,1,0), float3(1,-1,0), float3(-1,1,0), float3(-1,-1,0),
        float3(1,0,1), float3(1,0,-1), float3(-1,0,1), float3(-1,0,-1),
        float3(0,1,1), float3(0,1,-1), float3(0,-1,1), float3(0,-1,-1)
    };
    
    float mix_factor = (sin(time.x * 0.4f) * 0.5f + 0.5f);
    float scale = mix(2.5f, 1.8f, mix_factor);

    float2 proj[12];
    float3 rotated_v[12];
    for(int i=0; i<12; i++) {
        float3 p = v_base[i] * scale;
        float3 rv;
        rv.x = p.x * F + p.y * H + p.z * G;
        rv.y = p.x * G + p.y * F + p.z * H;
        rv.z = p.x * H + p.y * G + p.z * F;
        rotated_v[i] = rv;
        proj[i] = rv.xy / (15.0 - rv.z) * 4.0;
    }

    // 3. FACES
    int tris[24] = { 0,4,8, 0,5,9, 1,4,10, 1,5,11, 2,6,8, 2,7,9, 3,6,10, 3,7,11 };
    int quads[24] = { 0,1,5,4, 2,3,7,6, 0,2,9,8, 1,3,11,10, 4,6,8,10, 5,7,9,11 };

    float3 color = float3(0.0, 0.0, 0.01);
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
        float3 light = normalize(float3(1, 1, -1));
        float3 v0, v1, v2;
        if(hitFace < 8) {
            v0 = rotated_v[tris[hitFace*3]]; v1 = rotated_v[tris[hitFace*3+1]]; v2 = rotated_v[tris[hitFace*3+2]];
        } else {
            v0 = rotated_v[quads[(hitFace-8)*4]]; v1 = rotated_v[quads[(hitFace-8)*4+1]]; v2 = rotated_v[quads[(hitFace-8)*4+2]];
        }
        float3 n = normalize(cross(v1-v0, v2-v0));
        float diffuse = max(0.2, dot(n, light));
        float3 baseColor = (hitFace >= 8) ? float3(1.0, 0.8, 0.2) : float3(0.8, 0.2, 1.0);
        color = baseColor * diffuse + 0.1;
    }

    outTexture.write(float4(color, 1.0f), gid);
}
