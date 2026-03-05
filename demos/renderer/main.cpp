#include <SDL3/SDL.h>
#include <iostream>
#include <string.h>
#include "SynergeticRenderer.hpp"
#include "spu/SynergeticsMath.hpp"

#ifdef __APPLE__
#import <AppKit/AppKit.h>
#endif

using namespace Synergetics;

int main(int argc, char* argv[]) {
    // 0. CLI Argument Parsing
    bool forensic_mode = false;
    bool deep_sea_mode = false;
    bool pulse_mode = false;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--forensic") == 0) {
            forensic_mode = true;
            std::cout << "WARNING: Launching in FORENSIC MODE." << std::endl;
        } else if (strcmp(argv[i], "--deep-sea") == 0) {
            deep_sea_mode = true;
            std::cout << "SAFE: Launching in DEEP SEA MODE." << std::endl;
        } else if (strcmp(argv[i], "--pulse") == 0) {
            pulse_mode = true;
            std::cout << "TETHERED: 10-Second Safe Pulse Active." << std::endl;
        }
    }

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    Uint32 windowFlags = SDL_WINDOW_RESIZABLE;
#ifdef __APPLE__
    windowFlags |= SDL_WINDOW_METAL;
#endif

    int w = deep_sea_mode ? 400 : 800;
    int h = deep_sea_mode ? 400 : 600;

    SDL_Window* window = SDL_CreateWindow(
        "SPU-1 Sovereign Renderer",
        w, h,
        windowFlags
    );

    if (!window) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    IRenderer* renderer = nullptr;
    void* metalView = nullptr;
    MTL::Device* device = nullptr;
    CA::MetalLayer* layer = nullptr;

#ifdef __APPLE__
    metalView = SDL_Metal_CreateView(window);
    layer = (CA::MetalLayer*)SDL_Metal_GetLayer(metalView);
    device = MTL::CreateSystemDefaultDevice();
    layer->setDevice(device);
    layer->setPixelFormat(MTL::PixelFormatBGRA8Unorm);
    layer->setAllowsNextDrawableTimeout(false);
    layer->setFramebufferOnly(true);
    
    renderer = new MetalRenderer(device);
#else
    renderer = new VulkanRenderer(window);
#endif

    if (deep_sea_mode) {
        if (!renderer->getDSS()) renderer->toggleDSS(); 
        SDL_SetWindowTitle(window, "SPU-1 [DEEP SEA MODE]");
    } else if (!forensic_mode) {
        if (!renderer->getDSS()) renderer->toggleDSS(); 
        SDL_SetWindowTitle(window, "SPU-1 [SAFE MODE]");
    }

#ifdef __APPLE__
    [NSApp activateIgnoringOtherApps:YES];
#endif

    bool quit = false;
    SDL_Event e;
    Uint64 session_start = SDL_GetTicks();

    while (!quit) {
        Uint64 current_ticks = SDL_GetTicks();
        Uint64 elapsed = current_ticks - session_start;

        // 10-Second Watchdog (SIG_KILL)
        if (pulse_mode && elapsed >= 10000) {
            std::cout << "WATCHDOG: 10-Second Pulse Complete. Grounding Session." << std::endl;
            quit = true;
        }

        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_EVENT_QUIT) {
                quit = true;
            } else if (e.type == SDL_EVENT_KEY_DOWN) {
                if (forensic_mode) {
                    if (e.key.key == SDLK_SPACE) renderer->toggleJanus();
                    else if (e.key.key == SDLK_S) renderer->toggleDSS();
                }
            }
        }

        Uint32 flags = SDL_GetWindowFlags(window);
        if (!(flags & SDL_WINDOW_HIDDEN) && !(flags & SDL_WINDOW_MINIMIZED)) {
            renderer->draw(layer);
        }

        SDL_Delay(16); // 60 FPS cap
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
