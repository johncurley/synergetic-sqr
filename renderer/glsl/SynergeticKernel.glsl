#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// --- SPU-1 ALGEBRAIC CORE (Integer Only) ---

struct SurdFixed64 {
    int a; // coefficient of 1
    int b; // coefficient of sqrt(3)
};

const int SPU_SHIFT = 16;
const int SPU_ONE = 1 << 16;

SurdFixed64 spu_add(SurdFixed64 u, SurdFixed64 v) { return SurdFixed64(u.a + v.a, u.b + v.b); }
SurdFixed64 spu_sub(SurdFixed64 u, SurdFixed64 v) { return SurdFixed64(u.a - v.a, u.b - v.b); }
SurdFixed64 spu_neg(SurdFixed64 s) { return SurdFixed64(-s.a, -s.b); }

SurdFixed64 spu_mul(SurdFixed64 u, SurdFixed64 v) {
    int64_t prod_bb = int64_t(u.b) * v.b;
    int64_t surd_term = (prod_bb << 1) + prod_bb; 
    int64_t res_a = (int64_t(u.a) * v.a + surd_term) >> SPU_SHIFT;
    int64_t res_b = (int64_t(u.a) * v.b + int64_t(u.b) * v.a) >> SPU_SHIFT;
    return SurdFixed64(int(res_a), int(res_b));
}

SurdFixed64 spu_safe_normalize(SurdFixed64 s) {
    uint mask = 0x40000000;
    if (abs(s.a) < 256 && abs(s.b) < 256) return s; 
    if ((uint(s.a) & mask) != 0 || (uint(s.b) & mask) != 0) {
        return SurdFixed64(s.a >> 1, s.b >> 1);
    }
    return s;
}

struct Quadray4 {
    SurdFixed64 q[4];
};

Quadray4 spu_rotate60(Quadray4 q) {
    return Quadray4(SurdFixed64[](q.q[1], q.q[2], q.q[0], q.q[3]));
}

struct SurdVector3 {
    SurdFixed64 x, y, z;
};

SurdVector3 spu_to_cartesian(Quadray4 q) {
    return SurdVector3(
        spu_add(spu_sub(spu_sub(q.q[0], q.q[1]), q.q[2]), q.q[3]), 
        spu_add(spu_sub(spu_add(spu_neg(q.q[0]), q.q[1]), q.q[2]), q.q[3]),
        spu_add(spu_add(spu_sub(spu_neg(q.q[0]), q.q[1]), q.q[2]), q.q[3]) 
    );
}

// --- CONTROL INTERFACE ---

layout(std430, binding = 1) buffer SPUControl {
    uint tick;
    int rot_count;
};

// --- CARTESIAN CORNER (Optical Interface - Floats Allowed) ---

layout(rgba8, binding = 0) writeonly uniform image2D outTexture;

struct DisplayCorner {
    static float toFloat(SurdFixed64 s) {
        return (float(s.a) + float(s.b) * 1.73205081) / 65536.0;
    }

    static float getScale(uint tick) {
        uint period = 200; 
        uint t_cycle = tick % period;
        float mix_factor = (t_cycle < period / 2) ? (float(t_cycle) / (period / 2.0)) : (2.0 - float(t_cycle) / (period / 2.0));
        return 2.0 + 2.0 * mix_factor; 
    }

    static vec2 project(SurdVector3 sv, float scale) {
        vec3 pf = vec3(toFloat(sv.x), toFloat(sv.y), toFloat(sv.z)) * scale;
        return pf.xy / (20.0 - pf.z) * 6.0;
    }

    static float drawEdge(vec2 uv, vec2 a, vec2 b) {
        vec2 pa = uv - a, ba = b - a;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        float d = length(pa - ba * h);
        return smoothstep(0.01, 0.005, d);
    }
};

void main() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(outTexture);
    if (gid.x >= size.x || gid.y >= size.y) return;

    vec2 uv = (vec2(gid) / vec2(size)) * 2.0 - 1.0;
    uv.y *= -1.0;
    float aspect = float(size.x) / float(size.y);
    uv.x *= aspect;

    // 1. JITTERBUG GEOMETRY (ALGEBRAIC CORE)
    SurdFixed64 zero = SurdFixed64(0, 0);
    SurdFixed64 one = SurdFixed64(SPU_ONE, 0);
    SurdFixed64 neg_one = SurdFixed64(-SPU_ONE, 0);

    Quadray4 v_base[12] = Quadray4[](
        Quadray4(SurdFixed64[](one, one, zero, zero)),
        Quadray4(SurdFixed64[](one, zero, one, zero)),
        Quadray4(SurdFixed64[](one, zero, zero, one)),
        Quadray4(SurdFixed64[](zero, one, one, zero)),
        Quadray4(SurdFixed64[](zero, one, zero, one)),
        Quadray4(SurdFixed64[](zero, zero, one, one)),
        Quadray4(SurdFixed64[](neg_one, neg_one, zero, zero)),
        Quadray4(SurdFixed64[](neg_one, zero, neg_one, zero)),
        Quadray4(SurdFixed64[](neg_one, zero, zero, neg_one)),
        Quadray4(SurdFixed64[](zero, neg_one, neg_one, zero)),
        Quadray4(SurdFixed64[](zero, neg_one, zero, neg_one)),
        Quadray4(SurdFixed64[](zero, zero, neg_one, neg_one))
    );

    // 2. OPTICAL SCALE (CARTESIAN CORNER)
    float scale = DisplayCorner::getScale(tick);

    // 3. OPTICAL PROJECTION (CARTESIAN CORNER)
    vec2 proj[12];
    for(int i=0; i<12; i++) {
        Quadray4 qv = v_base[i];
        for(int r=0; r<rot_count; r++) { qv = spu_rotate60(qv); }
        proj[i] = DisplayCorner::project(spu_to_cartesian(qv), scale);
    }

    // 4. ZERO-JITTER WIREFRAME (CARTESIAN CORNER)
    float wire = 0.0;
    int edges[48] = int[]( 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,5, 2,4, 2,5, 3,4, 3,5, 4,5, 
                           6,7, 6,8, 6,9, 6,10, 7,8, 7,9, 7,11, 8,10, 8,11, 9,10, 9,11, 10,11 );
    for(int i=0; i<24; i++) {
        wire = max(wire, DisplayCorner::drawEdge(uv, proj[edges[i*2]], proj[edges[i*2+1]]));
    }

    imageStore(outTexture, gid, vec4(vec3(wire), 1.0));
}
