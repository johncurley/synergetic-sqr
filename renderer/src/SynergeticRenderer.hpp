#ifndef SYNERGETIC_RENDERER_HPP
#define SYNERGETIC_RENDERER_HPP

#include <SDL3/SDL.h>

#ifdef __APPLE__
#include <simd/simd.h>
#include <QuartzCore/QuartzCore.hpp>
#include <Metal/Metal.hpp>
#endif

#include "SynergeticsMath.hpp"

namespace Synergetics {

class IRenderer {
public:
    virtual ~IRenderer() {}
    virtual void draw(void* layer) = 0;
    virtual void toggleJanus() = 0;
    virtual long getJanus() const = 0;
    virtual void toggleDSS() = 0;
    virtual bool getDSS() const = 0;
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

private:
    void buildComputePipeline();

    struct SurdRotorFixed {
        SurdFixed64 w, x;
        int janus;
    };

    struct SPUControl {
        uint32_t tick;
        int32_t rot_count;
        uint32_t prime_phase;
        uint32_t dss_enabled; // REG_DSS: 0=OFF, 1=ON
    };

    MTL::Device* _device;
    MTL::CommandQueue* _commandQueue;
    MTL::ComputePipelineState* _computePipeline;
    
    int _janus = 1;
    bool _dssEnabled = false;
    uint64_t _tickCount = 0;
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

private:
    SDL_GPUDevice* _gpuDevice;
    SDL_GPUComputePipeline* _computePipeline;
    
    int _janus = 1;
    bool _dssEnabled = false;
    uint64_t _tickCount = 0;
};

} // namespace Synergetics

#endif
