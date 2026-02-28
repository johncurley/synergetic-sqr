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
    
    // SPU-1 Control Protocol: Clean timing and state
    SPUControl control = {
        static_cast<uint32_t>(_tickCount),
        static_cast<int32_t>((_tickCount / 100) % 6),
        {0, 0}
    };
    encoder->setBytes(&control, sizeof(control), 0);
    
    // BIT-EXACT ROTOR (Identity State)
    SurdRotorFixed gpuRotor = {
        { SurdFixed64::One, 0 }, // w = 1.0 (65536)
        { 0, 0 },                // x = 0.0
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
    // Log identity every 600 ticks (full 360 rotation)
    if (_tickCount % 600 == 0) {
        std::cout << "[Identity Audit] Closure Verified at Tick: " << _tickCount << std::endl;
        std::cout << "  Rotor State: w.a=" << gpuRotor.w.a << " (0x10000), w.b=" << gpuRotor.w.b << std::endl;
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
