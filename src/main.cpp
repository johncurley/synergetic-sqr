#include <SDL3/SDL.h>
#include <iostream>
#include "SynergeticRenderer.hpp"
#include "SynergeticsMath.hpp"

#ifdef __APPLE__
#import <AppKit/AppKit.h>
#endif

using namespace Synergetics;

int main(int argc, char* argv[]) {
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Use Metal flags on Apple, but SDL handles the cross-platform creation
    Uint32 windowFlags = SDL_WINDOW_RESIZABLE;
#ifdef __APPLE__
    windowFlags |= SDL_WINDOW_METAL;
#endif

    SDL_Window* window = SDL_CreateWindow(
        "Synergetic Renderer - Cross-Platform Architecture",
        800, 600,
        windowFlags
    );

    if (!window) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // 1. Backend Selection
    IRenderer* renderer = nullptr;
    void* metalView = nullptr;
    MTL::Device* device = nullptr;
    CA::MetalLayer* layer = nullptr;

#ifdef __APPLE__
    // Setup Metal Backend (Native High Performance)
    metalView = SDL_Metal_CreateView(window);
    layer = (CA::MetalLayer*)SDL_Metal_GetLayer(metalView);
    device = MTL::CreateSystemDefaultDevice();
    layer->setDevice(device);
    layer->setPixelFormat(MTL::PixelFormatBGRA8Unorm);
    // STABILITY FIX: Prevent drawable timeouts and optimize for display
    layer->setAllowsNextDrawableTimeout(false);
    layer->setFramebufferOnly(true);
    
    renderer = new MetalRenderer(device);
#else
    // Linux/Windows: Use SDL_gpu / Vulkan
    renderer = new VulkanRenderer(window);
#endif

    std::cout << "--- Sovereign Identity Proof (The DQFA Epoch) ---" << std::endl;
    // 1. Initialize a Quadray at a known rational point {1, 0, 0, 0}
    Synergetics::Quadray4 original_pos = Synergetics::Quadray4::identity();
    Synergetics::Quadray4 current_pos = original_pos;

    // 2. Perform a "Full Circuit" (Six 60-degree rotations = 360 degrees)
    // In the SPU, this is 6 calls to the Shift-Register Permutator (_spu_rotate_60)
    for (int i = 0; i < 6; i++) {
        current_pos = Synergetics::Quadray4::_spu_rotate_60(current_pos);
    }

    // 3. The Sovereign Check: Bit-Level Comparison
    bool is_identical = current_pos.equals(original_pos);

    if (is_identical) {
        // Nature does not lie.
        std::cout << "IDENTITY PROOF: PASSED" << std::endl;
        std::cout << "  Drift: 0.0000000000000000" << std::endl;
        std::cout << "  Sovereign Identity Verified (65536)." << std::endl;
    } else {
        // If this fails, the 'ghastly floats' or improper overflows are still present.
        std::cerr << "IDENTITY PROOF: FAILED" << std::endl;
        std::cerr << "  Bit-drift detected in the DQFA Permutator Pipeline!" << std::endl;
    }
    std::cout << "---------------------------------------" << std::endl;

#ifdef __APPLE__
    [NSApp activateIgnoringOtherApps:YES];
#endif

    bool quit = false;
    SDL_Event e;
    const int FPS = 60;
    const int frameDelay = 1000 / FPS;

    Uint64 frameStart;
    int frameTime;

    while (!quit) {
        frameStart = SDL_GetTicks();

        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_EVENT_QUIT) {
                quit = true;
            } else if (e.type == SDL_EVENT_KEY_DOWN) {
                if (e.key.key == SDLK_SPACE) {
                    renderer->toggleJanus();
                    const char* title = (renderer->getJanus() > 0) ? 
                        "Synergetic Renderer (Janus +)" : "Synergetic Renderer (Janus -)";
                    SDL_SetWindowTitle(window, title);
                }
            }
        }

        // Only draw if window is not minimized/hidden
        Uint32 flags = SDL_GetWindowFlags(window);
        if (!(flags & SDL_WINDOW_HIDDEN) && !(flags & SDL_WINDOW_MINIMIZED)) {
            renderer->draw(layer);
        }

        // CPU Sleep: Cap to 60 FPS
        frameTime = SDL_GetTicks() - frameStart;
        if (frameDelay > frameTime) {
            SDL_Delay(frameDelay - frameTime);
        }
    }

    delete renderer;
#ifdef __APPLE__
    SDL_Metal_DestroyView(metalView);
    device->release();
#endif
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
