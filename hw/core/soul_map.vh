// soul_map.vh - Standardized Personality Offsets (v1.1)
// Target: SPU-13 Sovereign Fleet
// Objective: Define the "Lithic Struct" and LHS for Scaling Intelligence.

`ifndef SOUL_MAP_VH
`define SOUL_MAP_VH

// --- 1. Global Partitions ---
`define SOUL_BASE_ADDR      24'h700000 
`define SOUL_SECTOR_SIZE    24'h001000 
`define SOUL_PAGE_SIZE      24'h000100 
`define SOUL_HEADER_ADDR    24'h000000 // LHS v1.0 Location (First Page)

// --- 2. LHS Structure (The DNA) ---
// [255:224] : Magic Signature 32'h53515213 ("SQR13")
// [223:216] : Soul Class (1:Seed, 2:Aura, 3:Manifold)
// [215:208] : Resolution (Fixed-point bit-depth)
// [207:192] : Heartbeat Sync (61440 Hz)
// [191:0]   : Manifest Data

// --- 3. Personality Dimensions (Relative to Base) ---
// Sector 0: The Baselines (Sanity & Thresholds)
`define ADDR_BASELINES      24'h000000 
`define ADDR_LINEAGE        24'h000004 // 32-bit "Sovereign Name"
`define ADDR_STOICISM       24'h000010 // Polynomial coef for noise resistance
`define ADDR_EMPATHY        24'h000020 // Haptic entrainment curves

// Sector 1: The Temperament (Dynamics)
`define ADDR_TEMPERAMENT    24'h001000
`define ADDR_RESONANCE      24'h001010 // Frequency attractors

// Sector 2-15: The Dream Archive (Compressed History)
`define ADDR_DREAM_START    24'h002000
`define ADDR_DREAM_END      24'h0FFFFF

// --- 4. Logic Functions ---
function [15:0] calculate_laminar_grade;
    input [31:0] tucks;
    input [31:0] total_cycles;
    begin
        calculate_laminar_grade = (tucks == 0) ? 16'hFFFF : (total_cycles / (tucks + 1));
    end
endfunction

`endif
