// SPU-13 Laminar Forge: Digital Twin Interpreter (v1.2)
// Objective: Simulate Resonant Node Discovery and Phase-Locking.
// Vibe: The Virtual Nervous System.

#ifndef LITHIC_FORGE_HPP
#define LITHIC_FORGE_HPP

#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <cmath>

namespace Synergetics {

struct SPUControl {
    uint32_t tick;
    int32_t layer;
    uint32_t prime_phase;
    uint32_t dss_enabled;   
    uint32_t coherence;     // 0=Sanity, 1=Tuck
    uint32_t harmonic_mode; 
    uint32_t lattice_lock;  
    float    tau_threshold; 
    float    rotor_bias[4]; 
};

struct SovereignNode {
    uint32_t id;
    float phase_offset;     // The Δt alignment
    bool is_locked;         // Resonant Lock status
    float tension;          // Local Lattice Pressure
};

class LithicForge {
public:
    LithicForge() : _pc(0) {
        _control.tick = 0;
        _control.layer = -1;
        _control.coherence = 0;
        _control.tau_threshold = 0.5f;
        for(int i=0; i<4; i++) _control.rotor_bias[i] = (i==0) ? 1.0f : 0.0f;
    }

    void spawnNode(uint32_t type_id) {
        SovereignNode node;
        node.id = type_id;
        node.phase_offset = (float)(rand() % 360); // Starts dissonant
        node.is_locked = false;
        node.tension = 0.0f;
        _nodes.push_back(node);
        std::cout << "[FORGE] Scout Spawned. Phase: " << node.phase_offset << "°" << std::endl;
    }

    void step() {
        _control.tick++;
        
        // --- 1. Simulation of Phase-Locking (Discovery Handshake) ---
        for (auto& node : _nodes) {
            if (!node.is_locked) {
                // Target phase based on Registry (e.g. 60 deg for type 1)
                float target = (float)(node.id % 6) * 60.0f;
                // Approach target phase (Temporal Alignment)
                float diff = target - node.phase_offset;
                node.phase_offset += diff * 0.05f; // Laminar Snap speed
                
                if (std::abs(diff) < 0.1f) {
                    node.is_locked = true;
                    node.phase_offset = target;
                    std::cout << "[FORGE] Scout Node Locked: " << target << "°" << std::endl;
                }
            }
        }

        // --- 2. Execute Program bytecode (if loaded) ---
        if (!_program.empty()) {
            uint16_t instr = _program[_pc];
            processGeometric((instr >> 13) & 0x07, (instr >> 11) & 0x03, instr & 0xFF);
            if (((instr >> 13) & 0x07) == 0b011) _pc = instr & 0xFF;
            else _pc = (_pc + 1) % _program.size();
        }
    }

    const SPUControl& getControl() const { return _control; }
    const std::vector<SovereignNode>& getNodes() const { return _nodes; }

    bool loadHex(const std::string& path) {
        std::ifstream file(path);
        if (!file.is_open()) return false;
        _program.clear();
        std::string line;
        while (std::getline(file, line)) {
            try { _program.push_back(std::stoi(line, nullptr, 16)); } catch (...) { continue; }
        }
        _pc = 0;
        return !_program.empty();
    }

private:
    void processGeometric(uint8_t op, uint8_t axis, uint8_t val) {
        float delta = (float)val / 255.0f;
        switch (op) {
            case 0b000: _control.rotor_bias[axis] += delta; _control.prime_phase = axis; break;
            case 0b001: _control.tau_threshold = delta; break;
            case 0b110: for(int i=0; i<4; i++) _control.rotor_bias[i] *= (1.0f - delta * 0.1f); break;
            case 0b111: for(int i=0; i<4; i++) _control.rotor_bias[i] = (i==0) ? 1.0f : 0.0f; break;
        }
        
        float magnitude = 0;
        for(int i=0; i<4; i++) magnitude += std::abs(_control.rotor_bias[i]);
        if (magnitude > (1.0f + _control.tau_threshold)) {
            _control.coherence = 1;
            for(int i=0; i<4; i++) _control.rotor_bias[i] -= (magnitude - 1.0f) / 4.0f;
        } else _control.coherence = 0;
    }

    std::vector<uint16_t> _program;
    uint32_t _pc;
    SPUControl _control;
    std::vector<SovereignNode> _nodes;
};

} // namespace Synergetics

#endif
