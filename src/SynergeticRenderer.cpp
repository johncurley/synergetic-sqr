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
    _rotor = SQRotor::identity();
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
    _rotor.janus *= -1.0f;
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
    
    // SMOOTH UPDATE: Small increment (approx 0.3 degrees)
    float deltaAngle = 0.005f; 
    SQRotor deltaRotor = SQRotor::fromAxisAngle(Axis::W, deltaAngle);
    _rotor = _rotor.multiply(deltaRotor);
    
    // DRIFT CHECK: Update standard Matrix for comparison
    simd::float4x4 deltaMatrix = SQRotor::axisRotationMatrix(Axis::W, deltaAngle, 1.0f);
    _comparisonMatrix = simd_mul(_comparisonMatrix, deltaMatrix);
    
    // Periodically log drift (magnitude error)
    if ((int)(_time * 60.0f) % 600 == 0) { // Every ~10 seconds
        float rotorMag = simd::length(_rotor.coords);
        float matrixMag = simd::length(_comparisonMatrix.columns[1]); 
        std::cout << "[SQR Stability Proof] Time: " << _time << "s" << std::endl;
        std::cout << "  SQR Float Drift:   " << std::abs(1.0f - rotorMag) << std::endl;
        std::cout << "  Mat4 Matrix Drift: " << std::abs(1.0f - matrixMag) << std::endl;
        
        // SQR renormalization
        if (std::abs(1.0f - rotorMag) > 1e-6f) {
            _rotor.coords = simd::normalize(_rotor.coords);
        }
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
