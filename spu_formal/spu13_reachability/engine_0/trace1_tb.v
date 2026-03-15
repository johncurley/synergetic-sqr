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
  reg [0:0] PI_fault_detected;
  reg [2:0] PI_opcode;
  reg [0:0] PI_reset;
  reg [0:0] PI_instr_complete;
  wire [0:0] PI_clk = clock;
  reg [127:0] PI_reg_next;
  reg [127:0] PI_reg_curr;
  spu13_formal UUT (
    .fault_detected(PI_fault_detected),
    .opcode(PI_opcode),
    .reset(PI_reset),
    .instr_complete(PI_instr_complete),
    .clk(PI_clk),
    .reg_next(PI_reg_next),
    .reg_curr(PI_reg_curr)
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
    // UUT.$auto$async2sync.\cc:107:execute$51  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$63  = 1'b0;
    // UUT.$auto$async2sync.\cc:116:execute$49  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$55  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$61  = 1'b1;
    UUT.seq_state = 2'b00;

    // state 0
    PI_fault_detected = 1'b0;
    PI_opcode = 3'b001;
    PI_reset = 1'b0;
    PI_instr_complete = 1'b1;
    PI_reg_next = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    PI_reg_curr = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_fault_detected <= 1'b0;
      PI_opcode <= 3'b001;
      PI_reset <= 1'b0;
      PI_instr_complete <= 1'b1;
      PI_reg_next <= 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      PI_reg_curr <= 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end

    genclock <= cycle < 1;
    cycle <= cycle + 1;
  end
endmodule
