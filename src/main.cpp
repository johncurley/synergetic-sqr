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
    bool safe_mode = true;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--forensic") == 0) {
            safe_mode = false;
            std::cout << "WARNING: Launching in FORENSIC MODE. Optical Dampers Disabled." << std::endl;
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

    SDL_Window* window = SDL_CreateWindow(
        "SPU-1 Sovereign Renderer",
        800, 600,
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

    // Apply Safe-Mode State
    if (safe_mode) {
        if (!renderer->getDSS()) renderer->toggleDSS(); // Force ON
        SDL_SetWindowTitle(window, "SPU-1 [SAFE MODE] | Damper [ON]");
    } else {
        SDL_SetWindowTitle(window, "SPU-1 [FORENSIC] | Damper [OFF]");
    }

#ifdef __APPLE__
    [NSApp activateIgnoringOtherApps:YES];
#endif

    bool quit = false;
    SDL_Event e;
    const int FPS = 60;
    const int frameDelay = 1000 / FPS;

    while (!quit) {
        Uint64 frameStart = SDL_GetTicks();

        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_EVENT_QUIT) {
                quit = true;
            } else if (e.type == SDL_EVENT_KEY_DOWN) {
                if (e.key.key == SDLK_SPACE) {
                    renderer->toggleJanus();
                } else if (e.key.key == SDLK_S) {
                    renderer->toggleDSS();
                }
                
                char title[128];
                snprintf(title, sizeof(title), "SPU-1 [%s] | Damper [%s]", 
                    (renderer->getJanus() > 0 ? "Janus +" : "Janus -"),
                    (renderer->getDSS() ? "ON" : "OFF"));
                SDL_SetWindowTitle(window, title);
            }
        }

        Uint32 flags = SDL_GetWindowFlags(window);
        if (!(flags & SDL_WINDOW_HIDDEN) && !(flags & SDL_WINDOW_MINIMIZED)) {
            renderer->draw(layer);
        }

        int frameTime = SDL_GetTicks() - frameStart;
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
