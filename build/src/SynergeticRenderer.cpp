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
    _velocityRotor = SurdRotor::identity();
    _comparisonMatrix = matrix_identity_float4x4;
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
    std::ifstream file("src/SynergeticKernelFinal.metal");
    if (!file.is_open()) {
        std::cerr << "CRITICAL ERROR: Could not find src/SynergeticKernelFinal.metal" << std::endl;
        return;
    }
    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string sourceStr = buffer.str();
    std::cout << "[Shader Load] First 60 chars: " << sourceStr.substr(0, 60) << "..." << std::endl;
    NS::String* source = NS::String::string(sourceStr.c_str(), NS::UTF8StringEncoding);
    MTL::Library* library = _device->newLibrary(source, nullptr, &error);
    if (!library) {
        std::cerr << "Failed to load library: " << (error ? error->localizedDescription()->utf8String() : "Unknown Error") << std::endl;
        return;
    }
    // MASTER RESET: Load authoritative master kernel
    MTL::Function* function = library->newFunction(NS::String::string("renderSynergeticV9_Master", NS::UTF8StringEncoding));
    if (!function) {
        std::cerr << "CRITICAL ERROR: Function 'renderSynergeticV9_Master' not found." << std::endl;
        return;
    }
    _computePipeline = _device->newComputePipelineState(function, &error);
    function->release();
    library->release();
}

void MetalRenderer::draw(void* layerPtr) {
    if (!_computePipeline) return;
    CA::MetalLayer* layer = (CA::MetalLayer*)layerPtr;

    _time += 0.016f;
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    CA::MetalDrawable* drawable = layer->nextDrawable();
    if (!drawable) { pool->release(); return; }

    MTL::CommandBuffer* cmdBuf = _commandQueue->commandBuffer();
    MTL::ComputeCommandEncoder* encoder = cmdBuf->computeCommandEncoder();
    encoder->setComputePipelineState(_computePipeline);
    encoder->setTexture(drawable->texture(), 0);
    
    simd::float4 timeData = {_time, 0, 0, 0};
    encoder->setBytes(&timeData, sizeof(timeData), 0);
    
    // Fresh Rationalization
    float angle = _time * 0.05f;
    float w = cos(angle * 0.5f);
    float s = sin(angle * 0.5f);
    long D = 100000000L;
    
    _rotor.w = { (int64_t)(w * D), 0, D };
    _rotor.x = { (int64_t)(s * D), 0, D };
    _rotor.y = { 0, 0, D };
    _rotor.z = { 0, 0, D };

    // CALCULUS: Instantaneous velocity
    float dw = -0.05f * 0.5f * sin(angle * 0.5f);
    float ds =  0.05f * 0.5f * cos(angle * 0.5f);
    _velocityRotor.w = { (int64_t)(dw * D), 0, D };
    _velocityRotor.x = { (int64_t)(ds * D), 0, D };
    _velocityRotor.y = { 0, 0, D };
    _velocityRotor.z = { 0, 0, D };
    
    // ALGEBRAIC DRIVER
    RationalSurd wobble = RationalSurd::oscillator((int64_t)(_time * 1000.0f), 2000L);
    
    // COMPATIBILITY: Convert to 16-byte aligned 32-bit for Intel Broadwell GPU
    SurdRotor32 gpuRotor = SurdRotor32::fromRotor(_rotor);
    SurdRotor32 gpuVelocity = SurdRotor32::fromRotor(_velocityRotor);
    Surd32 gpuWobble = Surd32::fromSurd(wobble);

    encoder->setBytes(&gpuRotor, sizeof(gpuRotor), 1);
    encoder->setBytes(&gpuVelocity, sizeof(gpuVelocity), 2);
    encoder->setBytes(&gpuWobble, sizeof(gpuWobble), 3);
    
    MTL::Size gridSize = MTL::Size(drawable->texture()->width(), drawable->texture()->height(), 1);
    MTL::Size threadGroupSizeVec = MTL::Size(8, 8, 1);
    encoder->dispatchThreads(gridSize, threadGroupSizeVec);
    encoder->endEncoding();
    cmdBuf->presentDrawable(drawable);
    cmdBuf->commit();
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
    _time = 0.0f;
}

VulkanRenderer::~VulkanRenderer() {
    SDL_DestroyGPUDevice(_gpuDevice);
}

void VulkanRenderer::toggleJanus() {
    _rotor.janus *= -1;
    std::cout << "Janus Polarity Flipped (Vulkan): " << (_rotor.janus > 0 ? "+" : "-") << std::endl;
}

void VulkanRenderer::draw(void* unused) {
    _time += 0.016f;
}

} // namespace Synergetics
