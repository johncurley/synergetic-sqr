#include <metal_stdlib>
using namespace metal;

// DQFA (Deterministic Quadratic Field Arithmetic) Spec v1.5
// SPU-1 Sovereign Pipeline: Quadray-Native Integer Logic

struct SurdFixed64 {
    int a; // coefficient of 1
    int b; // coefficient of sqrt(3)
    
    static constexpr constant int Shift = 16;
    static constexpr constant int One = 1 << 16;

    SurdFixed64 add(SurdFixed64 other) const {
        return { a + other.a, b + other.b };
    }

    SurdFixed64 subtract(SurdFixed64 other) const {
        return { a - other.a, b - other.b };
    }

    SurdFixed64 multiply(SurdFixed64 other) const {
        long prod_bb = (long)b * other.b;
        long surd_term = (prod_bb << 1) + prod_bb; // *3
        long res_a = ((long)a * other.a + surd_term) >> Shift;
        long res_b = ((long)a * other.b + (long)b * other.a) >> Shift;
        return { (int)res_a, (int)res_b };
    }

    float toFloat() const {
        return (float(a) + float(b) * 1.73205081f) / float(One);
    }
};

struct Quadray4 {
    SurdFixed64 q[4];
};

struct SurdRotorFixed {
    SurdFixed64 w, x;
    int janus;
};

float3 quadrayToCartesian(Quadray4 q) {
    float q1 = q.q[0].toFloat();
    float q2 = q.q[1].toFloat();
    float q3 = q.q[2].toFloat();
    float q4 = q.q[3].toFloat();
    return float3((q1 - q2 - q3 + q4), (-q1 + q2 - q3 + q4), (-q1 - q2 + q3 + q4));
}

// SPU-1 Zero-Jitter Edge Renderer
float distToSegment(float2 p, float2 a, float2 b) {
    float2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

kernel void renderDQFA_v1_5(
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

    // 1. ROTATION MATRIX (SMOOTH ALGEBRAIC)
    SurdFixed64 sw = rotor.w;
    SurdFixed64 sx = rotor.x;
    SurdFixed64 ct = sw.multiply(sw).subtract({ (3 * sx.multiply(sx).a), (3 * sx.multiply(sx).b) });
    SurdFixed64 st_coeff = sw.multiply(sx).add(sw.multiply(sx));
    float f_ct = ct.toFloat();
    float f_st = st_coeff.toFloat() * 1.73205081f * (float)rotor.janus;
    float F = (2.0f * f_ct + 1.0f) / 3.0f;
    float G = (2.0f * (f_ct * -0.5f + f_st * 0.8660254f) + 1.0f) / 3.0f;
    float H = (2.0f * (f_ct * -0.5f - f_st * 0.8660254f) + 1.0f) / 3.0f;

    // 2. PROJECT JITTERBUG (12 VERTICES)
    Quadray4 v_base[12] = {
        {{ {SurdFixed64::One, 0}, {SurdFixed64::One, 0}, {0, 0}, {0, 0} }}, 
        {{ {SurdFixed64::One, 0}, {0, 0}, {SurdFixed64::One, 0}, {0, 0} }}, 
        {{ {SurdFixed64::One, 0}, {0, 0}, {0, 0}, {SurdFixed64::One, 0} }}, 
        {{ {0, 0}, {SurdFixed64::One, 0}, {SurdFixed64::One, 0}, {0, 0} }}, 
        {{ {0, 0}, {SurdFixed64::One, 0}, {0, 0}, {SurdFixed64::One, 0} }}, 
        {{ {0, 0}, {0, 0}, {SurdFixed64::One, 0}, {SurdFixed64::One, 0} }}, 
        {{ {-SurdFixed64::One, 0}, {-SurdFixed64::One, 0}, {0, 0}, {0, 0} }}, 
        {{ {-SurdFixed64::One, 0}, {0, 0}, {-SurdFixed64::One, 0}, {0, 0} }}, 
        {{ {-SurdFixed64::One, 0}, {0, 0}, {0, 0}, {-SurdFixed64::One, 0} }}, 
        {{ {0, 0}, {-SurdFixed64::One, 0}, {-SurdFixed64::One, 0}, {0, 0} }}, 
        {{ {0, 0}, {-SurdFixed64::One, 0}, {0, 0}, {-SurdFixed64::One, 0} }}, 
        {{ {0, 0}, {0, 0}, {-SurdFixed64::One, 0}, {-SurdFixed64::One, 0} }}  
    };
    
    float mix_factor = (sin(time.x * 0.4f) * 0.5f + 0.5f);
    float scale = mix(3.5f, 2.0f, mix_factor);

    float2 proj[12];
    for(int i=0; i<12; i++) {
        float3 p = quadrayToCartesian(v_base[i]) * scale;
        float3 rv;
        rv.x = p.x * F + p.y * H + p.z * G;
        rv.y = p.x * G + p.y * F + p.z * H;
        rv.z = p.x * H + p.y * G + p.z * F;
        proj[i] = rv.xy / (15.0f - rv.z) * 5.0f;
    }

    // 3. ZERO-JITTER WIREFRAME RENDER
    float edgeDist = 1e10;
    int edges[48] = { 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,5, 2,4, 2,5, 3,4, 3,5, 4,5, 
                      6,7, 6,8, 6,9, 6,10, 7,8, 7,9, 7,11, 8,10, 8,11, 9,10, 9,11, 10,11 };
    
    for(int i=0; i<24; i++) {
        edgeDist = min(edgeDist, distToSegment(uv, proj[edges[i*2]], proj[edges[i*2+1]]));
    }

    float wire = smoothstep(0.01, 0.005, edgeDist);
    float3 color = float3(wire); // High-contrast White on Black

    outTexture.write(float4(color, 1.0f), gid);
}
