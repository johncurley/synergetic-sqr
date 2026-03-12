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
    _layer = -1;        // DEFAULT: Mode D (Pure IVM Metric)
    _harmonic = false;
    _latticeLock = true; // DEFAULT: GROUNDED
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
        "DQFA.metal",
        "./DQFA.metal",
        "../demos/renderer/DQFA.metal",
        "demos/renderer/DQFA.metal",
        "src/DQFA.metal"
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
        std::cout << "SUCCESS: SPU-13 Kernel (DQFA) Manifested at: " << finalPath << std::endl;
    } else {
        std::cerr << "CRITICAL ERROR: DQFA.metal not found in any search path." << std::endl;
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
    if (!_computePipeline || !layerPtr) return;
    
    // 1. Establish the Sovereign Memory Pool
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    
    CA::MetalLayer* layer = (CA::MetalLayer*)layerPtr;
    CA::MetalDrawable* drawable = layer->nextDrawable();
    
    // 2. The Gasket Guard: Ensure the vessel is ready for light
    if (!drawable || !drawable->texture()) {
        pool->release();
        return;
    }

    // 3. Step the Digital Twin (Laminar Evolution)
    try {
        _forge.step();
    } catch (...) {
        std::cerr << "[FORGE] Dissonance detected during step. Skipping cycle." << std::endl;
    }

    MTL::CommandBuffer* cmdBuf = _commandQueue->commandBuffer();
    if (!cmdBuf) {
        pool->release();
        return;
    }

    MTL::ComputeCommandEncoder* encoder = cmdBuf->computeCommandEncoder();
    if (!encoder) {
        pool->release();
        return;
    }

    encoder->setComputePipelineState(_computePipeline);
    encoder->setTexture(drawable->texture(), 0);
    
    // 4. State Sync (Crystalline Alignment)
    Synergetics::SPUControl forgeControl = _forge.getControl();
    SPUControl control;
    control.tick = forgeControl.tick;
    control.layer = forgeControl.layer;
    control.prime_phase = forgeControl.prime_phase;
    control.coherence = forgeControl.coherence;

    // Inject dynamic UI overrides
    control.dss_enabled = _dssEnabled ? 1u : 0u;
    control.harmonic_mode = _harmonic ? 1u : 0u;
    control.lattice_lock = _latticeLock ? 1u : 0u;
    control.bio_security = _bioSecurity;
    control.tau_threshold = forgeControl.tau_threshold;
    for(int i=0; i<4; i++) control.rotor_bias[i] = forgeControl.rotor_bias[i];

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
    
    // 5. Release the Pool
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
    _layer = -1;        // DEFAULT: Mode D (Pure IVM Metric)
    _harmonic = false;
    _latticeLock = true; // DEFAULT: GROUNDED
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
    bool isLocked = _coherence.update(_janus > 0);
    
    // In a full implementation, we would:
    // 1. Acquire Command Buffer
    // 2. Begin Compute Pass
    // 3. Bind Pipeline & Textures
    // 4. Update Push Constants (fgh coefficients + coherence)
    // 5. Dispatch
    // 6. Submit & Present
    
    if (_tickCount % 600 == 0) {
        std::cout << "[Vulkan Sync Verification] Tick: " << _tickCount << " | Layer: " << _layer << " | DSS: " << (_dssEnabled ? "ON" : "OFF") << " | Coherence: " << (isLocked ? "LOCKED" : "STALLED") << std::endl;
    }
}

} // namespace Synergetics
