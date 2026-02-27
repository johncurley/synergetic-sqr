#include <metal_stdlib>
using namespace metal;

// DQFA (Deterministic Quadratic Field Arithmetic) Spec v1.4
// Bit-exact spatial transformations over SF32.16 (a + b*sqrt(3)) / 2^16

struct SurdFixed64 {
    int a; // coefficient of 1
    int b; // coefficient of sqrt(3)
    
    // Shift is 16. One = 2^16 = 65536.
    static constexpr constant int Shift = 16;
    static constexpr constant int One = 1 << 16;

    SurdFixed64 add(SurdFixed64 other) const {
        return { a + other.a, b + other.b };
    }

    SurdFixed64 subtract(SurdFixed64 other) const {
        return { a - other.a, b - other.b };
    }

    // SMUL: Safe 32x32 -> 64-bit Multiply with 16-bit Shift
    SurdFixed64 multiply(SurdFixed64 other) const {
        long res_a = ((long)a * other.a + (long)3 * b * other.b) >> Shift;
        long res_b = ((long)a * other.b + (long)b * other.a) >> Shift;
        return { (int)res_a, (int)res_b };
    }

    float toFloat() const {
        return (float(a) + float(b) * 1.73205081f) / float(One);
    }
};

struct SurdRotorFixed {
    SurdFixed64 w, x; // Representing w + x*sqrt(3)i
    int janus;
};

kernel void renderDQFA_v1_4(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float4& time [[buffer(0)]],
    constant SurdRotorFixed& rotor [[buffer(1)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 uv = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
    uv.y *= -1.0f;
    float aspect = float(width) / float(height);
    uv.x *= aspect;

    // 1. COMPUTE ROTATION COEFFICIENTS (PURE ALGEBRA)
    SurdFixed64 w = rotor.w;
    SurdFixed64 x = rotor.x;
    
    // ct = w*w - 3*x*x (Algebraic cos)
    SurdFixed64 ct = w.multiply(w).subtract({ (3 * x.multiply(x).a), (3 * x.multiply(x).b) });
    // st_coeff = 2*w*x (Algebraic sin coefficient of sqrt(3))
    SurdFixed64 st_coeff = w.multiply(x).add(w.multiply(x));
    
    float f_ct = ct.toFloat();
    float f_st_coeff = st_coeff.toFloat();
    
    // F, G, H coefficients for SQR Matrix
    float F = (2.0f * f_ct + 1.0f) / 3.0f;
    float G = (-f_ct + 3.0f * f_st_coeff + 1.0f) / 3.0f;
    float H = (-f_ct - 3.0f * f_st_coeff + 1.0f) / 3.0f;

    // 2. PROJECT JITTERBUG
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

    // 3. RASTERIZE
    int tris[24] = { 0,4,8, 0,5,9, 1,4,10, 1,5,11, 2,6,8, 2,7,9, 3,6,10, 3,7,11 };
    float3 color = float3(0.0, 0.0, 0.01);
    float maxZ = -1e10;
    bool hit = false;
    for(int i=0; i<8; i++) {
        float2 v0 = proj[tris[i*3]], v1 = proj[tris[i*3+1]], v2 = proj[tris[i*3+2]];
        float d0 = (uv.x - v0.x) * (v1.y - v0.y) - (uv.y - v0.y) * (v1.x - v0.x);
        float d1 = (uv.x - v1.x) * (v2.y - v1.y) - (uv.y - v1.y) * (v2.x - v1.x);
        float d2 = (uv.x - v2.x) * (v0.y - v2.y) - (uv.y - v2.y) * (v0.x - v2.x);
        if ((d0 >= 0 && d1 >= 0 && d2 >= 0) || (d0 <= 0 && d1 <= 0 && d2 <= 0)) {
            float avgZ = (rotated_v[tris[i*3]].z + rotated_v[tris[i*3+1]].z + rotated_v[tris[i*3+2]].z) / 3.0;
            if(avgZ > maxZ) { maxZ = avgZ; hit = true; }
        }
    }

    if(hit) color = float3(0.8, 0.2, 1.0) * (0.5 + 0.5 * (maxZ / 3.0)) + 0.1;
    outTexture.write(float4(color, 1.0f), gid);
}
