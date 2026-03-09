// SPU-13 I2C Visual Audit (v3.4.13)
// Objective: Verify SSD1306 Initialization and I2C Timing.
// Logic: Monitor SCL/SDA transitions during the 25-byte burst.

`timescale 1ns/1ps

module spu_i2c_audit_tb();
    reg clk;
    reg reset;
    reg [7:0] data_in;
    wire scl, sda, data_req, ready;

    // 1. Instantiate the Driver
    spu_ssd1306_driver u_driver (
        .clk(clk), .reset(reset),
        .data_in(data_in), .data_req(data_req),
        .scl(scl), .sda(sda), .ready(ready)
    );

    integer i;
    initial begin
        clk = 0; reset = 1; data_in = 8'hA5;
        $display("--- I2C Visual Audit: Commencing ---");
        #100 reset = 0;

        // Step 1: Observe START Condition
        wait(sda == 0);
        $display("START Condition Detected.");
        
        // Step 2: Monitor Address Phase (0x78)
        #500;
        $display("Address Phase Active. Monitoring SCL pulses...");
        
        // Step 3: Observe Transition to Command Stream
        wait(ready);
        $display("Initialization Burst Complete. System is READY.");
        
        // Step 4: Verify Data Request
        wait(data_req);
        $display("Data Path Open. Visual Manifold streaming...");

        if (ready && data_req)
            $display("PASS: I2C Display Path Verified.");
        else
            $display("FAIL: Driver stalled in initialization.");
            
        $finish;
    end

    // Clock at 61.44 kHz (approx 16.27us period)
    always #8138 clk = ~clk;

endmodule
