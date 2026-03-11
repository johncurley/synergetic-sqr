// SPU-13 Harmonic Transducer (v3.4.0 Laminar Edition)
// Implementation: Dual-Mode (ASCII + Vector) Transduction.
// Objective: Strike the IVM Lattice with bit-exact impulses.
// Result: Information as Topological Pressure.

module spu_harmonic_transducer (
    input  wire         clk,
    input  wire         reset,
    
    // Mode 1: ASCII Strike (Digital Hammer)
    input  wire [7:0]   ascii_in,
    input  wire         ascii_valid,
    
    // Mode 2: Laminar Vector (Zero-Latency)
    input  wire [15:0]  vector_in,
    input  wire         vector_valid,
    
    output reg  [127:0] ripple_out,
    output wire         membrane_lock
);

    reg signed [31:0] node_a, node_b, node_c, node_d;
    wire signed [31:0] decay_a = node_a >>> 4;
    wire signed [31:0] decay_b = node_b >>> 4;
    wire signed [31:0] decay_c = node_c >>> 4;
    wire signed [31:0] decay_d = node_d >>> 4;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            node_a <= 0; node_b <= 0; node_c <= 0; node_d <= 0;
        end else begin
            if (ascii_valid) begin
                node_a <= (node_a - decay_a) + {14'b0, ascii_in[1:0], 16'b0};
                node_b <= (node_b - decay_b) + {14'b0, ascii_in[3:2], 16'b0};
                node_c <= (node_c - decay_c) + {14'b0, ascii_in[5:4], 16'b0};
                node_d <= (node_d - decay_d) + {14'b0, ascii_in[7:6], 16'b0};
            end else if (vector_valid) begin
                // Map 16-bit vector to 4D axes (4 bits per axis)
                node_a <= (node_a - decay_a) + {12'b0, vector_in[3:0],   16'b0};
                node_b <= (node_b - decay_b) + {12'b0, vector_in[7:4],   16'b0};
                node_c <= (node_c - decay_c) + {12'b0, vector_in[11:8],  16'b0};
                node_d <= (node_d - decay_d) + {12'b0, vector_in[15:12], 16'b0};
            end else begin
                node_a <= node_a - decay_a;
                node_b <= node_b - decay_b;
                node_c <= node_c - decay_c;
                node_d <= node_d - decay_d;
            end
        end
    end

    always @(*) ripple_out = {node_d, node_c, node_b, node_a};
    assign membrane_lock = (node_a == 0 && node_b == 0 && node_c == 0 && node_d == 0);

endmodule
