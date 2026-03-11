// SPU-13 Thermal Entropy Generator (v1.0)
// Target: iCE40UP5K (Spare LUT optimization)
// Objective: Generate a Unique Biological Signature via LUT meta-stability.
// Logic: Free-running ring oscillators sampled by the Fibonacci Heartbeat.

module spu_thermal_entropy (
    input  wire        clk,
    input  wire        reset,
    output reg  [63:0] entropy_out
);

    // 1. Ring Oscillators (Meta-stable thermal sensors)
    // We use a chain of inverters to create a high-frequency, jittery pulse.
    wire [3:0] osc_out;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : rings
            wire [15:0] chain;
            assign chain[0] = ~chain[15]; // Feedback
            for (genvar j = 0; j < 15; j = j + 1) begin : inverters
                // Physical LUT-based inverters
                (* keep *) assign chain[j+1] = ~chain[j];
            end
            assign osc_out[i] = chain[15];
        end
    endgenerate

    // 2. Entropy Accumulator
    // We sample the jittery oscillators into a 64-bit shifting pool.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            entropy_out <= 64'h0;
        end else begin
            entropy_out <= {entropy_out[62:0], osc_out[0] ^ osc_out[1] ^ osc_out[2] ^ osc_out[3]};
        end
    end

endmodule
