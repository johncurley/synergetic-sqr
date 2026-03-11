// SPU-13 Harmonic Lattice (v1.0)
// Implementation: 4-Core Harmonic Subset for ECP5 reification.
// Objective: Maintain circular data-flow while fitting within the gate-budget.

module spu_lattice_4 (
    input  wire         clk,
    input  wire         reset,
    input  wire [2:0]   opcode,
    input  wire [1:0]   prime_phase,
    input  wire         sign_flip,
    input  wire [831:0] ext_in,      
    input  wire [127:0] strike_in,
    output wire [831:0] manifold_out, 
    output wire         lattice_fault
);

    wire [831:0] core_state [0:3];
    wire [831:0] next_state [0:3];
    wire [3:0]   core_faults;
    
    assign lattice_fault = |core_faults;
    assign manifold_out  = core_state[0];

    wire [3071:0] neighbor_bus [0:3];
    
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : core_lattice
            // Simplified Circular Interconnect for 4 cores
            assign neighbor_bus[i][0*256 +: 256]  = core_state[(i + 1) % 4][255:0];
            assign neighbor_bus[i][1*256 +: 256]  = core_state[(i + 2) % 4][255:0];
            assign neighbor_bus[i][2*256 +: 256]  = core_state[(i + 3) % 4][255:0];
            assign neighbor_bus[i][3*256 +: 256]  = core_state[(i + 1) % 4][255:0]; // Repeat for bus width
            assign neighbor_bus[i][4*256 +: 256]  = core_state[(i + 2) % 4][255:0];
            assign neighbor_bus[i][5*256 +: 256]  = core_state[(i + 3) % 4][255:0];
            assign neighbor_bus[i][6*256 +: 256]  = core_state[(i + 1) % 4][255:0];
            assign neighbor_bus[i][7*256 +: 256]  = core_state[(i + 2) % 4][255:0];
            assign neighbor_bus[i][8*256 +: 256]  = core_state[(i + 3) % 4][255:0];
            assign neighbor_bus[i][9*256 +: 256]  = core_state[(i + 1) % 4][255:0];
            assign neighbor_bus[i][10*256 +: 256] = core_state[(i + 2) % 4][255:0];
            assign neighbor_bus[i][11*256 +: 256] = core_state[(i + 3) % 4][255:0];

            spu_core u_core (
                .clk(clk),
                .reset(reset),
                .reg_curr(core_state[i]),
                .neighbors(neighbor_bus[i]),
                .strike_in((i == 0) ? strike_in : 128'b0),
                .opcode(opcode),
                .prime_phase(prime_phase),
                .sign_flip(sign_flip),
                .reg_out(next_state[i]),
                .fault_detected(core_faults[i])
            );

            reg [831:0] state_reg;
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    state_reg <= (i == 0) ? ext_in : 832'b0;
                end else begin
                    state_reg <= next_state[i];
                end
            end
            assign core_state[i] = state_reg;
        end
    endgenerate

endmodule
