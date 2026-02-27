#ifndef SYNERGETIC_RENDERER_HPP
#define SYNERGETIC_RENDERER_HPP

#include <SDL3/SDL.h>
#include <simd/simd.h>
#include <QuartzCore/QuartzCore.hpp>
#include <Metal/Metal.hpp>
#include "SynergeticsMath.hpp"

namespace Synergetics {

class IRenderer {
public:
    virtual ~IRenderer() {}
    virtual void draw(void* layer) = 0;
    virtual void toggleJanus() = 0;
    virtual long getJanus() const = 0;
};

class MetalRenderer : public IRenderer {
public:
    MetalRenderer(MTL::Device* device);
    ~MetalRenderer();
    
    void draw(void* layer) override;
    void toggleJanus() override;
    long getJanus() const override { return _rotor.janus; }

private:
    void buildComputePipeline();

    MTL::Device* _device;
    MTL::CommandQueue* _commandQueue;
    MTL::ComputePipelineState* _computePipeline;
    MTL::Buffer* _veBuffer;
    MTL::Buffer* _octBuffer;
    MTL::Buffer* _edgeBuffer;
    
    SurdRotor _rotor;
    SurdRotor _velocityRotor; // The infinitesimal part of the rotor
    simd::float4x4 _comparisonMatrix;
    float _time = 0.0f;
};

class VulkanRenderer : public IRenderer {
public:
    VulkanRenderer(SDL_Window* window);
    ~VulkanRenderer();
    
    void draw(void* unused) override;
    void toggleJanus() override;
    long getJanus() const override { return _rotor.janus; }

private:
    SDL_GPUDevice* _gpuDevice;
    SDL_GPUComputePipeline* _computePipeline;
    
    SurdRotor _rotor;
    float _time = 0.0f;
};

} // namespace Synergetics

#endif
