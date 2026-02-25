#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include "SynergeticRenderer.hpp"
#include "SynergeticsMath.hpp"
#include "Models.hpp"
#include <iostream>
#include <fstream>
#include <sstream>

using namespace Synergetics;

SynergeticRenderer::SynergeticRenderer(MTL::Device* device) : _device(device) {
    _commandQueue = _device->newCommandQueue();
    _veBuffer = _device->newBuffer(ve_data, sizeof(ve_data), MTL::ResourceStorageModeShared);
    _octBuffer = _device->newBuffer(oct_data, sizeof(oct_data), MTL::ResourceStorageModeShared);
    _edgeBuffer = _device->newBuffer(jitterbug_edges, sizeof(jitterbug_edges), MTL::ResourceStorageModeShared);
    _rotor = SurdRotor::identity();
    _comparisonMatrix = matrix_identity_float4x4;
    buildComputePipeline();
}

SynergeticRenderer::~SynergeticRenderer() {
    _edgeBuffer->release();
    _octBuffer->release();
    _veBuffer->release();
    _computePipeline->release();
    _commandQueue->release();
}

void SynergeticRenderer::toggleJanus() {
    _rotor.janus *= -1;
    std::cout << "Janus Polarity Flipped: " << (_rotor.janus > 0 ? "+" : "-") << std::endl;
}

void SynergeticRenderer::buildComputePipeline() {
    NS::Error* error = nullptr;
    std::ifstream file("src/SynergeticKernel.metal");
    std::stringstream buffer;
    buffer << file.rdbuf();
    NS::String* source = NS::String::string(buffer.str().c_str(), NS::UTF8StringEncoding);
    MTL::Library* library = _device->newLibrary(source, nullptr, &error);
    if (!library) {
        std::cerr << "Failed to load library: " << (error ? error->localizedDescription()->utf8String() : "Unknown Error") << std::endl;
        return;
    }
    MTL::Function* function = library->newFunction(NS::String::string("renderSynergetic", NS::UTF8StringEncoding));
    _computePipeline = _device->newComputePipelineState(function, &error);
    function->release();
    library->release();
}

void SynergeticRenderer::draw(CA::MetalLayer* layer) {
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
    
    // FRESH RATIONALIZATION: 
    // Instead of compounding error (rotor * delta), we calculate a fresh
    // bit-exact RationalSurd for the current frame.
    float angle = _time * 0.05f; // Meditative, extremely slow rotation
    float w = cos(angle * 0.5f);
    float s = sin(angle * 0.5f);
    
    long D = 1000000000L; // Fixed denominator for frame-local precision
    _rotor.w = { (long)(w * D), 0, D };
    _rotor.x = { (long)(s * D), 0, D };
    _rotor.y = { 0, 0, D };
    _rotor.z = { 0, 0, D };
    // janus remains persistent
    
    // DRIFT CHECK: Update standard Matrix for baseline comparison
    simd::float4x4 deltaMatrix = SQRotor::axisRotationMatrix(Axis::W, 0.001f, 1.0f);
    _comparisonMatrix = simd_mul(_comparisonMatrix, deltaMatrix);
    
    // Periodically log
    if ((int)(_time * 60.0f) % 600 == 0) { 
        std::cout << "[Meditative Surd Pipeline] Time: " << _time << "s" << std::endl;
        std::cout << "  Providing GPU with exact RationalSurd for frame " << (int)(_time*60) << std::endl;
        std::cout << "  Matrix Drift (Baseline): " << std::abs(1.0f - simd::length(_comparisonMatrix.columns[1])) << std::endl;
    }
    
    encoder->setBytes(&_rotor, sizeof(_rotor), 1);
    
    encoder->setBuffer(_veBuffer, 0, 2);
    encoder->setBuffer(_octBuffer, 0, 3);
    encoder->setBuffer(_edgeBuffer, 0, 4);
    
    MTL::Size gridSize = MTL::Size(drawable->texture()->width(), drawable->texture()->height(), 1);
    MTL::Size threadGroupSizeVec = MTL::Size(8, 8, 1);
    encoder->dispatchThreads(gridSize, threadGroupSizeVec);
    encoder->endEncoding();
    cmdBuf->presentDrawable(drawable);
    cmdBuf->commit();
    pool->release();
}
