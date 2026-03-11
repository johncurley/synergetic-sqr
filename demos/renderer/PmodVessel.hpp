// SPU-13 PMOD Vessel: Hardware Emulation Layer (v1.0)
// Objective: 1:1 parity between virtual and physical PMOD cartridges.
// Vibe: The Simulator of Persistence.

#ifndef PMOD_VESSEL_HPP
#define PMOD_VESSEL_HPP

#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <cstdint>

namespace Synergetics {

// The Niche of the Cartridge
enum class PmodNiche {
    NONE,
    SOUL,     // SPI Flash (Personality)
    ALLY,     // Differential Artery (Node-to-Node)
    KNOWLEDGE // microSD (Large Data)
};

class IPmodVessel {
public:
    virtual ~IPmodVessel() {}
    virtual PmodNiche getNiche() const = 0;
    virtual bool loadFromFile(const std::string& path) = 0;
    virtual uint8_t readByte(uint32_t addr) = 0;
};

class SpiFlashVessel : public IPmodVessel {
public:
    SpiFlashVessel() : _capacity(8 * 1024 * 1024) { // 8MB Default
        _data.resize(_capacity, 0xFF);
    }

    PmodNiche getNiche() const override { return PmodNiche.SOUL; }

    bool loadFromFile(const std::string& path) override {
        std::ifstream file(path, std::ios::binary | std::ios::ate);
        if (!file.is_open()) return false;
        
        std::streamsize size = file.tellg();
        file.seekg(0, std::ios::beg);
        
        if (size > _capacity) size = _capacity;
        file.read(reinterpret_cast<char*>(_data.data()), size);
        
        std::cout << "[VESSEL] Soul Inhaled: " << path << " (" << size << " bytes)" << std::endl;
        return true;
    }

    uint8_t readByte(uint32_t addr) override {
        if (addr >= _data.size()) return 0xFF;
        return _data[addr];
    }

    // Direct access for the LithicForge Digital Twin
    const uint8_t* getRawData() const { return _data.data(); }

private:
    uint32_t _capacity;
    std::vector<uint8_t> _data;
};

} // namespace Synergetics

#endif
