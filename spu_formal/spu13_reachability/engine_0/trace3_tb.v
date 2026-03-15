`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [127:0] PI_reg_next;
  reg [0:0] PI_instr_complete;
  reg [127:0] PI_reg_curr;
  reg [2:0] PI_opcode;
  reg [0:0] PI_reset;
  wire [0:0] PI_clk = clock;
  reg [0:0] PI_fault_detected;
  spu13_formal UUT (
    .reg_next(PI_reg_next),
    .instr_complete(PI_instr_complete),
    .reg_curr(PI_reg_curr),
    .opcode(PI_opcode),
    .reset(PI_reset),
    .clk(PI_clk),
    .fault_detected(PI_fault_detected)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:107:execute$133  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$139  = 1'b0;
    // UUT.$auto$async2sync.\cc:116:execute$119  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$125  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$131  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$137  = 1'b1;
    UUT.reset_seen = 1'b0;
    UUT.seq_state = 2'b00;

    // state 0
    PI_reg_next = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    PI_instr_complete = 1'b1;
    PI_reg_curr = 128'b11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000100000000000000000000000000000001;
    PI_opcode = 3'b001;
    PI_reset = 1'b1;
    PI_fault_detected = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_reg_next <= 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      PI_instr_complete <= 1'b0;
      PI_reg_curr <= 128'b11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000100000000000000000000000000000001;
      PI_opcode <= 3'b000;
      PI_reset <= 1'b0;
      PI_fault_detected <= 1'b0;
    end

    // state 2
    if (cycle == 1) begin
      PI_reg_next <= 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      PI_instr_complete <= 1'b1;
      PI_reg_curr <= 128'b11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000100000000000000000000000000000001;
      PI_opcode <= 3'b001;
      PI_reset <= 1'b0;
      PI_fault_detected <= 1'b0;
    end

    genclock <= cycle < 2;
    cycle <= cycle + 1;
  end
endmodule
