// Arty A7-35T Top-Level Integration (v3.1.10)
// Target: Xilinx Artix-7 (100MHz Resonant Clock)

module arty_a7_top (
    input  wire       clk_100mhz,
    input  wire       btn_rst_n,      
    input  wire [3:0] sw,             
    output wire [3:0] led,            
    output wire [7:0] pmod_ja,
    input  wire       usb_uart_rx,
    output wire       usb_uart_tx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis_active;
    wire [31:0]  phys_addr;
    
    spu_core u_core (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(sw[2:0]),
        .prime_phase(sw[3:2]),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    spu_gram_controller u_gram (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .janus_bit(sw[0]),
        .addr_in(next_state[31:0]),
        .phys_addr_out(phys_addr)
    );

    spu_laminar_power u_power (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .boot_phase(sw[2:0]),
        .reg_in(next_state),
        .reg_out(reg_state),
        .henosis_active(henosis_active)
    );

    spu_io_bridge #(
        .CLK_FREQ(100000000)
    ) u_io (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(led),
        .pmod_ja_out(pmod_ja),
        .sw_control(sw),
        .serial_rx(usb_uart_rx),
        .serial_tx(usb_uart_tx)
    );

endmodule
