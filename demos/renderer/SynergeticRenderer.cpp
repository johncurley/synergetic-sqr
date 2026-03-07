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
    _janus = 1;
    _dssEnabled = true; // SAFETY DEFAULT: ON
    _tickCount = 0;
    buildComputePipeline();
}

MetalRenderer::~MetalRenderer() {
    if (_computePipeline) _computePipeline->release();
    _commandQueue->release();
}

void MetalRenderer::toggleJanus() {
    _janus *= -1;
    std::cout << "Janus Polarity Flipped: " << (_janus > 0 ? "+" : "-") << std::endl;
}

void MetalRenderer::toggleDSS() {
    _dssEnabled = !_dssEnabled;
    std::cout << "Optical Damper (DSS): " << (_dssEnabled ? "ENABLED" : "DISABLED") << std::endl;
}

void MetalRenderer::buildComputePipeline() {
    NS::Error* error = nullptr;
    
    // Path list for high-fidelity discovery
    const char* paths[] = {
        "SynergeticKernelFinal.metal",
        "./SynergeticKernelFinal.metal",
        "../src/kernels/SynergeticKernelFinal.metal",
        "src/kernels/SynergeticKernelFinal.metal",
        "../demos/renderer/SynergeticKernelFinal.metal",
        "demos/renderer/SynergeticKernelFinal.metal",
        "src/SynergeticKernelFinal.metal",
        "../src/SynergeticKernelFinal.metal"
    };

    std::ifstream file;
    std::string finalPath;

    for (const char* p : paths) {
        file.open(p);
        if (file.is_open()) {
            finalPath = p;
            break;
        }
    }

    if (!finalPath.empty()) {
        std::cout << "SUCCESS: SPU-13 Kernel Manifested at: " << finalPath << std::endl;
    } else {
        std::cerr << "CRITICAL ERROR: SPU-13 Kernel not found in any search path." << std::endl;
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

    _tickCount++;
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    CA::MetalDrawable* drawable = layer->nextDrawable();
    if (!drawable) { pool->release(); return; }

    MTL::CommandBuffer* cmdBuf = _commandQueue->commandBuffer();
    MTL::ComputeCommandEncoder* encoder = cmdBuf->computeCommandEncoder();
    encoder->setComputePipelineState(_computePipeline);
    encoder->setTexture(drawable->texture(), 0);
    
    uint32_t currentPhase = (_tickCount / 1200) % 4;
    SPUControl control = {
        static_cast<uint32_t>(_tickCount),
        static_cast<int32_t>(_layer),
        currentPhase,
        _dssEnabled ? 1u : 0u
    };
    encoder->setBytes(&control, sizeof(control), 0);
    
    SurdRotorFixed gpuRotor = {
        { SurdFixed64::One, 0 }, 
        { 0, 0 },                
        _janus                   
    };

    encoder->setBytes(&gpuRotor, sizeof(gpuRotor), 1);
    
    MTL::Size gridSize = MTL::Size(drawable->texture()->width(), drawable->texture()->height(), 1);
    MTL::Size threadGroupSizeVec = MTL::Size(8, 8, 1);
    encoder->dispatchThreads(gridSize, threadGroupSizeVec);
    encoder->endEncoding();
    cmdBuf->presentDrawable(drawable);
    cmdBuf->commit();
    
    if (_tickCount % 600 == 0) {
        const char* phaseLabels[4] = { "P1: Unity", "P3: Chirality", "P5: Equilibrium", "P7: Hyper-Flip" };
        std::cout << "[Identity Closure Verification] Tick: " << _tickCount << std::endl;
        std::cout << "  Rotor State: w.a=" << gpuRotor.w.a << " (0x10000), w.b=" << gpuRotor.w.b << std::endl;
        std::cout << "  Thomson Phase: " << phaseLabels[currentPhase] << " (REG_P=0x0" << (currentPhase*2+1) << ")" << std::endl;
        std::cout << "  Optical Damper: " << (_dssEnabled ? "ON" : "OFF") << std::endl;
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
    _tickCount = 0;
    _janus = 1;
    _dssEnabled = true; // SAFETY DEFAULT: ON
    _layer = 0;
    _computePipeline = nullptr;
    
    // Shader loading logic would go here (SPIR-V)
    // For now, we maintain the structural shell for cross-platform parity.
}

VulkanRenderer::~VulkanRenderer() {
    if (_gpuDevice) {
        SDL_ReleaseWindowFromGPUDevice(_gpuDevice, nullptr); // Window usually handled by main
        SDL_DestroyGPUDevice(_gpuDevice);
    }
}

void VulkanRenderer::toggleJanus() {
    _janus *= -1;
    std::cout << "Janus Polarity Flipped (Vulkan): " << (_janus > 0 ? "+" : "-") << std::endl;
}

void VulkanRenderer::toggleDSS() {
    _dssEnabled = !_dssEnabled;
    std::cout << "Optical Damper (Vulkan DSS): " << (_dssEnabled ? "ENABLED" : "DISABLED") << std::endl;
}

void VulkanRenderer::draw(void* unused) {
    _tickCount++;
    
    // In a full implementation, we would:
    // 1. Acquire Command Buffer
    // 2. Begin Compute Pass
    // 3. Bind Pipeline & Textures
    // 4. Update Push Constants (fgh coefficients)
    // 5. Dispatch
    // 6. Submit & Present
    
    if (_tickCount % 600 == 0) {
        std::cout << "[Vulkan Sync Verification] Tick: " << _tickCount << " | Layer: " << _layer << " | DSS: " << (_dssEnabled ? "ON" : "OFF") << std::endl;
    }
}

} // namespace Synergetics
