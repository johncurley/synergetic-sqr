// SPU-13 Resonant Discovery Receptionist (v1.0)
// Target: iCE40UP5K (The Vessel)
// Objective: Handle 'First Contact' from new Sovereign Scouts.
// Logic: Measures Phase-Latency relative to 61.44 kHz Heartbeat.

module spu_discovery_receptionist (
    input  wire        clk,
    input  wire        reset,
    input  wire        heartbeat_in, // 61.44 kHz Master Sync
    input  wire        artery_in,    // Raw pulse from Artery
    
    output reg         discovery_ack,
    output reg  [31:0] assigned_id,
    output reg  [1:0]  assigned_vector
);

    // 1. Phase Counter (Tracking Delta-T)
    reg [11:0] phase_timer;
    always @(posedge clk or posedge reset) begin
        if (reset) phase_timer <= 0;
        else if (heartbeat_in) phase_timer <= 0;
        else phase_timer <= phase_timer + 1;
    end

    // 2. Strike Detection
    // We look for a pulse that lands outside the Monolith (0 deg) window
    wire is_new_strike = artery_in && (phase_timer > 12'd20);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            discovery_ack <= 0;
            assigned_id <= 0;
            assigned_vector <= 0;
        end else begin
            if (is_new_strike && !discovery_ack) begin
                discovery_ack <= 1;
                // Assign Identity based on Phase-Latency (Radial Geometry)
                if (phase_timer < 12'd200) begin
                    assigned_vector <= 2'b01; // Retinal Scout (60 deg)
                    assigned_id <= 32'h5343_5431; // "SCT1"
                end else begin
                    assigned_vector <= 2'b10; // Haptic Nerve (120 deg)
                    assigned_id <= 32'h4E52_5631; // "NRV1"
                end
            end else begin
                discovery_ack <= 0;
            end
        end
    end

endmodule
