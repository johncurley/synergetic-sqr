#include <SDL3/SDL.h>
#include <iostream>
#include <string.h>
#include <string>
#include "SynergeticRenderer.hpp"
#include "spu/SynergeticsMath.hpp"

#ifdef __APPLE__
#import <AppKit/AppKit.h>
#endif

using namespace Synergetics;

int main(int argc, char* argv[]) {
    bool forensic_mode = false;
    bool deep_sea_mode = false;
    bool skeletal_mode = false;
    bool harmonic_mode = false;
    Uint64 session_limit = 0; // 0 = Infinite

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--forensic") == 0) {
            forensic_mode = true;
        } else if (strcmp(argv[i], "--deep-sea") == 0) {
            deep_sea_mode = true;
        } else if (strcmp(argv[i], "--skeletal") == 0) {
            skeletal_mode = true;
        } else if (strcmp(argv[i], "--harmonic") == 0) {
            harmonic_mode = true;
        } else if (strcmp(argv[i], "--pulse") == 0) {
            session_limit = 10000; // Default 10s
        } else if (strcmp(argv[i], "--duration") == 0 && i + 1 < argc) {
            session_limit = std::stoull(argv[++i]);
        }
    }

    if (!SDL_Init(SDL_INIT_VIDEO)) return 1;

    Uint32 windowFlags = SDL_WINDOW_RESIZABLE;
#ifdef __APPLE__
    windowFlags |= SDL_WINDOW_METAL;
#endif

    int w = deep_sea_mode ? 400 : 800;
    int h = deep_sea_mode ? 400 : 600;

    SDL_Window* window = SDL_CreateWindow("SPU-1 Sovereign Renderer", w, h, windowFlags);
    if (!window) return 1;

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
    } else if (skeletal_mode) {
        renderer->setLayer(1); // Mode 1: Core IVM Skeleton
    } else if (harmonic_mode) {
        renderer->toggleHarmonic();
    } else if (!forensic_mode) {
        if (!renderer->getDSS()) renderer->toggleDSS(); 
    }

#ifdef __APPLE__
    [NSApp activateIgnoringOtherApps:YES];
#endif

    bool quit = false;
    SDL_Event e;
    Uint64 session_start = SDL_GetTicks();

    while (!quit) {
        Uint64 elapsed = SDL_GetTicks() - session_start;
        if (session_limit > 0 && elapsed >= session_limit) {
            std::cout << "WATCHDOG: Session limit of " << session_limit << "ms reached. Grounding." << std::endl;
            quit = true;
        }

        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_EVENT_QUIT) quit = true;
            if (e.type == SDL_EVENT_KEY_DOWN) {
                switch (e.key.key) {
                    case SDLK_ESCAPE: quit = true; break;
                    case SDLK_J: renderer->toggleJanus(); break;
                    case SDLK_D: renderer->toggleDSS(); break;
                    case SDLK_H: renderer->toggleHarmonic(); break;
                    case SDLK_1: renderer->setLayer(0); break;
                    case SDLK_2: renderer->setLayer(1); break;
                }
            }
        }

        // Update Window Title based on current mode
        std::string title = "SPU-1 [";
        if (renderer->isHarmonic()) title += "HARMONIC VIS]";
        else if (renderer->getLayer() == 1) title += "IVM SKELETON]";
        else title += "FLORA]";
        SDL_SetWindowTitle(window, title.c_str());

        Uint32 flags = SDL_GetWindowFlags(window);
        if (!(flags & SDL_WINDOW_HIDDEN) && !(flags & SDL_WINDOW_MINIMIZED)) {
            renderer->draw(layer);
        }
        SDL_Delay(16);
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
