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

    std::cout << "--- Synergetic Determinism Benchmark ---" << std::endl;
    RationalSurd w60 = {0, 1, 2};
    RationalSurd x60 = {1, 0, 2};
    SurdRotor delta = {w60, x60, RationalSurd::zero(), RationalSurd::zero(), 1};
    SurdRotor current = SurdRotor::identity();
    for(int i=0; i<6; i++) current = current.multiply(delta);
    if(current.w.equals(RationalSurd::one())) {
        std::cout << "SUCCESS: Result is BIT-EXACT to identity (Zero Drift)." << std::endl;
    }
    
    // HYPER-SURD CALCULUS BENCHMARK
    std::cout << "--- Hyper-Surd Calculus Benchmark ---" << std::endl;
    // f(x) = x^2. Let's find f(3) and f'(3)
    HyperSurd x = HyperSurd::variable(RationalSurd::fromInt(3));
    HyperSurd result = x.multiply(x); // x * x = x^2
    
    std::cout << "Function f(x) = x^2 at x = 3" << std::endl;
    std::cout << "  f(3)  = " << result.val.toFloat() << " (Expected: 9)" << std::endl;
    std::cout << "  f'(3) = " << result.eps.toFloat() << " (Expected: 6)" << std::endl;
    
    if (result.val.equals(RationalSurd::fromInt(9)) && result.eps.equals(RationalSurd::fromInt(6))) {
        std::cout << "SUCCESS: Derivative is BIT-EXACT (Algebraic Calculus)." << std::endl;
    }

    // TENSEGRITY TENSION BENCHMARK
    std::cout << "--- Tensegrity Tension Benchmark ---" << std::endl;
    // F = k * x. Let's find F and dF/dx for k=10, x=2
    RationalSurd k = RationalSurd::fromInt(10);
    HyperSurd x_disp = HyperSurd::variable(RationalSurd::fromInt(2));
    HyperSurd force = HyperSurd::HookesLaw(x_disp, k);

    std::cout << "Spring Tension F = k*x (k=10, x=2)" << std::endl;
    std::cout << "  Force F      = " << force.val.toFloat() << " (Expected: 20)" << std::endl;
    std::cout << "  Gradient dF  = " << force.eps.toFloat() << " (Expected: 10)" << std::endl;

    if (force.val.equals(RationalSurd::fromInt(20)) && force.eps.equals(RationalSurd::fromInt(10))) {
        std::cout << "SUCCESS: Tension Physics is BIT-EXACT (Zero Drift Dynamic)." << std::endl;
    }

    // RATIONAL PROJECTION BENCHMARK
    std::cout << "--- Rational Projection Benchmark ---" << std::endl;
    // Project x=10, z=5 with focal=2 and offset=0
    RationalSurd px = RationalSurd::fromInt(10);
    RationalSurd pz = RationalSurd::fromInt(5);
    RationalSurd focal = RationalSurd::fromInt(2);
    RationalSurd result_p = px.project(focal, pz, RationalSurd::zero());

    std::cout << "Projecting x=10, z=5 (Focal=2)" << std::endl;
    std::cout << "  Result  = " << result_p.toFloat() << " (Expected: 4)" << std::endl;

    if (result_p.equals(RationalSurd::fromInt(4))) {
        std::cout << "SUCCESS: Projection is BIT-EXACT (Deterministic Perspective)." << std::endl;
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
