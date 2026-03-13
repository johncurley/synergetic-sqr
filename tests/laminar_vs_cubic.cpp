// Laminar vs Cubic Benchmark (v1.0)
// Objective: Empirically prove the superiority of Rational Quadrance.
// Vibe: The Speed of 60 Degrees.

#include <iostream>
#include <chrono>
#include <cmath>
#include <vector>

const int ITERATIONS = 10000000;

int main() {
    std::cout << "--- Commencing 'Cubic Tax' Benchmark ---" << std::endl;

    // 1. CUBIC (Standard sqrt)
    float x = 123.45f, y = 67.89f, r = 150.0f;
    auto start_cubic = std::chrono::high_resolution_clock::now();
    bool res_c = false;
    for(int i=0; i<ITERATIONS; i++) {
        res_c = std::sqrt(x*x + y*y) < r;
    }
    auto end_cubic = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff_cubic = end_cubic - start_cubic;

    // 2. LAMINAR (Rational Quadrance)
    long lx = 12345, ly = 6789, lr = 15000;
    auto start_laminar = std::chrono::high_resolution_clock::now();
    bool res_l = false;
    for(int i=0; i<ITERATIONS; i++) {
        res_l = (lx*lx + ly*ly) < (lr*lr);
    }
    auto end_laminar = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff_laminar = end_laminar - start_laminar;

    std::cout << "CUBIC TIME (sqrt):   " << diff_cubic.count() << "s" << std::endl;
    std::cout << "LAMINAR TIME (quad): " << diff_laminar.count() << "s" << std::endl;
    std::cout << "SPEED ADVANTAGE:     " << (diff_cubic.count() / diff_laminar.count()) << "x" << std::endl;
    
    return 0;
}
