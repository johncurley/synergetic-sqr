cmake_minimum_required(VERSION 3.16)
project(SynergeticSQR VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Option to build the Visual Renderer (Requires SDL3)
option(BUILD_RENDERER "Build the SDL3 visual renderer" ON)

if(BUILD_RENDERER)
    # Automatic SDL3 Fetching
    include(FetchContent)
    FetchContent_Declare(
      SDL3
      GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
      GIT_TAG main
    )
    FetchContent_MakeAvailable(SDL3)
endif()

# 2. Source Files
set(SOURCES
    src/main.cpp
    renderer/src/SynergeticRenderer.cpp
)

# 3. Global Include Directories
include_directories(core/include)
include_directories(renderer/src)
include_directories(metal-cpp)

# 4. Executable (Visual Renderer)
if(BUILD_RENDERER)
    add_executable(synergetic-sqr ${SOURCES})
endif()

# 4.1 Deterministic Verification Suite
add_executable(spu-verify tests/suites/rigorous_verification.cpp)
if(APPLE)
    target_link_libraries(spu-verify PRIVATE "-framework Foundation") 
    set_source_files_properties(tests/suites/rigorous_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# 4.2 Collision Verification Suite
add_executable(spu-collision tests/suites/collision_verification.cpp)
if(APPLE)
    set_source_files_properties(tests/suites/collision_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# 4.3 Bulletproof Verification Suite
add_executable(spu-bulletproof tests/suites/bulletproof_verification.cpp)
if(APPLE)
    set_source_files_properties(tests/suites/bulletproof_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# 4.4 Extreme Chaos Suite
add_executable(spu-extreme-chaos tests/suites/extreme_chaos_verification.cpp)
if(APPLE)
    set_source_files_properties(tests/suites/extreme_chaos_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# 4.5 SDK Verification Suite
add_executable(spu-sdk-verify tests/suites/sdk_verification.cpp)
if(APPLE)
    set_source_files_properties(tests/suites/sdk_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# --- SPU-1 PURITY GUARD ---
add_custom_target(purity_audit ALL
    COMMAND sed -n '/SOVEREIGN CORE/,/END SOVEREIGN CORE/p' "${CMAKE_CURRENT_SOURCE_DIR}/core/include/spu/SynergeticsMath.hpp" | grep -E 'float|double' && (echo "PURITY ERROR: Contamination in Core" && exit 1) || true
    COMMENT "Auditing SPU-1 Algebraic Core for floating-point contamination..."
)

# 5. Asset Management
if(BUILD_RENDERER)
    add_custom_command(TARGET synergetic-sqr POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/src
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/renderer/metal/DQFA.metal ${CMAKE_CURRENT_BINARY_DIR}/src/DQFA.metal
        COMMENT "Syncing shaders to build directory..."
    )
endif()

# 6. Linking Logic
if(BUILD_RENDERER)
    if(APPLE)
        target_link_libraries(synergetic-sqr PRIVATE SDL3::SDL3 "-framework Metal" "-framework Foundation" "-framework QuartzCore" "-framework AppKit")
        set_source_files_properties(renderer/src/SynergeticRenderer.cpp src/main.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
    else()
        target_link_libraries(synergetic-sqr PRIVATE SDL3::SDL3)
    endif()
endif()
