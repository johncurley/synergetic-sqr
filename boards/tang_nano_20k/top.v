// Tang Nano 20k Top-Level Integration (v3.1.36)
// Target: Gowin GW2A-18C
// Implementation: Universal Fractal Heart (61.44 kHz)

module tang_nano_20k_top (
    input  wire sys_clk, // 27MHz
    input  wire sys_rst_n,
    output wire [5:0] led,
    output wire uart_tx,
    input  wire uart_rx
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis_active;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(27000000)
    ) fractal_osc (
        .clk_in(sys_clk),
        .rst_n(sys_rst_n),
        .en(1'b1),
        .clk_laminar(clk_resonant)
    );

    // 2. SPU-13 Core
    spu_core u_core (
        .clk(clk_resonant),
        .reset(~sys_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_resonant),
        .reset(~sys_rst_n),
        .boot_phase(3'b001),
        .reg_in(next_state),
        .reg_out(reg_state),
        .henosis_active(henosis_active)
    );

    // 4. IO Bridge
    spu_io_bridge #(
        .CLK_PHYS_HZ(27000000)
    ) u_io (
        .clk_phys(sys_clk),
        .clk_resonant(clk_resonant),
        .reset(~sys_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(led[3:0]),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led[4] = clk_resonant;
    assign led[5] = fault;

endmodule
