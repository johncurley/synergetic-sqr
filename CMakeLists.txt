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
