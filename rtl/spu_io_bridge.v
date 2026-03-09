// SPU-13 I/O Bridge: Harmonic Edition (v3.3.84)
// Implementation: Capturing UART 'Hammer Strikes' for Lattice Excitation.
// Objective: Dual-domain bridge for telemetry and interactive resonance.

module spu_io_bridge #(
    parameter CLK_PHYS_HZ = 12000000
)(
    input  wire         clk_phys,      // High-speed oscillator
    input  wire         clk_resonant,  // 61.44 kHz heartbeat
    input  wire         reset,
    
    // SPU Interface
    input  wire [831:0] spu_reg_in,
    output wire [127:0] strike_ripple, // To SPU injection path
    input  wire         fault_detected,
    
    // Physical IO
    output wire [3:0]   led_status,
    output wire [7:0]   pmod_ja_out,
    input  wire [3:0]   sw_control,
    input  wire         serial_rx,
    output wire         serial_tx
);

    // 1. Telemetry Path (TX): SPU -> Host
    // Sending the A-lane state for monitoring
    surd_uart_tx #(
        .CLK_HZ(CLK_PHYS_HZ),
        .BAUD(115200)
    ) u_telemetry (
        .clk(clk_phys),
        .reset(reset),
        .data_in(spu_reg_in[31:0]),
        .start(|spu_reg_in[31:0]), 
        .tx(serial_tx),
        .ready()
    );

    // 2. Interaction Path (RX): Host -> SPU
    // Capture 'Hammer Strikes' from the keyboard
    wire [7:0] rx_data;
    wire       rx_valid;
    
    // Simple UART RX (Conceptual for Phase 1.3)
    // In a physical reification, this would be a full UART RX module.
    // For now, we bridge the valid signal to the transducer.
    assign rx_valid = !serial_rx; // Falling edge detection (Start bit)
    assign rx_data  = 8'h41;      // Static 'A' for initial reification

    // 3. The Harmonic Transducer: The Resonant Membrane
    spu_harmonic_transducer u_membrane (
        .clk(clk_resonant),
        .reset(reset),
        .ascii_in(rx_data),
        .data_valid(rx_valid),
        .ripple_out(strike_ripple),
        .membrane_lock()
    );

    // 4. Status Reification
    assign led_status[0] = fault_detected;
    assign led_status[1] = !serial_rx;      // Pulse on strike
    assign led_status[2] = clk_resonant;
    assign led_status[3] = |strike_ripple;  // Active ripple intensity

    assign pmod_ja_out = spu_reg_in[7:0];

endmodule
