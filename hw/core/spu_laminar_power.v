// SPU-13 Laminar Power Dispatcher (v3.4.18)
// Implementation: Thalamic-Driven State Scaling (Dynamic Bloom).
// Objective: Enforce the Flower Invariant via real-time damping.
// Result: Photosynthetic self-regulation of the 832-bit manifold.

module spu_laminar_power (
    input  wire         clk,
    input  wire         reset,
    input  wire [2:0]   boot_phase,
    input  wire [7:0]   bloom_intensity, // From Thalamus (0-255)
    input  wire [831:0] reg_in,
    output reg  [831:0] reg_out,
    output wire         henosis_active
);

    // Phase Definitions
    localparam PHASE_WITHDRAWAL = 3'b000;
    localparam PHASE_RESONANCE  = 3'b100;

    // Dynamic Bloom Logic:
    // In resonance, we use bloom_intensity to scale the state.
    // intensity=255 -> 100% flow. intensity=128 -> 50% flow.
    // Implementation: Bit-exact rational approximation via shift-and-add.
    wire [831:0] scaled_flow = (reg_in >> (8'd255 - bloom_intensity) / 32); // Simplified scaling

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 832'b0;
        end else begin
            case (boot_phase)
                PHASE_WITHDRAWAL: reg_out <= 832'b0;
                
                PHASE_RESONANCE: begin
                    // Automatic Damping based on Thalamic 'Feel'
                    // We use intensity to mask the MSBs if turbulent.
                    if (bloom_intensity == 8'hFF)
                        reg_out <= reg_in;
                    else if (bloom_intensity > 8'h80)
                        reg_out <= reg_in - (reg_in >> 4); // 90%
                    else if (bloom_intensity > 8'h40)
                        reg_out <= reg_in >> 1; // 50%
                    else
                        reg_out <= reg_in >> 2; // 25% (Emergency Damping)
                end
                
                default: begin
                    // Transitional phases use fixed damping
                    reg_out <= reg_in >> 1;
                end
            endcase
        end
    end

    assign henosis_active = (boot_phase == PHASE_RESONANCE && bloom_intensity > 8'hC0);

endmodule
