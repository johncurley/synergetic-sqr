// SPU-13 Laminar Forge: Digital Twin Interpreter (v1.1)
// Objective: Full ISA Parity with Hardware (SQR Rotor + Davis Law).
// Feature: Bridge to Metal/Vulkan SPUControl uniform state.

#ifndef LITHIC_FORGE_HPP
#define LITHIC_FORGE_HPP

#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <cmath>

namespace Synergetics {

// Mirror of the hardware SPUControl struct used in Shaders
struct SPUControl {
    uint32_t tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     // 0=Sanity, 1=Tuck
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    float    tau_threshold; // Physical Sanity Floor
    float    rotor_bias[4]; // 4D Quadray Bias (A,B,C,D)
};

class LithicForge {
public:
    LithicForge() : _pc(0) {
        // Initialize Identity State
        _control.tick = 0;
        _control.layer = -1;
        _control.coherence = 0;
        _control.tau_threshold = 0.5f;
        for(int i=0; i<4; i++) _control.rotor_bias[i] = (i==0) ? 1.0f : 0.0f;
    }

    bool loadHex(const std::string& path) {
        std::ifstream file(path);
        if (!file.is_open()) return false;
        
        _program.clear();
        std::string line;
        while (std::getline(file, line)) {
            try {
                uint16_t word = std::stoi(line, nullptr, 16);
                _program.push_back(word);
            } catch (...) { continue; }
        }
        _pc = 0;
        return !_program.empty();
    }

    const SPUControl& getControl() const { return _control; }

    void step() {
        if (_program.empty()) return;
        
        uint16_t instr = _program[_pc];
        uint8_t opcode = (instr >> 13) & 0x07;
        uint8_t axis   = (instr >> 11) & 0x03;
        uint8_t payload = instr & 0xFF;

        processGeometric(opcode, axis, payload);

        // PC Flow (Sync with Fibonacci Heartbeat)
        if (opcode == 0b011) _pc = payload; // LEAP
        else _pc = (_pc + 1) % _program.size();
        
        _control.tick++;
    }

private:
    void processGeometric(uint8_t op, uint8_t axis, uint8_t val) {
        float delta = (float)val / 255.0f;

        switch (op) {
            case 0b000: // ROTR (spin): Update 4D bias
                _control.rotor_bias[axis] += delta;
                _control.prime_phase = axis;
                break;
                
            case 0b001: // TUCK (lock): Adjust Tau threshold
                _control.tau_threshold = delta;
                break;
                
            case 0b110: // ANNE (anneal): Pull toward Equilibrium
                for(int i=0; i<4; i++) 
                    _control.rotor_bias[i] *= (1.0f - delta * 0.1f);
                break;
                
            case 0b111: // IDNT (reset): Unity Reset
                for(int i=0; i<4; i++) _control.rotor_bias[i] = (i==0) ? 1.0f : 0.0f;
                _control.coherence = 0;
                break;

            case 0b100: // SYNC (wait): Simulate phase lock
                // No immediate change, just aligns with heartbeat
                break;
        }

        // --- Davis Law Sanity Gate (Simulation) ---
        float magnitude = 0;
        for(int i=0; i<4; i++) magnitude += std::abs(_control.rotor_bias[i]);
        
        // If tension K > Tau, trigger visual 'Tuck'
        if (magnitude > (1.0f + _control.tau_threshold)) {
            _control.coherence = 1; // Visual Dissonance
            // Soft Recovery: Force re-alignment
            for(int i=0; i<4; i++) _control.rotor_bias[i] -= (magnitude - 1.0f) / 4.0f;
        } else {
            _control.coherence = 0; // Crystalline
        }
    }

    std::vector<uint16_t> _program;
    uint32_t _pc;
    SPUControl _control;
};

} // namespace Synergetics

#endif
