// OrangeCrab Top-Level Integration (v3.1.1)
// Target: Lattice ECP5 (LFE5U-25F) - Open-Toolchain Native

module orangecrab_top (
    input  wire clk_48mhz,    // Onboard oscillator
    input  wire btn_rst_n,    // Reset button
    output wire led_r, led_g, led_b,
    output wire uart_tx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         resonance_lock;

    // 1. SPU-13 Sovereign Core Instance
    spu_core u_core (
        .clk(clk_48mhz),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      // SPERM_X4
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 2. Self-Test Logic
    spu_self_test u_test (
        .clk(clk_48mhz),
        .reset(~btn_rst_n),
        .reg_in(next_state),
        .pass(resonance_lock)
    );

    // 3. Status Mapping
    assign led_r = fault;
    assign led_g = resonance_lock;
    assign led_b = clk_48mhz; // Heartbeat

endmodule
