// TinyFPGA BX Top-Level Integration (v3.3.54)
// Target: Lattice iCE40LP8K
// Implementation: Universal Fractal Heart & Expanded ISA

module tinyfpga_bx_top (
    input  wire clk, // 16MHz
    output wire pin_led,
    output wire usb_p,
    output wire usb_n,
    output wire usb_pu,
    output wire uart_tx,
    input  wire uart_rx
);

    // Disable USB
    assign usb_p = 1'b0;
    assign usb_n = 1'b0;
    assign usb_pu = 1'b0;

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire [3:0]   bridge_leds;
    wire         henosis_pass;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(16000000)
    ) fractal_osc (
        .clk_in(clk),
        .rst_n(1'b1), 
        .en(1'b1),
        .clk_laminar(clk_resonant)
    );

    // 2. SPU-13 Core (Expanded ISA)
    spu_core u_core (
        .clk(clk_resonant),
        .reset(1'b0),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(1'b0),
        .reg_in(next_state),
        .pass(henosis_pass),
        .fail()
    );

    // 4. IO Bridge (UART Telemetry)
    spu_io_bridge #(
        .CLK_PHYS_HZ(16000000)
    ) u_io (
        .clk_phys(clk),
        .clk_resonant(clk_resonant),
        .reset(1'b0),
        .spu_reg_in(next_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign pin_led = henosis_pass;

endmodule
