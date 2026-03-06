// iCEBreaker Top-Level Integration (v2.9.31)
// Target: Lattice iCE40UP5K (Open-Toolchain Native)

module icebreaker_top (
    input  wire clk_12mhz,
    input  wire btn_rst_n,
    output wire led_red,
    output wire led_green,
    output wire uart_tx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis;

    // SPU-13 Core Instance
    spu_core u_core (
        .clk(clk_12mhz),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      // SPERM_X4
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // Self-Test Logic
    spu_self_test u_test (
        .clk(clk_12mhz),
        .reset(~btn_rst_n),
        .reg_in(next_state),
        .pass(henosis)
    );

    assign led_red   = fault;
    assign led_green = henosis;

endmodule
