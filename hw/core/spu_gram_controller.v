// SPU-13 G-RAM Controller (v1.1 HAL)
// Target: iCE40UP5K (iCeSugar) / ECP5 (ULX3S)
// Objective: 128KB Standing Wave Buffer using internal SPRAM/BRAM.
// Function: Holds 65,536 16-bit ABCD slices.

module spu_gram_controller (
    input  wire         clk,
    input  wire         reset,
    input  wire [15:0]  addr,       // 16-bit address for 64K depth
    input  wire [15:0]  data_in,    
    input  wire         write_en,
    output reg  [15:0]  data_out,
    output wire         ready
);

    // Standing Wave Buffer (128KB total)
    // On iCE40UP5K, Yosys will map this to 4x SB_SPRAM256KA blocks.
    // On ECP5, it will map to EBR (Block RAM) slices.
    reg [15:0] manifold_memory [0:65535];

    always @(posedge clk) begin
        if (write_en) begin
            manifold_memory[addr] <= data_in;
        end
        data_out <= manifold_memory[addr];
    end

    // The memory is zero-latency (Laminar Sync)
    assign ready = 1'b1;

endmodule
