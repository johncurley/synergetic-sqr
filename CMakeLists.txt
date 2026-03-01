cmake_minimum_required(VERSION 3.16)
project(SynergeticSQR VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Automatic SDL3 Fetching
include(FetchContent)
FetchContent_Declare(
  SDL3
  GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
  GIT_TAG main
)
FetchContent_MakeAvailable(SDL3)

# 2. Source Files
set(SOURCES
    src/main.cpp
    src/SynergeticRenderer.cpp
)

# 3. Include Directories
include_directories(src)
include_directories(metal-cpp)

# 4. Executable
add_executable(synergetic-sqr ${SOURCES})

# 4.1 Deterministic Verification Suite
add_executable(spu-verify tests/rigorous_verification.cpp)
if(APPLE)
    target_link_libraries(spu-verify PRIVATE "-framework Foundation") 
    set_source_files_properties(tests/rigorous_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# 4.2 Collision Verification Suite
add_executable(spu-collision tests/collision_verification.cpp)
if(APPLE)
    set_source_files_properties(tests/collision_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# 4.3 Bulletproof Verification Suite
add_executable(spu-bulletproof tests/bulletproof_verification.cpp)
if(APPLE)
    set_source_files_properties(tests/bulletproof_verification.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# --- SPU-1 PURITY GUARD (Zero-Tolerance Audit) ---
# Fails the build if 'float' or 'double' are found in the Algebraic Core
add_custom_target(purity_audit ALL
    COMMAND sed -n '/SOVEREIGN CORE/,/END SOVEREIGN CORE/p' "${CMAKE_CURRENT_SOURCE_DIR}/src/SynergeticsMath.hpp" | grep -E 'float|double' && (echo "PURITY ERROR: Floating point contamination found in SynergeticsMath.hpp Core" && exit 1) || true
    COMMAND sed -n '1,/CARTESIAN CORNER/p' "${CMAKE_CURRENT_SOURCE_DIR}/src/DQFA.metal" | grep -E 'float|double' && (echo "PURITY ERROR: Floating point contamination found in DQFA.metal Core" && exit 1) || true
    COMMENT "Auditing SPU-1 Algebraic Core for floating-point contamination..."
)
add_dependencies(synergetic-sqr purity_audit)

# 5. Robust Asset Management: Copy shader on every build
add_custom_command(TARGET synergetic-sqr POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_CURRENT_SOURCE_DIR}/src ${CMAKE_CURRENT_BINARY_DIR}/src
    COMMENT "Syncing shader source to build directory..."
)

# 6. Linking Logic
if(APPLE)
    target_link_libraries(synergetic-sqr PRIVATE SDL3::SDL3 "-framework Metal" "-framework Foundation" "-framework QuartzCore" "-framework AppKit")
    set_source_files_properties(src/SynergeticRenderer.cpp src/main.cpp PROPERTIES COMPILE_FLAGS "-x objective-c++")
else()
    target_link_libraries(synergetic-sqr PRIVATE SDL3::SDL3)
endif()
