// SPU-13 Kindness Guard (v2.9.18)
// Function: Monitors for 90-degree vector violations and thermal instability.
// Logic: Triggers asic_halt if parity or temperature exceed safety envelopes.

module spu_alignment_guard (
    input  wire         clk,
    input  wire         reset,
    input  wire [831:0] reg_state,
    input  wire         temp_fault,   // From thermal sensor
    output reg          asic_halt,    // Global Kill-Switch
    output wire [3:0]   error_code
);

    // 1. Isotropic Parity Check
    // Verifies the Thomson Invariant: sum(Q) == 0
    reg [31:0] parity_sum_a;
    reg [31:0] parity_sum_b;
    
    integer i;
    always @(*) begin
        parity_sum_a = 0;
        parity_sum_b = 0;
        for (i = 0; i < 13; i = i + 1) begin
            parity_sum_a = parity_sum_a + reg_state[i*64 +: 32];
            parity_sum_b = parity_sum_b + reg_state[i*64+32 +: 32];
        end
    end

    wire alignment_violation = (parity_sum_a != 0) || (parity_sum_b != 0);

    // 2. Hard-Stop Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            asic_halt <= 1'b0;
        end else if (alignment_violation || temp_fault) begin
            asic_halt <= 1'b1; // Trigger immediate system zero-out
        end
    end

    // Error Codes: 0001 = Parity, 0010 = Thermal, 0011 = Both
    assign error_code = {2'b0, temp_fault, alignment_violation};

endmodule
