// Arty A7-35T Top-Level Integration (v3.3.54)
// Target: Xilinx Artix-7
// Implementation: Universal Fractal Heart & Expanded ISA

module arty_a7_top (
    input  wire       clk_100mhz,
    input  wire       btn_rst_n,      
    input  wire [3:0] sw,             
    output wire [3:0] led,            
    output wire [7:0] pmod_ja,
    input  wire       usb_uart_rx,
    output wire       usb_uart_tx
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis_pass;
    
    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(100000000)
    ) fractal_osc (
        .clk_in(clk_100mhz),
        .rst_n(btn_rst_n),
        .en(1'b1), 
        .clk_laminar(clk_resonant)
    );

    // 2. SPU-13 Core Manifold (Expanded ISA)
    spu_core u_core (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(sw[2:0]),
        .prime_phase(sw[3:2]),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .reg_in(next_state),
        .pass(henosis_pass),
        .fail()
    );

    // 4. IO Bridge (UART Telemetry)
    spu_io_bridge #(
        .CLK_PHYS_HZ(100000000)
    ) u_io (
        .clk_phys(clk_100mhz),
        .clk_resonant(clk_resonant),
        .reset(~btn_rst_n),
        .spu_reg_in(next_state),
        .fault_detected(fault),
        .led_status(led),
        .pmod_ja_out(pmod_ja),
        .sw_control(sw),
        .serial_rx(usb_uart_rx),
        .serial_tx(usb_uart_tx)
    );

endmodule
