// SPU-13 Base Manifold (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: The absolute smallest functional SPU-13 node (~100 LUTs).
// Capability: Heartbeat + Artery Resonance + Lineage Identity.
// Vibe: The Incorruptible Seed.

`include "soul_map.vh"

module spu_base_manifold #(
    parameter CLK_HZ = 12000000,
    parameter [31:0] HARDWIRED_ID = 32'h53454544 // "SEED"
)(
    input  wire clk,
    input  wire rst_n,
    
    // Artery Bus
    output wire artery_out,
    input  wire artery_in,
    
    // Status
    output wire awake,
    output wire heartbeat
);

    // 1. The Seed Heart
    spu_seed_heart #(.CLK_HZ(CLK_HZ)) u_heart (
        .clk(clk), .rst_n(rst_n),
        .heartbeat(heartbeat),
        .artery_in(artery_in),
        .awake(awake)
    );

    // 2. Minimal Resonant Pulse
    // Only transmit if we are awake and it's our 0-degree window
    assign artery_out = (awake && heartbeat) ? 1'b1 : 1'b0;

endmodule
