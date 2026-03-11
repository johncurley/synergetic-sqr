// SPU-13 Physical Artery (v1.0)
// Target: iCE40 UP5K / Standard Fleet
// Objective: Phase-Locked Synchronicity via Global Buffer (GBUF).
// Logic: Hard-wires the 'Aorta' to the FPGA's high-speed backbone.

module spu_artery_phy (
    input  wire raw_heartbeat,    // From the Phi-Pulse Generator
    output wire global_heartbeat  // Distributed with zero-skew
);

    // This forces the signal onto the GBUF network.
    // It ensures the Heartbeat is protected from 'Cubic Noise' in general routing.
    SB_GB artery_aorta (
        .USER_SIGNAL_ANY(raw_heartbeat),
        .GLOBAL_BUFFER_OUTPUT(global_heartbeat)
    );

endmodule
