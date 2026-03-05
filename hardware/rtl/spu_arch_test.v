// SPU-1 Architecture Verification: Clocked Tetrahedral Pulse
// Hardens the permutation logic against timing-induced symmetry breaks

`timescale 1ns/1ps

module spu_arch_test;
    reg clk;
    reg reset;
    reg signed [31:0] q[0:3];
    wire [255:0] bus_in;
    wire [255:0] bus_out;

    // Pack/Unpack Logic
    assign bus_in = { {32'b0, q[3]}, {32'b0, q[2]}, {32'b0, q[1]}, {32'b0, q[0]} };
    
    // SPU-1 Core Component: Q1-Axis Permutator
    // Mapping: (a,b,c,d) -> (a,c,d,b)
    spu_permute permutator (
        .q_in(bus_in),
        .q_out(bus_out)
    );

    // Clock Generator
    always #5 clk = ~clk;

    initial begin
        $display("--- SPU-1 Clocked Architectural Test ---");
        clk = 0;
        reset = 1;
        
        // 1. Initialize Tetrahedron Vertex (Satisfying Parity sum=0)
        q[0] = 65536;  // Q1
        q[1] = -65536; // Q2
        q[2] = 0;      // Q3
        q[3] = 0;      // Q4

        #10 reset = 0;
        $display("Tick 0: Q1=%d, Q2=%d, Q3=%d, Q4=%d | Sum=%d", q[0], q[1], q[2], q[3], (q[0]+q[1]+q[2]+q[3]));

        // 2. Perform 3-Cycle Permutation
        repeat (3) begin
            @(posedge clk);
            q[0] <= bus_out[31:0];
            q[1] <= bus_out[95:64];
            q[2] <= bus_out[159:128];
            q[3] <= bus_out[223:192];
        end

        #10;
        $display("Tick 3: Q1=%d, Q2=%d, Q3=%d, Q4=%d | Sum=%d", q[0], q[1], q[2], q[3], (q[0]+q[1]+q[2]+q[3]));

        if (q[0] == 65536 && q[1] == -65536 && (q[0]+q[1]+q[2]+q[3] == 0))
            $display("PASS: Bit-Exact Identity restored with Parity Integrity.");
        else
            $display("FAIL: Symmetry Break or Drift detected!");

        $display("-----------------------------------------------");
        $finish;
    end
endmodule
