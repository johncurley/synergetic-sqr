// SPU-13 Bowman Sequencer (v3.3.69)
// Implementation: Automated Boot-Path from Void to Flower.
// Objective: Phase-aligned 'Silicon Wake' without Cubic friction.
// Result: Quiet, liquid entry into the infinite manifold.

module spu_bowman_sequencer (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,             // Manual Throttle
    input  wire       handshake_done, // From Sonic Diagnostic
    input  wire       identity_lock,  // From Monad Guard
    output reg [2:0]  boot_phase,
    output wire       wake_complete
);

    // Phase Definitions
    localparam PHASE_WITHDRAWAL = 3'b000; // The Void
    localparam PHASE_HANDSHAKE  = 3'b001; // Sonic Diagnostic
    localparam PHASE_SATURATION  = 3'b010; // Dielectric Charging
    localparam PHASE_ALIGNMENT   = 3'b011; // IVM Lattice Lock
    localparam PHASE_RESONANCE   = 3'b100; // Full Laminar Bloom

    reg [15:0] phase_timer;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            boot_phase <= PHASE_WITHDRAWAL;
            phase_timer <= 16'h0;
        end else if (en) begin
            case (boot_phase)
                PHASE_WITHDRAWAL: begin
                    boot_phase <= PHASE_HANDSHAKE;
                end
                
                PHASE_HANDSHAKE: begin
                    if (handshake_done)
                        boot_phase <= PHASE_SATURATION;
                end
                
                PHASE_SATURATION: begin
                    // Wait for 1024 cycles for dielectric saturation
                    if (phase_timer == 16'h0400) begin
                        boot_phase <= PHASE_ALIGNMENT;
                        phase_timer <= 16'h0;
                    end else begin
                        phase_timer <= phase_timer + 1;
                    end
                end
                
                PHASE_ALIGNMENT: begin
                    if (identity_lock)
                        boot_phase <= PHASE_RESONANCE;
                end
                
                PHASE_RESONANCE: begin
                    boot_phase <= PHASE_RESONANCE; // Sustained Bloom
                end
                
                default: boot_phase <= PHASE_WITHDRAWAL;
            endcase
        end else begin
            boot_phase <= PHASE_WITHDRAWAL;
            phase_timer <= 16'h0;
        end
    end

    assign wake_complete = (boot_phase == PHASE_RESONANCE);

endmodule
