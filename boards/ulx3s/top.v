// ULX3S Top-Level Integration (v3.1.3)
// Target: Lattice ECP5 (LFE5U-85F)

module ulx3s_top (
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    output wire [7:0] led,
    output wire ftdi_tx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         henosis;

    spu_core u_core (
        .clk(clk_25mhz), .reset(btn[0]),
        .reg_curr(reg_state), .neighbors(3072'b0),
        .opcode(3'b001), .prime_phase(2'b01), .sign_flip(1'b0),
        .reg_out(next_state), .fault_detected()
    );

    spu_self_test u_test (
        .clk(clk_25mhz), .reset(btn[0]),
        .reg_in(next_state), .pass(henosis)
    );

    assign led[0] = henosis;
    assign led[7:1] = reg_state[6:0];
    assign ftdi_tx = reg_state[0];

endmodule
