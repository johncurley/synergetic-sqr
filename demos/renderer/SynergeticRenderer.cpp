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
    _tensionToggle = true; // EMULATOR DEFAULT: Heal the Cartesian screen
    _bioSecurity = 9;    // DEFAULT: Mode 9
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
        "SovereignKernel.metal",
        "./SovereignKernel.metal",
        "../demos/renderer/SovereignKernel.metal",
        "demos/renderer/SovereignKernel.metal"
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
        std::cout << "SUCCESS: Unified Sovereign Kernel (v1.0) Manifested at: " << finalPath << std::endl;
    } else {
        std::cerr << "CRITICAL ERROR: SovereignKernel.metal not found." << std::endl;
        return;
    }
    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string sourceStr = buffer.str();
    
    // SOVEREIGN NUCLEAR CACHE BUSTER: Rename the entry point uniquely on every startup
    std::string timestamp = std::to_string(std::time(nullptr));
    std::string entryPoint = "renderSovereign_" + timestamp;
    
    // Replace the function name in the source string
    size_t pos = sourceStr.find("renderSovereign_v1");
    if (pos != std::string::npos) {
        sourceStr.replace(pos, 18, entryPoint);
    }

    // Add a unique version comment to bust the cache
    sourceStr = "// v" + timestamp + "\n" + sourceStr;

    NS::String* source = NS::String::string(sourceStr.c_str(), NS::UTF8StringEncoding);
    std::cout << "FORGE: Manifesting Unique Entry Point: " << entryPoint << std::endl;
    
    MTL::Library* library = _device->newLibrary(source, nullptr, &error);
    if (!library) {
        std::cerr << "Failed to load library: " << (error ? error->localizedDescription()->utf8String() : "Unknown Error") << std::endl;
        return;
    }
    MTL::Function* function = library->newFunction(NS::String::string(entryPoint.c_str(), NS::UTF8StringEncoding));
    if (!function) {
        std::cerr << "CRITICAL ERROR: Function '" << entryPoint << "' not found." << std::endl;
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
    control.is_cartesian_display = _tensionToggle ? 1u : 0u; 
    control.tau_threshold = forgeControl.tau_threshold;
    for(int i=0; i<4; i++) control.rotor_bias[i] = forgeControl.rotor_bias[i];
    control.anneal_cooling = _annealFactor;

    encoder->setBytes(&control, sizeof(control), 0);
    
    // Bind the Sovereign Command Buffer (v1.5)
    if (!_commandBuffer.empty()) {
        encoder->setBytes(_commandBuffer.data(), _commandBuffer.size() * sizeof(uint64_t), 1);
    } else {
        // Fallback: Dispatch an Empty Sovereign Word
        uint64_t empty = 0;
        encoder->setBytes(&empty, sizeof(uint64_t), 1);
    }
    
    MTL::Size gridSize = MTL::Size(drawable->texture()->width(), drawable->texture()->height(), 1);
    MTL::Size threadGroupSizeVec = MTL::Size(8, 8, 1);
    encoder->dispatchThreads(gridSize, threadGroupSizeVec);
    encoder->endEncoding();
    
    cmdBuf->presentDrawable(drawable);
    cmdBuf->commit();
    
    // 5. Sovereign Flush
    flushCommands();
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
    _isCartesian = true; // EMULATOR: Always true
    _bioSecurity = 9;    // DEFAULT: Mode 9
    _computePipeline = nullptr;
}

VulkanRenderer::~VulkanRenderer() {
    if (_gpuDevice) {
        SDL_ReleaseWindowFromGPUDevice(_gpuDevice, nullptr);
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

void VulkanRenderer::toggleTension() {
    _isCartesian = !_isCartesian;
    std::cout << "Laminar Tension (Vulkan): " << (_isCartesian ? "CUBIC (Healed)" : "SOVEREIGN (Native)") << std::endl;
}

void VulkanRenderer::draw(void* unused) {
    _tickCount++;
    bool isLocked = _coherence.update(_janus > 0);
    
    // In a full implementation, we would bind the SPUControl UBO here.
    // Ensure is_cartesian_display is passed as 1u to the shader.
    
    if (_tickCount % 600 == 0) {
        std::cout << "[Vulkan Sync Verification] Tick: " << _tickCount << " | Layer: " << _layer << " | DSS: " << (_dssEnabled ? "ON" : "OFF") << " | Coherence: " << (isLocked ? "LOCKED" : "STALLED") << " | Knot-Breaker: " << (_isCartesian ? "ACTIVE" : "OFF") << std::endl;
    }
}

} // namespace Synergetics
