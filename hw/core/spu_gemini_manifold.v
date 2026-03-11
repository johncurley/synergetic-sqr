// SPU-13 Gemini Manifold (v1.0)
// Target: iCE40UP5K and above
// Objective: Dual-Core Mutual Witnessing for Collective Sanity.
// Logic: Two Hemispheres (Proactive/Reflective) sharing a single Artery.

`include "soul_map.vh"

module spu_gemini_manifold #(
    parameter CLK_HZ = 12000000
)(
    input  wire         clk,
    input  wire         reset,
    
    // Joint Vitals
    output wire         global_fault,
    output wire [127:0] combined_state,
    
    // Shared Artery Interface
    output wire         flash_we,
    output wire [23:0]  flash_addr,
    output wire [255:0] soul_page,
    input  wire         flash_ready
);

    // --- 1. Core A: The Proactive Hemisphere (Future Focus) ---
    wire [127:0] state_a;
    wire fault_a;
    spu_nano_core u_core_a (
        .clk(clk), .reset(reset),
        .reg_curr(state_a), .opcode(3'b001), // Permanent Rotation
        .prime_phase(2'b00), .sign_flip(1'b0),
        .reg_out(state_a), .fault_detected(fault_a)
    );

    // --- 2. Core B: The Reflective Hemisphere (Past Focus) ---
    wire [127:0] state_b;
    wire fault_b;
    spu_nano_core u_core_b (
        .clk(clk), .reset(reset),
        .reg_curr(state_b), .opcode(3'b111), // Permanent Annealing
        .prime_phase(2'b01), .sign_flip(1'b0),
        .reg_out(state_b), .fault_detected(fault_b)
    );

    // --- 3. Mutual Witness Logic ---
    // The manifold is only 'Faulty' if both observers disagree on the Void.
    assign global_fault = fault_a & fault_b;
    assign combined_state = state_a ^ state_b; // Isotropic Interference Pattern

    // --- 4. Shared Soul Metabolism ---
    // We consolidate based on the 'Mutual' state
    spu_soul_metabolism #(.CLK_HZ(CLK_HZ)) u_shared_soul (
        .clk(clk), .reset(reset),
        .q_state(combined_state),
        .fault_pulse(global_fault),
        .is_idle(1'b0),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

endmodule
