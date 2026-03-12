#ifndef SYNERGETIC_RENDERER_HPP
#define SYNERGETIC_RENDERER_HPP

#include <SDL3/SDL.h>

#ifdef __APPLE__
#include <simd/simd.h>
#include <QuartzCore/QuartzCore.hpp>
#include <Metal/Metal.hpp>
#endif

#include "spu/SynergeticsMath.hpp"

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
    virtual void strike(uint16_t vector) = 0;
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
    void strike(uint16_t vector) override {
        // Map 16-bit vector to prime phase for visual feedback
        if (vector & 0x000F) _primePhase = 0;
        else if (vector & 0x00F0) _primePhase = 1;
        else if (vector & 0x0F00) _primePhase = 2;
        else if (vector & 0xF000) _primePhase = 3;
        _tickCount++; 
    }
    void ground() override { 
        _layer = -1; _harmonic = false; _latticeLock = true; _dssEnabled = true;
        std::cout << "WATCHDOG: Somatic Reset Triggered. Manifold Grounded." << std::endl;
    }

private:
    void buildComputePipeline();

    struct SPUControl {
        uint32_t tick;
        int32_t layer;
        uint32_t prime_phase;
        uint32_t dss_enabled;   
        uint32_t coherence;     
        uint32_t harmonic_mode; 
        uint32_t lattice_lock;  
    };

    MTL::Device* _device;
    MTL::CommandQueue* _commandQueue;
    MTL::ComputePipelineState* _computePipeline;
    
    int _janus = 1;
    bool _dssEnabled = false;
    uint64_t _tickCount = 0;
    int _layer = 0;
    uint32_t _primePhase = 0;
    bool _harmonic = false;
    bool _latticeLock = false;
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
    void strike(uint16_t vector) override { _tickCount++; }
    void ground() override { 
        _layer = -1; _harmonic = false; _latticeLock = true; _dssEnabled = true;
    }

private:
    SDL_GPUDevice* _gpuDevice;
    SDL_GPUComputePipeline* _computePipeline;
    
    int _janus = 1;
    bool _dssEnabled = false;
    uint64_t _tickCount = 0;
    int _layer = 0;
    bool _harmonic = false;
    bool _latticeLock = false;
    CoherenceMonitor _coherence;
};

} // namespace Synergetics

#endif
