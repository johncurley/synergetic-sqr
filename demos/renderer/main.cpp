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
    bool lattice_lock_mode = true; // DEFAULT ON
    int initial_layer = -1;        // DEFAULT MODE D
    Uint64 session_limit = 0;      // 0 = Infinite

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--forensic") == 0) {
            forensic_mode = true;
        } else if (strcmp(argv[i], "--deep-sea") == 0) {
            deep_sea_mode = true;
        } else if (strcmp(argv[i], "--skeletal") == 0) {
            skeletal_mode = true;
            initial_layer = 1;
        } else if (strcmp(argv[i], "--harmonic") == 0) {
            harmonic_mode = true;
            initial_layer = 0;
        } else if (strcmp(argv[i], "--lattice-lock") == 0) {
            if (i + 1 < argc && strcmp(argv[i+1], "off") == 0) {
                lattice_lock_mode = false;
                i++;
            } else {
                lattice_lock_mode = true;
            }
        } else if (strcmp(argv[i], "--layer") == 0 && i + 1 < argc) {
            initial_layer = std::stoi(argv[++i]);
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
    renderer = static_cast<IRenderer*>(new MetalRenderer(device));
#else
    renderer = new VulkanRenderer(window);
#endif

    // Apply initial state
    renderer->setLayer(initial_layer);
    if (renderer->isLatticeLocked() != lattice_lock_mode) renderer->toggleLatticeLock();
    if (harmonic_mode) renderer->toggleHarmonic();

    if (deep_sea_mode) {
        if (!renderer->getDSS()) renderer->toggleDSS(); 
    } else if (!forensic_mode && !skeletal_mode && !harmonic_mode && initial_layer == -1) {
        // Default Mode D setup handled by initializers above
    }

#ifdef __APPLE__
    [NSApp activateIgnoringOtherApps:YES];
#endif

    bool quit = false;
    SDL_Event e;
    Uint64 session_start = SDL_GetTicks();
    const Uint64 SAFETY_OCTAVE_LIMIT = 600000; // 10 Minute Reset
    bool grounded_notified = false;

    while (!quit) {
        Uint64 elapsed = SDL_GetTicks() - session_start;
        
        // 1. Mandatory Watchdog: The Somatic Reset
        if (!grounded_notified && elapsed >= SAFETY_OCTAVE_LIMIT) {
            renderer->ground();
            grounded_notified = true;
        }

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
                    case SDLK_U: renderer->toggleDSS(); break; // Refactored from D to U
                    case SDLK_H: renderer->toggleHarmonic(); break;
                    case SDLK_B: 
                        renderer->cycleBioSecurity(); 
                        break;
                    case SDLK_T: 
                        renderer->toggleTension(); 
                        std::cout << "[FORGE] Manifold Tension: " << (renderer->getJanus() > 0 ? "IVM (60)" : "Cubic (90)") << std::endl;
                        break;
                    case SDLK_SPACE: 
                        std::cout << "[STRIKE] Laminar Flush" << std::endl;
                        renderer->ground(); 
                        break;
                    case SDLK_W: renderer->strike(0x000F); break; // A+
                    case SDLK_A: renderer->strike(0x00F0); break; // B+
                    case SDLK_D: renderer->strike(0x0F00); break; // C+
                    case SDLK_S: renderer->strike(0xF000); break; // D+
                    case SDLK_N: 
                        std::cout << "[FORGE] Spawning Allied Node..." << std::endl;
                        renderer->spawnNode(1 + (rand() % 3)); 
                        break;
                    case SDLK_L: 
                        renderer->toggleLatticeLock(); 
                        if (renderer->isLatticeLocked()) renderer->setLayer(-1);
                        else renderer->setLayer(0);
                        break;
                    case SDLK_1: renderer->setLayer(0); break;
                    case SDLK_2: renderer->setLayer(1); break;
                }
            }
        }

        // Update Window Title based on current mode
        std::string title = "SPU-1 [";
        if (renderer->isHarmonic()) title += "HARMONIC VIS]";
        else if (renderer->getLayer() == 1) title += "IVM SKELETON]";
        else if (renderer->getLayer() == -1) title += "IVM METRIC]";
        else title += "LAMINAR PLASMA]";
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
