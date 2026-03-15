#ifndef SYNERGETIC_RENDERER_HPP
#define SYNERGETIC_RENDERER_HPP

#include <SDL3/SDL.h>

#ifdef __APPLE__
#include <simd/simd.h>
#include <QuartzCore/QuartzCore.hpp>
#include <Metal/Metal.hpp>
#endif

#include "spu/SynergeticsMath.hpp"
#include "spu/SovereignISA.hpp"
#include "LithicForge.hpp"
#include <vector>

namespace Synergetics {

class IRenderer {
public:
    virtual ~IRenderer() {}
    virtual void draw(void* layer) = 0;
    virtual void toggleJanus() = 0;
    virtual long getJanus() const = 0;
    virtual void toggleDSS() = 0;
    virtual bool getDSS() const = 0;
    virtual void setLayer(int layer) = 0;
    virtual int getLayer() const = 0;
    virtual void toggleHarmonic() = 0;
    virtual bool isHarmonic() const = 0;
    virtual void toggleLatticeLock() = 0;
    virtual bool isLatticeLocked() const = 0;
    virtual void toggleTension() = 0; // Toggle between Cubic (90) and IVM (60)
    virtual bool isCartesian() const = 0; // NEW: Get Knot-Breaker status
    virtual void cycleBioSecurity() = 0; 
    virtual void cycleAnnealing() = 0; // NEW: 0.0 to 1.0 

    // --- SOVEREIGN COMMAND INTERFACE ---
    virtual void dispatchCommand(const SovereignCommand& cmd) = 0;
    virtual void flushCommands() = 0;

    virtual void strike(uint16_t vector) = 0;
    virtual void processGeometric(uint8_t op, uint8_t axis, uint8_t val) = 0;
    virtual bool loadHex(const std::string& path) = 0;
    virtual void spawnNode(uint32_t type) = 0;
    virtual void ground() = 0; 
};

class MetalRenderer : public IRenderer {
public:
    MetalRenderer(MTL::Device* device);
    ~MetalRenderer();
    
    void draw(void* layer) override;
    void toggleJanus() override;
    long getJanus() const override { return _janus; }
    void toggleDSS() override;
    bool getDSS() const override { return _dssEnabled; }
    void setLayer(int layer) override { _layer = layer; }
    int getLayer() const override { return _layer; }
    void toggleHarmonic() override { _harmonic = !_harmonic; }
    bool isHarmonic() const override { return _harmonic; }
    void toggleLatticeLock() override { _latticeLock = !_latticeLock; }
    bool isLatticeLocked() const override { return _latticeLock; }
    void toggleTension() override { _tensionToggle = !_tensionToggle; }
    bool isCartesian() const override { return _tensionToggle; } // NEW
    void cycleBioSecurity() override { _bioSecurity = (_bioSecurity + 1) % 11; }
    void cycleAnnealing() override { _annealFactor += 0.25f; if (_annealFactor > 1.0f) _annealFactor = 0.0f; }
    
    void dispatchCommand(const SovereignCommand& cmd) override { _commandBuffer.push_back(cmd.compile()); }
    void flushCommands() override { _commandBuffer.clear(); }

    void strike(uint16_t vector) override { 
        if (vector & 0x000F) _forge.processGeometric(0, 0, 10);
        else if (vector & 0x00F0) _forge.processGeometric(0, 1, 10);
        else if (vector & 0x0F00) _forge.processGeometric(0, 2, 10);
        else if (vector & 0xF000) _forge.processGeometric(0, 3, 10);
    }
    void processGeometric(uint8_t op, uint8_t axis, uint8_t val) override { _forge.processGeometric(op, axis, val); }
    bool loadHex(const std::string& path) override { return _forge.loadHex(path); }
    void spawnNode(uint32_t type) override { _forge.spawnNode(type); }
    void ground() override { 
        _layer = -1; _harmonic = false; _latticeLock = true; _dssEnabled = true;
        std::cout << "WATCHDOG: Somatic Reset Triggered. Manifold Grounded." << std::endl;
    }

private:
    void buildComputePipeline();

    struct SurdRotorFixed {
        SurdFixed64 w, x;
        int janus;
    };

    struct SPUControl {
        uint32_t tick;
        int32_t layer;
        uint32_t prime_phase;
        uint32_t dss_enabled;   
        uint32_t coherence;     
        uint32_t harmonic_mode; 
        uint32_t lattice_lock;  
        uint32_t bio_security; 
        uint32_t is_cartesian_display; // NEW: Knot-Breaker Toggle
        float    tau_threshold; 
        float    rotor_bias[4]; 
        float    anneal_cooling; // NEW
    };

    MTL::Device* _device;
    MTL::CommandQueue* _commandQueue;
    MTL::ComputePipelineState* _computePipeline;
    
    LithicForge _forge;
    std::vector<uint64_t> _commandBuffer;
    int _janus = 1;
    bool _dssEnabled = false;
    uint64_t _tickCount = 0;
    int _layer = 0;
    uint32_t _primePhase = 0;
    bool _harmonic = false;
    bool _latticeLock = false;
    bool _tensionToggle = false;
    float _annealFactor = 0.0f;
    uint32_t _bioSecurity = 0;
    CoherenceMonitor _coherence;
};

class VulkanRenderer : public IRenderer {
public:
    VulkanRenderer(SDL_Window* window);
    ~VulkanRenderer();
    
    void draw(void* unused) override;
    void toggleJanus() override;
    long getJanus() const override { return _janus; }
    void toggleDSS() override;
    bool getDSS() const override { return _dssEnabled; }
    void setLayer(int layer) override { _layer = layer; }
    int getLayer() const override { return _layer; }
    void toggleHarmonic() override { _harmonic = !_harmonic; }
    bool isHarmonic() const override { return _harmonic; }
    void toggleLatticeLock() override { _latticeLock = !_latticeLock; }
    bool isLatticeLocked() const override { return _latticeLock; }
    void toggleTension() override;
    bool isCartesian() const override { return _isCartesian; } // NEW
    void cycleBioSecurity() override { _bioSecurity = (_bioSecurity + 1) % 11; }
    void cycleAnnealing() override { _annealFactor += 0.25f; if (_annealFactor > 1.0f) _annealFactor = 0.0f; }

    void dispatchCommand(const SovereignCommand& cmd) override { _commandBuffer.push_back(cmd.compile()); }
    void flushCommands() override { _commandBuffer.clear(); }

    void strike(uint16_t vector) override { _tickCount++; }
    void processGeometric(uint8_t op, uint8_t axis, uint8_t val) override {}
    bool loadHex(const std::string& path) override { return false; }
    void spawnNode(uint32_t type) override {}
    void ground() override { 
        _layer = -1; _harmonic = false; _latticeLock = true; _dssEnabled = true;
    }

private:
    SDL_GPUDevice* _gpuDevice;
    SDL_GPUComputePipeline* _computePipeline;
    std::vector<uint64_t> _commandBuffer;
    
    int _janus = 1;
    bool _dssEnabled = false;
    uint64_t _tickCount = 0;
    int _layer = 0;
    bool _harmonic = false;
    bool _latticeLock = false;
    bool _isCartesian = true;
    float _annealFactor = 0.0f;
    uint32_t _bioSecurity = 0;
    CoherenceMonitor _coherence;
};

} // namespace Synergetics

#endif
