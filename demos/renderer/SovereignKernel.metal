#include <metal_stdlib>
using namespace metal;

// SPU-13 UNIFIED SOVEREIGN KERNEL (v1.5)
// Objective: "Laminar & Ephemeral" 60-degree resonance.
// Uses a Rational Parabolic profile (1 - x^2) and a 1.5-pixel width 
// to bridge the "Cubic Gap" between physical sub-pixel bars.

struct SPUControl {
    uint tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    uint32_t bio_security; 
    uint32_t is_cartesian_display;
    float    tau_threshold; 
    float    rotor_bias[4]; 
};

struct SovereignCore {
    static float getIntensity(float2 uv, SPUControl ctrl, float pixel_w_uv) {
        float t = (ctrl.bio_security == 10) ? 0.0 : float(ctrl.tick) * 0.02;

        // 3-Axis IVM Projection (Normalized 60-degree vectors)
        float2 axes[3] = { 
            float2(1.0, 0.0), 
            float2(-0.5, 0.866), 
            float2(-0.5, -0.866)
        };
        
        float offsets[3] = { 
            sin(t) * 0.1, 
            sin(t + 2.0) * 0.1, 
            sin(t + 4.0) * 0.1
        };

        float exposure = 0.0;
        float step_size = 0.25;
        
        // RATIONAL EPHEMERAL WIDTH: 1.5 physical pixels
        // This ensures energy is always shared across sub-pixels, killing the "flash."
        float line_w = pixel_w_uv * 1.5f;

        for(int a=0; a<3; a++) {
            for(float i=-4.0; i<=4.0; i+=1.0) {
                float dist = abs(dot(uv, axes[a]) - (i * step_size + offsets[a]));
                
                // RATIONAL PARABOLIC PROFILE (1 - x^2)
                float x = dist / line_w;
                float intensity = saturate(1.0f - (x * x));
                
                exposure = max(exposure, intensity);
            }
        }
        return exposure;
    }

    static float2 getUV(uint2 gid, uint2 size) {
        float2 uv = (float2(gid) / float2(size)) * 2.0f - 1.0f;
        uv.y *= -1.0f;
        uv.x *= (float(size.x) / float(size.y));
        return uv;
    }
};

kernel void renderSovereign_v1(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    constant SPUControl& control [[buffer(0)]],
    constant uint64_t* commands  [[buffer(1)]]
) {
    uint2 size = uint2(outTexture.get_width(), outTexture.get_height());
    if (gid.x >= size.x || gid.y >= size.y) return;

    float2 uv = SovereignCore::getUV(gid, size);
    float aspect = float(size.x) / float(size.y);
    float pixel_w_uv = (2.0f * aspect) / float(size.x);
    float sub_offset = pixel_w_uv * 0.333f;

    // 1. LAMINAR CORE ENERGY
    float raw_energy = SovereignCore::getIntensity(uv, control, pixel_w_uv);

    // 2. SOVEREIGN COMMAND PROCESSING (v1.6)
    // For the audit, we only check the first instruction in the buffer
    uint64_t word = commands[0];
    uint8_t opcode = (word >> 56) & 0xFF;
    
    if (opcode == 0x41) { // SPROJ_P (Project Sovereign Point)
        // Unpack 12-bit signed quadrays
        int16_t qa = (word >> 44) & 0x0FFF; if (qa & 0x0800) qa |= 0xF000;
        int16_t qb = (word >> 32) & 0x0FFF; if (qb & 0x0800) qb |= 0xF000;
        int16_t qc = (word >> 12) & 0x0FFF; if (qc & 0x0800) qc |= 0xF000;
        int16_t qd = word & 0x0FFF;         if (qd & 0x0800) qd |= 0xF000;
        
        // Map to IVM space
        float a = float(qa) / 64.0f;
        float b = float(qb) / 64.0f;
        float c = float(qc) / 64.0f;
        float2 pos = float2((b - c) * 0.8660254f, a - (b + c) * 0.5f);
        
        float dist = length(uv - pos);
        float dot_intensity = smoothstep(0.02, 0.0, dist) * (float((word >> 24) & 0xFF) / 255.0f);
        raw_energy = max(raw_energy, dot_intensity);
    }

    // 3. SUB-PIXEL ADDRESSING (Ephemeral Needle)
    float raw_r = saturate(raw_energy); // Simplified for v1.6 command test
    float raw_g = saturate(raw_energy);
    float raw_b = saturate(raw_energy);

    // 4. SOVEREIGN LINEARIZATION
    float3 background = float3(0.005, 0.005, 0.01); 
    float3 signal = float3(0.0, 1.0, 0.8);          
    float3 final = pow(mix(background, signal, float3(raw_r, raw_g, raw_b)), 1.0f / 2.2f);

    outTexture.write(float4(final, 1.0f), gid);
}
