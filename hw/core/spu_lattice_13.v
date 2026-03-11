// SPU-13 Phyllotaxis Lattice (v3.3.89)
// Implementation: 13-Core Collective Manifold.
// Objective: Organic Data-Flow via Fibonacci-Spiral Interconnects.
// Result: Isotropic Propagation across the Silicon Fabric.
// Interaction: strike_in port for topological pressure distribution.

module spu_lattice_13 (
    input  wire         clk,
    input  wire         reset,
    input  wire [2:0]   opcode,
    input  wire [1:0]   prime_phase,
    input  wire         sign_flip,
    input  wire [831:0] ext_in,      
    input  wire [127:0] strike_in,   // From Harmonic Transducer
    output wire [831:0] manifold_out, 
    output wire         lattice_fault
);

    // 1. Manifold State Storage (13 Cores x 832 bits)
    wire [831:0] core_state [0:12];
    wire [831:0] next_state [0:12];
    wire [12:0]  core_faults;
    
    assign lattice_fault = |core_faults;
    assign manifold_out  = core_state[0];

    // 2. Fibonacci-Spiral Interconnects (The SQR-Link)
    wire [3071:0] neighbor_bus [0:12];
    
    genvar i;
    generate
        for (i = 0; i < 13; i = i + 1) begin : core_lattice
            assign neighbor_bus[i][0*256 +: 256]  = core_state[(i + 1)  % 13][255:0];
            assign neighbor_bus[i][1*256 +: 256]  = core_state[(i + 2)  % 13][255:0];
            assign neighbor_bus[i][2*256 +: 256]  = core_state[(i + 3)  % 13][255:0];
            assign neighbor_bus[i][3*256 +: 256]  = core_state[(i + 5)  % 13][255:0];
            assign neighbor_bus[i][4*256 +: 256]  = core_state[(i + 8)  % 13][255:0];
            assign neighbor_bus[i][5*256 +: 256]  = core_state[(i + 12) % 13][255:0];
            assign neighbor_bus[i][6*256 +: 256]  = core_state[(i + 13-1)  % 13][255:0];
            assign neighbor_bus[i][7*256 +: 256]  = core_state[(i + 13-2)  % 13][255:0];
            assign neighbor_bus[i][8*256 +: 256]  = core_state[(i + 13-3)  % 13][255:0];
            assign neighbor_bus[i][9*256 +: 256]  = core_state[(i + 13-5)  % 13][255:0];
            assign neighbor_bus[i][10*256 +: 256] = core_state[(i + 13-8)  % 13][255:0];
            assign neighbor_bus[i][11*256 +: 256] = core_state[(i + 13-12) % 13][255:0];

            // 3. Core Instantiation
            spu_core u_core (
                .clk(clk),
                .reset(reset),
                .reg_curr(core_state[i]),
                .neighbors(neighbor_bus[i]),
                .strike_in((i == 0) ? strike_in : 128'b0), // Inject into Core 0
                .opcode(opcode),
                .prime_phase(prime_phase),
                .sign_flip(sign_flip),
                .reg_out(next_state[i]),
                .fault_detected(core_faults[i])
            );

            // 4. State Registration
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
