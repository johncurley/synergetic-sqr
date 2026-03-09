// SPU-13 I/O Bridge: Standard Edition (v3.3.86)
// Implementation: Laminar Frame Protocol (Draft 1.0).
// Objective: Dual-layer I/O for bit-exact telemetry and experimental sensing.

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
    input  wire         coherence_lock, // From Guard
    
    // Physical IO
    output wire [3:0]   led_status,
    output wire [7:0]   pmod_ja_out,
    input  wire [3:0]   sw_control,
    input  wire         serial_rx,
    output wire         serial_tx
);

    // 1. The Laminar Frame Assembler (Telemetry)
    // Frame: [HEADER: Parity][PAYLOAD: State][FOOTER: Coherence]
    wire signed [31:0] a = spu_reg_in[31:0];
    wire signed [31:0] b = spu_reg_in[63:32];
    wire signed [31:0] c = spu_reg_in[95:64];
    wire signed [31:0] d = spu_reg_in[127:96];
    
    // Header: Symmetry Check (A+B+C+D must be Zero)
    wire symmetry_ok = ((a + b + c + d) == 32'sd0);
    
    // Payload: Primary Lane (A)
    wire [31:0] payload = spu_reg_in[31:0];
    
    // Footer: Phase-Lock Confirmation
    wire [7:0] footer = {7'b0, coherence_lock};

    // 2. Telemetry Path (TX)
    surd_uart_tx #(
        .CLK_HZ(CLK_PHYS_HZ),
        .BAUD(115200)
    ) u_telemetry (
        .clk(clk_phys),
        .reset(reset),
        .data_in({symmetry_ok, 23'b0, footer, payload}), // Multiplexed Frame
        .start(|spu_reg_in[31:0]), 
        .tx(serial_tx),
        .ready()
    );

    // 3. Interaction Path (RX): Harmonic Transduction
    wire [7:0] rx_data;
    wire       rx_valid;
    assign rx_valid = !serial_rx; 
    assign rx_data  = 8'h41;      

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
    assign led_status[1] = !symmetry_ok;    // Red-shift if symmetry fails
    assign led_status[2] = clk_resonant;
    assign led_status[3] = coherence_lock;  // Green-lock if resonant

    assign pmod_ja_out = spu_reg_in[7:0];

endmodule
