// SPU-11 Permutator Testbench
// Verifies bit-exact 11-axis cyclic closure in RTL simulation.

`timescale 1ns/1ps

module spu_permute_13_tb;
    reg [831:0] q_in;
    wire [831:0] q_out;

    // Instantiate SPU-11 Permutator
    spu_permute_13 uut (
        .q_in(q_in),
        .q_out(q_out)
    );

    initial begin
        $display("--- SPU-11 High-Dimensional Hardware Verification ---");

        // Load 11 unique values into axes Q1..Q11
        q_in = { 64'd11, 64'd10, 64'd9, 64'd8, 64'd7, 64'd6, 64'd5, 64'd4, 64'd3, 64'd2, 64'd1 };

        // Perform 11 Shuffles (Should return to Identity)
        repeat (11) begin
            #10;
            q_in = q_out;
        end

        if (q_in == { 64'd11, 64'd10, 64'd9, 64'd8, 64'd7, 64'd6, 64'd5, 64'd4, 64'd3, 64'd2, 64'd1 }) 
            $display("PASS: 11-Axis Cyclic Identity restored bit-exactly.");
        else 
            $display("FAIL: 11-Axis drift detected! got %h", q_in);

        $display("-------------------------------------------------------");
        $finish;
    end
endmodule
