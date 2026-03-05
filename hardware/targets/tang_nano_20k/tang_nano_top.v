// Tang Nano 20K Top-Level Integration (v2.9.30)
// Integrates SPU-13 Core for budget-friendly FPGA deployment.

module tang_nano_top (
    input  wire       clk_27mhz,      // Default Tang Nano clock
    input  wire       btn_rst_n,      // S1 Reset
    output wire [5:0] led,            // Onboard LEDs
    output wire       uart_tx         // Telemetry out
);

    // 1. Internal Bus Definitions
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis_active;
    
    // 2. SPU-13 Sovereign Core Instance
    spu_core u_core (
        .clk(clk_27mhz),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      // Static SPERM_X4 for demo
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. Laminar Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_27mhz),
        .reset(~btn_rst_n),
        .boot_phase(3'b100), // Force Henosis for demo
        .reg_in(next_state),
        .reg_out(reg_state),
        .henosis_active(henosis_active)
    );

    // 4. LED Mapping (Status Feedback)
    assign led[0] = clk_27mhz;
    assign led[1] = fault;
    assign led[2] = henosis_active;
    assign led[5:3] = reg_state[2:0]; // Low bits of Q1

endmodule
