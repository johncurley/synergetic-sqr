// SPU-13 Unified Hardware Abstraction Layer (v1.0)
// Objective: Pin parity across the SPU-13 fleet (iCE40, ECP5, Gowin, Xilinx).
// Method: Logical mapping to physical constraints.

`ifndef SPU13_PINS_VH
`define SPU13_PINS_VH

// --- 1. Resonant Pulse (Clock) ---
`define SPU_PIN_CLK      clk_phys

// --- 2. Temporal Anchor (Reset) ---
`define SPU_PIN_RST_N    rst_phys_n

// --- 3. Janus Status Display (RGB LED) ---
`define SPU_PIN_LED_R    led_sat_red
`define SPU_PIN_LED_G    led_sat_grn
`define SPU_PIN_LED_B    led_sat_blu

// --- 4. Command & Control (UART) ---
`define SPU_PIN_UART_TX  uart_phys_tx
`define SPU_PIN_UART_RX  uart_phys_rx

// --- 5. Metabolic Sense (Sensing) ---
`define SPU_PIN_ADC      adc_phys_in
`define SPU_PIN_BIAS     bias_phys_in

`endif // SPU13_PINS_VH
