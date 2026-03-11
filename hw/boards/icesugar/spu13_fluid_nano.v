// SPU-13 FLUID NANO ENGINE (v1.0)
// Target: iCE40UP5K (iCeSugar Nano)
// Objective: A standalone, 32-bit Navier-Stokes Monad.
// Feature: Davis Gasket + Henosis + Telemetry.

`include "../../include/spu/spu13_pins.vh"

module spu13_fluid_nano (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    output wire `SPU_PIN_UART_TX
);

    // --- 1. Manifold State ---
    reg signed [31:0] A, B, C, D;
    wire [127:0] reg_curr = {D, C, B, A};
    wire [127:0] reg_next;
    wire fault_detected;
    
    // --- 2. The Davis Core ---
    // Specifically parameterized for the iCeSugar gate budget.
    spu_nano_core #(
        .TAU_Q(64'h00000000_00010000)
    ) u_engine (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .reg_curr(reg_curr),
        .opcode(seq_opcode),
        .prime_phase(2'b00), .sign_flip(1'b0),
        .reg_out(reg_next),
        .fault_detected(fault_detected)
    );

    // --- 3. The Laminar Sequencer ---
    reg [23:0] timer;
    reg [2:0]  seq_opcode;
    always @(posedge `SPU_PIN_CLK or negedge `SPU_PIN_RST_N) begin
        if (!`SPU_PIN_RST_N) begin
            timer <= 0;
            seq_opcode <= 3'b000; // VADD (Initial Injection)
            {D, C, B, A} <= {96'b0, 32'h00010000};
        end else begin
            timer <= timer + 1;
            // Every 0.7s, evolve the state
            if (timer == 24'h7FFFFF) begin
                seq_opcode <= (seq_opcode == 3'b111) ? 3'b001 : 3'b111; // Toggle between ROT and ANNEAL
                {D, C, B, A} <= reg_next;
            end
        end
    end

    // --- 4. Telemetry ---
    wire uart_ready;
    surd_uart_tx #(
        .CLK_HZ(12000000),
        .BAUD(115200)
    ) u_sip (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .data_in({31'b0, fault_detected, A}),
        .start(timer == 24'h0),
        .tx(`SPU_PIN_UART_TX), .ready(uart_ready)
    );

    // --- 5. Visual Reification ---
    assign `SPU_PIN_LED_R = !`SPU_PIN_RST_N | fault_detected;
    assign `SPU_PIN_LED_G = `SPU_PIN_RST_N & !fault_detected;
    assign `SPU_PIN_LED_B = !uart_ready;

endmodule
