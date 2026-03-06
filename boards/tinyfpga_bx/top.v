// TinyFPGA BX Top-Level Integration (v3.1.3)
// Target: Lattice iCE40LP8K

module tinyfpga_bx_top (
    input  wire clk_16mhz,
    output wire led,          // User LED
    output wire uart_tx,
    output wire pin_1         // PMOD Mirror
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         henosis;

    spu_core u_core (
        .clk(clk_16mhz), .reset(1'b0),
        .reg_curr(reg_state), .neighbors(3072'b0),
        .opcode(3'b001), .prime_phase(2'b01), .sign_flip(1'b0),
        .reg_out(next_state), .fault_detected()
    );

    spu_self_test u_test (
        .clk(clk_16mhz), .reset(1'b0),
        .reg_in(next_state), .pass(henosis)
    );

    assign led = henosis;
    assign uart_tx = reg_state[0];

endmodule
