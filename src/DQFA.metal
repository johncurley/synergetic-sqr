#include <metal_stdlib>
using namespace metal;

// DQFA (Deterministic Quadratic Field Arithmetic) Spec v1.5
// SPU-1 Sovereign Pipeline: Total Purge of Floats

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

    SurdFixed64 negate() const {
        return { -a, -b };
    }

    // _spu_janus_flip: Projective Reflection (Sign-bit XOR)
    SurdFixed64 janusFlip() const {
        return { a, -b };
    }

    // _spu_surd_mul: Integer Multiply-Shift
    SurdFixed64 multiply(SurdFixed64 other) const {
        long prod_bb = (long)b * other.b;
        long surd_term = (prod_bb << 1) + prod_bb; // *3 logic
        long res_a = ((long)a * other.a + surd_term) >> Shift;
        long res_b = ((long)a * other.b + (long)b * other.a) >> Shift;
        return { (int)res_a, (int)res_b };
    }

    float toFloat() const {
        return (float(a) + float(b) * 1.73205081f) / float(One);
    }
};

struct SurdVector3 {
    SurdFixed64 x, y, z;
};

struct Quadray4 {
    SurdFixed64 q[4];

    // _spu_permute_q4: Zero-gate register shuffle
    static Quadray4 rotate60(Quadray4 in) {
        return { in.q[1], in.q[2], in.q[0], in.q[3] };
    }

    // SPU-1: Algebraic Quadray to Cartesian mapping (Integer Only)
    SurdVector3 toCartesian() const {
        return {
            q[0].subtract(q[1]).subtract(q[2]).add(q[3]), // X = Q1 - Q2 - Q3 + Q4
            q[0].negate().add(q[1]).subtract(q[2]).add(q[3]), // Y = -Q1 + Q2 - Q3 + Q4
            q[0].negate().subtract(q[1]).add(q[2]).add(q[3])  // Z = -Q1 - Q2 + Q3 + Q4
        };
    }
};

struct SurdRotorFixed {
    SurdFixed64 w, x;
    int janus;
};

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

    // 1. JITTERBUG GEOMETRY (QUADRAY NATIVE)
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
    
    // 2. DISCRETE SPU ROTATION (REGISTER SHUFFLES)
    int rot_count = rotor.x.a; 

    float2 proj[12];
    for(int i=0; i<12; i++) {
        Quadray4 qv = v_base[i];
        for(int r=0; r<rot_count; r++) {
            qv = Quadray4::rotate60(qv); // SHUFFLE
        }
        
        // Pure Integer mapping to Cartesian
        SurdVector3 sv = qv.toCartesian();
        
        // Final Floating-Point Display conversion (The Border)
        float scale = 3.0f; // High-level Display Scale
        float3 pf = float3(sv.x.toFloat(), sv.y.toFloat(), sv.z.toFloat()) * scale;
        
        proj[i] = pf.xy / (20.0f - pf.z) * 6.0f;
    }

    // 3. ZERO-JITTER WIREFRAME RENDER
    float edgeDist = 1e10;
    int edges[48] = { 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,5, 2,4, 2,5, 3,4, 3,5, 4,5, 
                      6,7, 6,8, 6,9, 6,10, 7,8, 7,9, 7,11, 8,10, 8,11, 9,10, 9,11, 10,11 };
    
    for(int i=0; i<24; i++) {
        edgeDist = min(edgeDist, distToSegment(uv, proj[edges[i*2]], proj[edges[i*2+1]]));
    }

    float wire = smoothstep(0.01, 0.005, edgeDist);
    outTexture.write(float4(float3(wire), 1.0f), gid);
}
