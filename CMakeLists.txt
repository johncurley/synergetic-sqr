cmake_minimum_required(VERSION 3.20)

# 1. Initialize with standard C/C++ only
project(synergetic-sqr LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 2. Enable Objective-C++ ONLY on macOS for Metal support
if(APPLE)
    enable_language(OBJCXX)
endif()

# --- OPTIONS ---
option(BUILD_RENDERER "Build the visual SPU-1 demonstrator" ON)

# --- EXTERNAL DEPENDENCIES ---
include(FetchContent)
FetchContent_Declare(
  sdl3
  GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
  GIT_TAG main
)
FetchContent_MakeAvailable(sdl3)

# --- INCLUDE DIRECTORIES ---
include_directories(core/include)
include_directories(software/api)
include_directories(software/toolchain)
include_directories(demos/renderer)
include_directories(metal-cpp)

# --- CORE ALGEBRAIC AUDIT (PURITY GUARD) ---
add_custom_target(purity_audit
    COMMAND grep -rnE "float|double" core/include/spu/SynergeticsMath.hpp | grep -v "DisplayAdapter" | grep -v "Legacy" || true
    COMMENT "Auditing SPU-1 Algebraic Core for floating-point contamination..."
)

# --- VERIFICATION SUITES ---
macro(add_spu_test name source)
    add_executable(${name} verification/suites/${source})
    if(APPLE)
        set_source_files_properties(verification/suites/${source} PROPERTIES COMPILE_FLAGS "-x objective-c++")
    endif()
    target_link_libraries(${name} PRIVATE spu_core_interface)
endmacro()

# Interface library for shared includes
add_library(spu_core_interface INTERFACE)
target_include_directories(spu_core_interface INTERFACE core/include software/api software/toolchain)

add_spu_test(spu-verify rigorous_verification.cpp)
add_spu_test(spu-extreme-chaos extreme_chaos_verification.cpp)
add_spu_test(spu-bulletproof bulletproof_verification.cpp)
add_spu_test(spu-collision collision_verification.cpp)
add_spu_test(spu-sdk-verify sdk_verification.cpp)
add_spu_test(spu-prime-verify prime_synthesis_verification.cpp)
add_spu_test(spu13-verify spu13_verification.cpp)
add_spu_test(spu-robotics-verify robotics_verification.cpp)
add_spu_test(spu-toolchain-verify toolchain_verification.cpp)
add_spu_test(spu-security-verify security_verification.cpp)
add_spu_test(spu-hull-verify hull_verification.cpp)

# --- VISUAL DEMONSTRATOR ---
if(BUILD_RENDERER)
    set(RENDERER_SOURCES
        demos/renderer/main.cpp
        demos/renderer/SynergeticRenderer.cpp
    )
    
    add_executable(synergetic-sqr ${RENDERER_SOURCES})
    target_link_libraries(synergetic-sqr PRIVATE SDL3-shared spu_core_interface)
    
    if(APPLE)
        set_source_files_properties(demos/renderer/main.cpp demos/renderer/SynergeticRenderer.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
        target_link_libraries(synergetic-sqr PRIVATE "-framework Metal" "-framework QuartzCore" "-framework AppKit")
    endif()

    add_custom_command(TARGET synergetic-sqr POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/demos/renderer ${CMAKE_CURRENT_BINARY_DIR}/
        COMMENT "Syncing shaders and models to build directory..."
    )
endif()
