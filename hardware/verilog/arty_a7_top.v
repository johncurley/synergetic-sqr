// Arty A7-35T Top-Level Integration (v2.9.20)
// Integrates SPU-13 Core, G-RAM, and Laminar Power for Physical Launch.

module arty_a7_top (
    input  wire       clk_100mhz,
    input  wire       btn_rst_n,      // Active-low reset (Button 0)
    input  wire [3:0] sw,             // Control switches
    output wire [3:0] led,            // Status LEDs
    output wire [7:0] pmod_ja         // Forensic Data Mirror
);

    // 1. Internal Bus Definitions
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis_active;
    wire [31:0]  phys_addr;
    
    // 2. SPU-13 Sovereign Core Instance
    spu_core u_core (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0), // Loopback/BRAM logic integrated in Stage 2
        .opcode(sw[2:0]),
        .prime_phase(sw[3:2]),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. G-RAM Controller Instance
    spu_gram_controller u_gram (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .janus_bit(sw[0]),
        .addr_in(next_state[31:0]),
        .phys_addr_out(phys_addr)
    );

    // 4. Laminar Power Dispatcher (Hysteresis-Zero)
    spu_laminar_power u_power (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .boot_phase(sw[2:0]), // Simplified boot-strap via switches for prototype
        .reg_in(next_state),
        .reg_out(reg_state),
        .henosis_active(henosis_active)
    );

    // 5. I/O Bridge (Physical Feedback)
    spu_io_bridge u_io (
        .clk(clk_100mhz),
        .reset(~btn_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(led),
        .pmod_ja_out(pmod_ja),
        .sw_control(sw)
    );

endmodule
