// SPU-13 SQR Determinism Testbench (v1.0)
`timescale 1ns/1ps

module sqr_determinism_tb;
    reg clk = 0;
    reg reset = 0;
    always #5 clk = ~clk; 

    reg [63:0] q_init_a, q_init_b, q_init_c, q_init_d;
    wire [63:0] q_out_a, q_out_b, q_out_c, q_out_d;
    
    spu_sqr_rotor uut (
        .clk(clk), .reset(reset),
        .q_in_a(q_init_a), .q_in_b(q_init_b), .q_in_c(q_init_c), .q_in_d(q_init_d),
        .t_param(16'h2AAA), 
        .q_out_a(q_out_a), .q_out_b(q_out_b), .q_out_c(q_out_c), .q_out_d(q_out_d)
    );

    integer i;
    integer max_cycles;
    initial begin
        $display("--- SPU-13 Oath of Coherency: 60-degree Determinism Test ---");
        
        // Define depth based on environment
        if ($test$plusargs("QUICK_AUDIT")) max_cycles = 1;
        else max_cycles = 6;

        // Initial Identity: Apex Vector [1.0, 0, 0, 0]
        q_init_a = 64'h00000000_00010000; 
        q_init_b = 64'h0; q_init_c = 64'h0; q_init_d = 64'h0;
        
        reset = 1; #20 reset = 0;

        for (i = 0; i < max_cycles; i = i + 1) begin
            @(posedge clk);
            q_init_a <= q_out_a;
            q_init_b <= q_out_b;
            q_init_c <= q_out_c;
            q_init_d <= q_out_d;
            $display("Cycle %0d: [%h, %h, %h, %h]", i+1, q_out_a, q_out_b, q_out_c, q_out_d);
        end

        @(posedge clk);
        if (max_cycles == 1) begin
            if (q_out_a == 64'h0 && q_out_b == 64'h00000000_00010000) begin
                $display("SUCCESS: Bit-Perfect Permutation. The Manifold is Laminar.");
                $finish;
            end
        end else if (q_out_a == 64'h00000000_00010000 && q_out_b == 64'h0) begin
            $display("SUCCESS: Bit-Perfect Recovery. The Manifold is Laminar.");
            $finish;
        end
        
        $display("FAILURE: Residual Entropy Detected!");
        $stop;
    end
endmodule
