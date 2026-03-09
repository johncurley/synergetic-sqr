// SPU-13 I/O Bridge: Metabolic Edition (v3.4.0)
// Implementation: Laminar Frame Protocol (Draft 1.1).
// Objective: Dual-layer I/O with Real-time Power Telemetry.

module spu_io_bridge #(
    parameter CLK_PHYS_HZ = 12000000
)(
    input  wire         clk_phys,
    input  wire         clk_resonant,
    input  wire         reset,
    
    // SPU Interface
    input  wire [831:0] spu_reg_in,
    input  wire [15:0]  microwatts,    // From Metabolic Sense
    input  wire         sip_active,    // From Metabolic Sense
    output wire [127:0] strike_ripple,
    input  wire         fault_detected,
    input  wire         coherence_lock,
    
    // Physical IO
    output wire [3:0]   led_status,
    output wire [7:0]   pmod_ja_out,
    input  wire [3:0]   sw_control,
    input  wire         serial_rx,
    output wire         serial_tx
);

    // 1. The Laminar Frame Assembler (Telemetry)
    // Frame v1.1: [SYMM:1][uW:16][RES:7][FOOTER:8][PAYLOAD:32]
    wire signed [31:0] a = spu_reg_in[31:0];
    wire signed [31:0] b = spu_reg_in[63:32];
    wire signed [31:0] c = spu_reg_in[95:64];
    wire signed [31:0] d = spu_reg_in[127:96];
    
    wire symmetry_ok = ((a + b + c + d) == 32'sd0);
    wire [31:0] payload = spu_reg_in[31:0];
    wire [7:0]  footer = {6'b0, sip_active, coherence_lock};

    // 2. Telemetry Path (TX)
    surd_uart_tx #(
        .CLK_HZ(CLK_PHYS_HZ),
        .BAUD(115200)
    ) u_telemetry (
        .clk(clk_phys),
        .reset(reset),
        .data_in({symmetry_ok, microwatts, 7'b0, footer, payload}), 
        .start(|spu_reg_in[31:0]), 
        .tx(serial_tx),
        .ready()
    );

    // 3. Interaction Path (RX)
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
    assign led_status[1] = !sip_active;     // Red-shift if 'The Gulp' occurs
    assign led_status[2] = clk_resonant;
    assign led_status[3] = coherence_lock;  

    assign pmod_ja_out = spu_reg_in[7:0];

endmodule
