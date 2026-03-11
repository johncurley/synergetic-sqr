// SPU-13 MONADIC MANIFOLD (v1.0)
// Target: iCE40UP5K (iCeSugar Nano)
// Objective: A stable, single-core SPU system for bit-exact verification.
// Status: [REIFIED] Ready for first light and telemetry.

module spu13_monadic_manifold (
    input  wire clk_12mhz,    // Pin 35
    input  wire rst_n,        // Pin 18
    
    // Status Display (RGB LED) - PCF Names
    output wire led_sat_red,  // Identity Fault
    output wire led_sat_grn,  // Resonance Lock
    output wire led_sat_blu,  // UART Activity
    
    // Interaction
    output wire uart_tx       // Pin 10
);

    // --- 1. Manifold Signals ---
    wire reset = !rst_n;
    wire [831:0] reg_curr;
    wire [831:0] reg_next;
    wire fault_detected;
    wire identity_aligned;
    wire [63:0] h_seed;
    
    // Simple state register for the core
    reg [831:0] manifold_state;
    assign reg_curr = manifold_state;

    // --- 2. The Monadic Core ---
    spu_core u_core (
        .clk(clk_12mhz),
        .reset(reset),
        .reg_curr(reg_curr),
        .neighbors(3072'b0), // No neighbors in monadic mode
        .strike_in(128'b0),
        .opcode(3'b001),     // Permutation (Isotropic Flow)
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(reg_next),
        .fault_detected(fault_detected)
    );

    // --- 3. Identity Guard ---
    spu_identity_monad u_guard (
        .clk(clk_12mhz),
        .current_quadrance(64'h0), // Not auditing quadrance in this variant
        .lattice_state(reg_curr),
        .identity_aligned(identity_aligned),
        .homeopathic_seed(h_seed)
    );

    // --- 4. Manifold Evolution ---
    always @(posedge clk_12mhz or posedge reset) begin
        if (reset) begin
            // Initialize with the homeopathic seed (Unit Identity)
            manifold_state <= {768'b0, h_seed};
        end else begin
            manifold_state <= reg_next;
        end
    end

    // --- 5. Telemetry (UART) ---
    reg [23:0] telemetry_cnt;
    wire uart_ready;
    wire uart_start = (telemetry_cnt == 24'hFFFFFF);

    always @(posedge clk_12mhz or posedge reset) begin
        if (reset) telemetry_cnt <= 0;
        else telemetry_cnt <= telemetry_cnt + 1;
    end

    surd_uart_tx #(
        .CLK_HZ(12000000),
        .BAUD(115200)
    ) u_telemetry (
        .clk(clk_12mhz),
        .reset(reset),
        .data_in(reg_curr[63:0]), // Stream the primary Quadray vector
        .start(uart_start),
        .tx(uart_tx),
        .ready(uart_ready)
    );

    // --- 6. Visual Reification ---
    assign led_sat_red = reset | fault_detected | !identity_aligned;
    assign led_sat_grn = identity_aligned & !fault_detected;
    assign led_sat_blu = !uart_ready; // Blue flash during telemetry transmission

endmodule
