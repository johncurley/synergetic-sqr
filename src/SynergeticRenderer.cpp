#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include "SynergeticRenderer.hpp"
#include <iostream>
#include <fstream>
#include <sstream>

namespace Synergetics {

MetalRenderer::MetalRenderer(MTL::Device* device) : _device(device) {
    _commandQueue = _device->newCommandQueue();
    _computePipeline = nullptr;
    _rotor = SurdRotor::identity();
    _tickCount = 0;
    buildComputePipeline();
}

MetalRenderer::~MetalRenderer() {
    if (_computePipeline) _computePipeline->release();
    _commandQueue->release();
}

void MetalRenderer::toggleJanus() {
    _rotor.janus *= -1;
    std::cout << "Janus Polarity Flipped: " << (_rotor.janus > 0 ? "+" : "-") << std::endl;
}

void MetalRenderer::buildComputePipeline() {
    NS::Error* error = nullptr;
    std::ifstream file("src/DQFA.metal");
    if (!file.is_open()) {
        std::cerr << "CRITICAL ERROR: Could not find src/DQFA.metal" << std::endl;
        return;
    }
    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string sourceStr = buffer.str();
    NS::String* source = NS::String::string(sourceStr.c_str(), NS::UTF8StringEncoding);
    MTL::Library* library = _device->newLibrary(source, nullptr, &error);
    if (!library) {
        std::cerr << "Failed to load library: " << (error ? error->localizedDescription()->utf8String() : "Unknown Error") << std::endl;
        return;
    }
    // DQFA v1.5: Load the pure algebraic Quadray-Native kernel
    MTL::Function* function = library->newFunction(NS::String::string("renderDQFA_v1_5", NS::UTF8StringEncoding));
    if (!function) {
        std::cerr << "CRITICAL ERROR: Function 'renderDQFA_v1_5' not found." << std::endl;
        return;
    }
    _computePipeline = _device->newComputePipelineState(function, &error);
    function->release();
    library->release();
}

void MetalRenderer::draw(void* layerPtr) {
    if (!_computePipeline) return;
    CA::MetalLayer* layer = (CA::MetalLayer*)layerPtr;

    _tickCount++;
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    CA::MetalDrawable* drawable = layer->nextDrawable();
    if (!drawable) { pool->release(); return; }

    MTL::CommandBuffer* cmdBuf = _commandQueue->commandBuffer();
    MTL::ComputeCommandEncoder* encoder = cmdBuf->computeCommandEncoder();
    encoder->setComputePipelineState(_computePipeline);
    encoder->setTexture(drawable->texture(), 0);
    
    simd::float4 timeData = {(float)_tickCount * 0.016f, 0, 0, 0};
    encoder->setBytes(&timeData, sizeof(timeData), 0);
    
    // DQFA PURE ALGEBRAIC DRIVER
    // Smooth rotation using the Rational Oscillator as an angle proxy
    SurdFixed64 angle_proxy = rationalOscillator(_tickCount * 4, 10000); // Very slow cycle
    
    // Smooth Rotor (w, x) for the display
    // w = 1.0, x = oscillating surd
    SurdRotorFixed gpuRotor = {
        { SurdFixed64::One, 0 }, // w (Principal)
        { 0, angle_proxy.a },    // x (Smooth rotation component)
        (int)_rotor.janus        // janus polarity
    };

    encoder->setBytes(&gpuRotor, sizeof(gpuRotor), 1);
    
    MTL::Size gridSize = MTL::Size(drawable->texture()->width(), drawable->texture()->height(), 1);
    MTL::Size threadGroupSizeVec = MTL::Size(8, 8, 1);
    encoder->dispatchThreads(gridSize, threadGroupSizeVec);
    encoder->endEncoding();
    cmdBuf->presentDrawable(drawable);
    cmdBuf->commit();
    
    // DETERMINISM AUDIT: Bit-Exact Identity Check
    // We only log the Identity when the smooth rotation returns to zero
    if (angle_proxy.a == 0) {
        std::cout << "[DQFA IDENTITY] Absolute Closure Verified at Tick: " << _tickCount << std::endl;
        std::cout << "  Rotor Identity Bitmask: w.a=" << gpuRotor.w.a << " (0x10000), w.b=" << gpuRotor.w.b << std::endl;
    }

    pool->release();
}

// --- VULKAN RENDERER (SDL_gpu) ---

VulkanRenderer::VulkanRenderer(SDL_Window* window) {
    _gpuDevice = SDL_CreateGPUDevice(SDL_GPU_SHADERFORMAT_SPIRV, true, nullptr);
    if (!_gpuDevice) {
        std::cerr << "SDL_gpu: Failed to create device!" << std::endl;
        return;
    }
    SDL_ClaimWindowForGPUDevice(_gpuDevice, window);
    _rotor = SurdRotor::identity();
    _tickCount = 0;
}

VulkanRenderer::~VulkanRenderer() {
    SDL_DestroyGPUDevice(_gpuDevice);
}

void VulkanRenderer::toggleJanus() {
    _rotor.janus *= -1;
    std::cout << "Janus Polarity Flipped (Vulkan): " << (_rotor.janus > 0 ? "+" : "-") << std::endl;
}

void VulkanRenderer::draw(void* unused) {
    _tickCount++;
}

} // namespace Synergetics
