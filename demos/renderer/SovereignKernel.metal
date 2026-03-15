#include <metal_stdlib>
using namespace metal;

// SPU-13 UNIFIED SOVEREIGN KERNEL (v1.7)
// Objective: "Stillness-Locked" 60-degree resonance.
// Integrates the Anneal Stabilizer logic to ensure emulator-to-hardware parity.

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
    float    anneal_cooling; // NEW: 0.0 (Fluid) to 1.0 (Locked)
};

struct SovereignCore {
    // Mimics the spu13_anneal_stabilizer.v logic
    static float latticeSnap(float val, float cooling) {
        if (cooling <= 0.0) return val;
        
        // Lattice Grid Size (matching the 64-unit hardware grid)
        float grid = 0.015625; // 1/64
        float target = round(val / grid) * grid;
        
        // Move toward the target based on the cooling factor
        return mix(val, target, cooling);
    }

    static float getIntensity(float2 uv, SPUControl ctrl, float pixel_w_uv) {
        float t = (ctrl.bio_security == 10) ? 0.0 : float(ctrl.tick) * 0.02;

        float2 axes[3] = { float2(1.0, 0.0), float2(-0.5, 0.866), float2(-0.5, -0.866) };
        float offsets[3] = { sin(t) * 0.1, sin(t + 2.0) * 0.1, sin(t + 4.0) * 0.1 };

        float exposure = 0.0;
        float step_size = 0.25;
        float line_w = pixel_w_uv * 1.5f;

        for(int a=0; a<3; a++) {
            for(float i=-4.0; i<=4.0; i+=1.0) {
                float dist = abs(dot(uv, axes[a]) - (i * step_size + offsets[a]));
                
                // --- THE ANNEAL SNAP (Hardware Parity) ---
                dist = latticeSnap(dist, ctrl.anneal_cooling);

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

    // 1. ANNEALED SUB-PIXEL SAMPLING
    float raw_r = SovereignCore::getIntensity(uv - float2(sub_offset, 0), control, pixel_w_uv);
    float raw_g = SovereignCore::getIntensity(uv, control, pixel_w_uv);
    float raw_b = SovereignCore::getIntensity(uv + float2(sub_offset, 0), control, pixel_w_uv);

    // 2. SOVEREIGN COMMAND PROCESSING (v1.7)
    uint64_t word = commands[0];
    uint8_t opcode = (word >> 56) & 0xFF;
    if (opcode == 0x41) { // SPROJ_P
        int16_t qa = (word >> 44) & 0x0FFF; if (qa & 0x0800) qa |= 0xF000;
        int16_t qb = (word >> 32) & 0x0FFF; if (qb & 0x0800) qb |= 0xF000;
        int16_t qc = (word >> 12) & 0x0FFF; if (qc & 0x0800) qc |= 0xF000;
        
        float a = float(qa) / 64.0f;
        float b = float(qb) / 64.0f;
        float c = float(qc) / 64.0f;
        float2 pos = float2((b - c) * 0.8660254f, a - (b + c) * 0.5f);
        
        float dist = SovereignCore::latticeSnap(length(uv - pos), control.anneal_cooling);
        float dot_intensity = smoothstep(0.02, 0.0, dist) * (float((word >> 24) & 0xFF) / 255.0f);
        raw_r = max(raw_r, dot_intensity);
        raw_g = max(raw_g, dot_intensity);
        raw_b = max(raw_b, dot_intensity);
    }

    // 3. SOVEREIGN LINEARIZATION
    float3 energy = saturate(float3(raw_r, raw_g, raw_b));
    float3 background = float3(0.005, 0.005, 0.01); 
    float3 signal = float3(0.0, 1.0, 0.8);          
    float3 final = pow(mix(background, signal, energy), 1.0f / 2.2f);

    outTexture.write(float4(final, 1.0f), gid);
}
