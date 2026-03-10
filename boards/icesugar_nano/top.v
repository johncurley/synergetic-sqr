// SPU-13 NANO SEED (v1.2 Programmable)
// Target: iCE40LP1K (iCeSugar Nano)
// Objective: A programmable, 32-bit SPU monad for 1k LUTs.
// Feature: Bit-Serial Davis Gasket + SAS Instruction Sequencer.

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
    
    // --- 2. Instruction Sequencer (The Bloom) ---
    reg [7:0] instruction_rom [0:15];
    reg [3:0] pc;
    reg [23:0] timer;
    
    initial begin
        $readmemh("../../software/bloom.hex", instruction_rom);
    end

    wire [7:0] current_instr = instruction_rom[pc];
    wire [2:0] opcode      = current_instr[7:5];
    wire [1:0] prime_phase = current_instr[4:3];
    wire       sign_flip   = current_instr[2];

    // --- 3. The Serial Davis Gasket ---
    wire over_curvature;
    wire audit_ready;
    reg  audit_start;
    
    spu_serial_davis_gate #(
        .TAU_Q(32'h0400)
    ) u_gate (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .a(A[31:16]), .b(B[31:16]), .c(C[31:16]), .d(D[31:16]),
        .start(audit_start),
        .over_curvature(over_curvature),
        .ready(audit_ready)
    );

    // --- 4. The Nano Core (ALU) ---
    spu_nano_core u_core (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .reg_curr(reg_curr),
        .opcode(opcode),
        .prime_phase(prime_phase), .sign_flip(sign_flip),
        .reg_out(reg_next),
        .fault_detected(fault_detected)
    );

    // --- 5. Laminar State Machine ---
    localparam IDLE=0, AUDIT=1, COMMIT=2, SIP=3;
    reg [1:0] state;

    always @(posedge `SPU_PIN_CLK or negedge `SPU_PIN_RST_N) begin
        if (!`SPU_PIN_RST_N) begin
            timer <= 0;
            pc <= 0;
            state <= IDLE;
            {D, C, B, A} <= {96'b0, 32'h00010000};
            audit_start <= 0;
        end else begin
            timer <= timer + 1;
            case (state)
                IDLE: begin
                    if (timer == 24'h7FFFFF) state <= AUDIT;
                end
                
                AUDIT: begin
                    audit_start <= 1;
                    if (audit_ready) begin
                        audit_start <= 0;
                        state <= COMMIT;
                    end
                end
                
                COMMIT: begin
                    {D, C, B, A} <= reg_next;
                    if (opcode == 3'b100) pc <= 0; // LEAP to START
                    else pc <= pc + 1;
                    state <= SIP;
                end
                
                SIP: begin
                    state <= IDLE;
                    timer <= 0;
                end
            endcase
        end
    end

    // --- 6. Telemetry ---
    wire uart_ready;
    surd_uart_tx #(
        .CLK_HZ(12000000),
        .BAUD(115200)
    ) u_sip (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .data_in({31'b0, over_curvature | fault_detected, A}),
        .start(state == COMMIT),
        .tx(`SPU_PIN_UART_TX), .ready(uart_ready)
    );

    // --- 7. Visual Reification ---
    assign `SPU_PIN_LED_R = over_curvature | fault_detected;
    assign `SPU_PIN_LED_G = !`SPU_PIN_RST_N; // Heartbeat during Reset
    assign `SPU_PIN_LED_B = !uart_ready;

endmodule
