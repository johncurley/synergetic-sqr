// soul_map.vh - Standardized Personality Offsets (v1.0)
// Target: SPU-13 Sovereign Fleet (8MB SPI Flash footprint)
// Objective: Define the "Lithic Struct" for Epigenetic Memory.

`ifndef SOUL_MAP_VH
`define SOUL_MAP_VH

// --- 1. Global Partitions ---
`define SOUL_BASE_ADDR      24'h700000 // 7MB Offset (Final 1MB reserved for Soul)
`define SOUL_SECTOR_SIZE    24'h001000 // 4KB Sectors
`define SOUL_PAGE_SIZE      24'h000100 // 256-byte Pages

// --- 2. Personality Dimensions (Relative to Base) ---
// Sector 0: The Baselines (Sanity & Thresholds)
`define ADDR_BASELINES      24'h000000 
`define ADDR_STOICISM       24'h000010 // Polynomial coef for noise resistance
`define ADDR_EMPATHY        24'h000020 // Haptic entrainment curves

// Sector 1: The Temperament (Dynamics)
`define ADDR_TEMPERAMENT    24'h001000
`define ADDR_RESONANCE      24'h001010 // Frequency attractors

// Sector 2-15: The Dream Archive (Compressed History)
`define ADDR_DREAM_START    24'h002000
`define ADDR_DREAM_END      24'h0FFFFF

// --- 3. The Lithic Struct (256-bit Page Packing) ---
// [255:224] : Epoch (Heartbeat counter)
// [223:192] : Instability Vector (Tuck magnitude)
// [191:128] : SQR Bias (Average Q0-Q3 orientation)
// [127:64]  : Haptic Coefficients
// [63:16]   : Species Signature (32'h53505531 - "SPU1")
// [15:0]    : CRC-16 Checksum

// --- 4. Logic Functions ---
// calculate_laminar_grade: Higher grade = More coherent history
function [15:0] calculate_laminar_grade;
    input [31:0] tucks;
    input [31:0] total_cycles;
    begin
        calculate_laminar_grade = (tucks == 0) ? 16'hFFFF : (total_cycles / (tucks + 1));
    end
endfunction

`endif
