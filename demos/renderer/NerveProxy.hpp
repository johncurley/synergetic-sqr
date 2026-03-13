// SPU-13 Nerve Proxy: USB-to-PMOD Bridge (v1.0)
// Objective: Hardware-in-the-Loop bridge for the FT232H.
// Vibe: The Emulator's Sensory Organs.

#ifndef NERVE_PROXY_HPP
#define NERVE_PROXY_HPP

#include <iostream>
#include <vector>
#include <cstdint>

#ifdef USE_FTDI
#include <ftd2xx.h>
#endif

namespace Synergetics {

class NerveProxy {
public:
    NerveProxy() : _handle(nullptr), _isActive(false) {}
    ~NerveProxy() { disconnect(); }

    bool connect() {
#ifdef USE_FTDI
        FT_STATUS status = FT_Open(0, &_handle);
        if (status != FT_OK) {
            std::cerr << "[NERVE] Failed to open FT232H Device." << std::endl;
            return false;
        }

        // Set Bit-Bang Mode (MPSSE Initialization)
        FT_SetBitMode(_handle, 0xFF, 0x01); // All pins output, Async Bit-Bang
        FT_SetBaudRate(_handle, 9600);      // Baseline frequency
        
        _isActive = true;
        std::cout << "[NERVE] FT232H Bridge Connected. PMODs Live." << std::endl;
        return true;
#else
        std::cout << "[NERVE] FTDI Driver not linked. Running in Virtual-Only mode." << std::endl;
        return false;
#endif
    }

    void disconnect() {
#ifdef USE_FTDI
        if (_handle) {
            FT_Close(_handle);
            _handle = nullptr;
        }
#endif
        _isActive = false;
    }

    // Write raw bit-state to PMOD pins (D0-D7)
    void strike(uint8_t bits) {
#ifdef USE_FTDI
        if (!_isActive) return;
        DWORD bytesWritten;
        FT_Write(_handle, &bits, 1, &bytesWritten);
#endif
    }

    // Read input from PMOD pins
    uint8_t inhale() {
#ifdef USE_FTDI
        if (!_isActive) return 0xFF;
        uint8_t bits;
        DWORD bytesRead;
        FT_GetBitMode(_handle, &bits);
        return bits;
#else
        return 0;
#endif
    }

    bool isActive() const { return _isActive; }

private:
    void* _handle;
    bool  _isActive;
};

} // namespace Synergetics

#endif
