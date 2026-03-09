// SPU-13 Laminar Power Dispatcher (v3.3.94)
// Implementation: Phase-Aligned State Release (The Bloom).
// Objective: Prevent 'Inrush Turbulence' during the Bowman Wake.
// Result: Effortless transition from Void to Resonant Flow.

module spu_laminar_power (
    input  wire         clk,
    input  wire         reset,
    input  wire [2:0]   boot_phase,
    input  wire [831:0] reg_in,
    output reg  [831:0] reg_out,
    output wire         henosis_active
);

    // Phase Definitions (Aligned with Bowman Sequencer)
    localparam PHASE_WITHDRAWAL = 3'b000;
    localparam PHASE_HANDSHAKE  = 3'b001;
    localparam PHASE_SATURATION  = 3'b010;
    localparam PHASE_ALIGNMENT   = 3'b011;
    localparam PHASE_RESONANCE   = 3'b100;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 832'b0;
        end else begin
            case (boot_phase)
                PHASE_WITHDRAWAL: begin
                    // The Void: Absolute Silence
                    reg_out <= 832'b0;
                end
                
                PHASE_HANDSHAKE: begin
                    // Handshake: Minimal state for sonic diagnostic
                    reg_out <= {800'b0, reg_in[31:0]};
                end
                
                PHASE_SATURATION: begin
                    // Saturation: Geometric Damping (50% amplitude)
                    // We use bit-shifts to 'sip' the energy.
                    reg_out <= reg_in >> 1;
                end
                
                PHASE_ALIGNMENT: begin
                    // Alignment: IVM Snapping (90% amplitude)
                    // Near-full flow to allow the Identity Gate to lock.
                    reg_out <= reg_in - (reg_in >> 4);
                end
                
                PHASE_RESONANCE: begin
                    // Resonance: Full Laminar Bloom
                    reg_out <= reg_in;
                end
                
                default: reg_out <= 832'b0;
            endcase
        end
    end

    assign henosis_active = (boot_phase == PHASE_RESONANCE);

endmodule
