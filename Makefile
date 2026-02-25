# Makefile for Synergetic Renderer

CXX = clang++
CXXFLAGS = -std=c++17 -fno-exceptions -fno-rtti
INCLUDES = -I./metal-cpp -I./src
LDFLAGS = -framework Metal -framework Foundation -framework QuartzCore -framework AppKit -framework MetalKit -framework Cocoa

SRC = src/main.mm src/SynergeticRenderer.cpp
OUT = synergetic-renderer

all: $(OUT)

$(OUT): $(SRC)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SRC) -o $(OUT) $(LDFLAGS)

clean:
	rm -f $(OUT)

run: all
	./$(OUT)
