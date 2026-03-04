## Arty A7-35T Pin Constraints for SPU-1 (v2.6.2)
## Target Board: Digilent Arty A7-35T (Xilinx XC7A35TICSG324-1L)

## 1. System Clock (100MHz)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## 2. Global Reset (Button 0)
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { reset }];

## 3. Status LEDs (Prime Phase Indicator)
set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { current_prime_phase[0] }];
set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { current_prime_phase[1] }];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { at_inertial_rest }];
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { fault_detected }];

## 4. Control Switches (Opcode/Janus Control)
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { opcode[0] }];
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { opcode[1] }];
set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { opcode[2] }];
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { janus_bit }];

## 5. PMOD Connectors (External Address/Data Bus)
## JA - Pins 1-4 (Lower Address Bus)
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { phys_addr_out[0] }];
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { phys_addr_out[1] }];
set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { phys_addr_out[2] }];
set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { phys_addr_out[3] }];
