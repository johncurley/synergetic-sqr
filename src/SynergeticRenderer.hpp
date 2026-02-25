#ifndef RENDERER_HPP
#define RENDERER_HPP

#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>
#include <simd/simd.h>
#include "SynergeticsMath.hpp"

class SynergeticRenderer {
public:
    SynergeticRenderer(MTL::Device* device);
    ~SynergeticRenderer();
    
    void draw(CA::MetalLayer* layer);

private:
    void buildComputePipeline();

    MTL::Device* _device;
    MTL::CommandQueue* _commandQueue;
    MTL::ComputePipelineState* _computePipeline;
    MTL::Buffer* _veBuffer;
    MTL::Buffer* _octBuffer;
    MTL::Buffer* _edgeBuffer;
    
    Synergetics::SurdRotor _rotor;
    simd::float4x4 _comparisonMatrix;
    float _time = 0.0f;
    
public:
    void toggleJanus();
};

#endif
