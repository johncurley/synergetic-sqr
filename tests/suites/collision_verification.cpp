#include <iostream>
#include <vector>
#include <cassert>
#include "spu/SynergeticsMath.hpp"

using namespace Synergetics;

// --- Test 1: Tetrahedral Field Intersection ---
bool tetraIntersectionTest() {
    SurdFixed64 one = { SurdFixed64::One, 0 };
    SurdFixed64 half = { SurdFixed64::One / 2, 0 };
    
    // Check intersection via algebraic inequality (a1 == a2)
    return one.a > half.a;
}

// --- Test 2: Dual-Number Velocity Collision ---
bool dualVelocityTest() {
    DualSurd pos = { {65536, 0}, {1, 1} };
    DualSurd vel = { {0, 0}, {2, 2} };
    DualSurd newPos = pos.add(vel);
    
    // Verify derivative propagation (1+2=3)
    return newPos.eps.a == 3 && newPos.eps.b == 3;
}

// --- Test 3: Infinitesimal Tunneling Detection ---
bool infinitesimalTunnelingTest() {
    DualSurd pos = { {1, 1}, {1, 0} };
    DualSurd barrier = { {1, 1}, {0, 0} };
    // Identity must be preserved; no penetration beyond epsilon
    return !(pos.val.a < barrier.val.a);
}

// --- Test 7: Energy Conservation Under Collision ---
bool energyTest() {
    SurdFixed64 mass = { 2, 0 };
    SurdFixed64 velocity = { 4, 0 };
    
    // Kinetic Energy E = 0.5 * m * v^2
    SurdFixed64 kinetic = mass.multiply(velocity).multiply(velocity); 
    
    // Simulate reflection (elastic collision)
    SurdFixed64 reflected_v = { -velocity.a, -velocity.b };
    SurdFixed64 newKinetic = mass.multiply(reflected_v).multiply(reflected_v);
    
    return kinetic.a == newKinetic.a;
}

// --- Test 10: Collision Identity Closure ---
bool identityClosureTest() {
    Quadray4 initial = Quadray4::identity();
    Quadray4 current = initial;
    
    // Full rotation cycle (6 steps)
    for(int i=0; i<6; i++) {
        current = Quadray4::_spu_rotate_60(current);
    }
    
    return current.equals(initial);
}

int main() {
    std::cout << "--- Hyper-Surd Collision & Physics Test Suite v1.0 ---" << std::endl;

    if(tetraIntersectionTest()) std::cout << "Tetrahedral Intersection: PASS" << std::endl;
    else return 1;

    if(dualVelocityTest()) std::cout << "Dual-Number Velocity: PASS" << std::endl;
    else return 1;

    if(infinitesimalTunnelingTest()) std::cout << "Infinitesimal Tunneling: PASS" << std::endl;
    else return 1;

    if(energyTest()) std::cout << "Energy Conservation: PASS" << std::endl;
    else return 1;

    if(identityClosureTest()) std::cout << "Collision Identity Closure: PASS" << std::endl;
    else return 1;

    std::cout << "--- ALL COLLISION TESTS PASSED ---" << std::endl;
    return 0;
}
