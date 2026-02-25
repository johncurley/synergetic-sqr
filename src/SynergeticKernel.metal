#include <metal_stdlib>
using namespace metal;

struct SQRotor {
    float4 coords;
    float janus; // +1.0 or -1.0
};

constant float3 Q1 = float3( 1.0f,  1.0f,  1.0f);
constant float3 Q2 = float3( 1.0f, -1.0f, -1.0f);
constant float3 Q3 = float3(-1.0f,  1.0f, -1.0f);
constant float3 Q4 = float3(-1.0f, -1.0f,  1.0f);

float3 toCartesian(float4 q) {
    return (Q1 * q.x) + (Q2 * q.y) + (Q3 * q.z) + (Q4 * q.w);
}

float dfSegment2D(float2 p, float2 a, float2 b) {
    float2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0f, 1.0f);
    return length(pa - ba * h);
}

kernel void renderSynergetic(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant float4& time [[buffer(0)]],
    constant SQRotor& rotor [[buffer(1)]],
    constant float* ve_verts [[buffer(2)]],
    constant float* oct_verts [[buffer(3)]],
    constant int* edges [[buffer(4)]]
) {
    uint width = outTexture.get_width();
    uint height = outTexture.get_height();
    if (gid.x >= width || gid.y >= height) return;

    float2 pixelPos = (float2(gid) / float2(width, height)) * 2.0f - 1.0f;
    pixelPos.y *= -1.0f;
    float aspect = float(width) / float(height);
    pixelPos.x *= aspect;

    // Jitterbug mix factor
    float mix_factor = (sin(time.x * 1.5f) * 0.5f + 0.5f);
    
    // SQR Parameters
    // In the algebraic update, rotor.coords already contains cos(theta/2) and sin(theta/2)
    float w = rotor.coords.x;
    float s = rotor.coords.y; // Assumes W-axis rotation for the demo
    float janus = rotor.janus;
    
    // Half-angle to full-angle coefficients
    float ct = w*w - s*s;
    float st = 2.0f * w * s * janus;
    
    float F = (2.0f * ct + 1.0f) / 3.0f;
    float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
    float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;

    float2 proj_verts[12];
    for (int i = 0; i < 12; ++i) {
        float4 q1 = float4(ve_verts[i*4], ve_verts[i*4+1], ve_verts[i*4+2], ve_verts[i*4+3]);
        float4 q2 = float4(oct_verts[i*4], oct_verts[i*4+1], oct_verts[i*4+2], oct_verts[i*4+3]);
        float4 q = mix(q1, q2, mix_factor);
        
        float4 rq;
        rq.x = q.x;
        rq.y = q.y * F + q.z * H + q.w * G;
        rq.z = q.y * G + q.z * F + q.w * H;
        rq.w = q.y * H + q.z * G + q.w * F;

        float3 p = toCartesian(rq);
        float z_dist = 6.0f - p.z;
        proj_verts[i] = p.xy / (z_dist * 0.4f);
    }

    float3 color = float3(0.01f, 0.01f, 0.03f);

    float min_edge = 1e10;
    for (int i = 0; i < 24; ++i) {
        min_edge = min(min_edge, dfSegment2D(pixelPos, proj_verts[edges[i*2]], proj_verts[edges[i*2+1]]));
    }
    color += float3(0.0f, 0.7f, 1.0f) * smoothstep(0.03f, 0.0f, min_edge);
    color += float3(1.0f, 1.0f, 1.0f) * smoothstep(0.008f, 0.0f, min_edge);

    float min_vert = 1e10;
    for (int i = 0; i < 12; ++i) {
        min_vert = min(min_vert, length(pixelPos - proj_verts[i]));
    }
    color += float3(0.2f, 1.0f, 0.5f) * smoothstep(0.06f, 0.0f, min_vert);
    color += float3(1.0f, 1.0f, 1.0f) * smoothstep(0.02f, 0.0f, min_vert);

    outTexture.write(float4(color, 1.0f), gid);
}
