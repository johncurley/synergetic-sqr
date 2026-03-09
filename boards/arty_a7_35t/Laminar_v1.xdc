## SPU-13 Physical Constraint File: Laminar v1
## Target: Arty A7-35T (Xilinx Artix-7)

## Main Clock (100MHz)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## The Quadray Outputs (PMOD Header JA)
## Mapping ABCD to Pins 1, 2, 3, 4 of JA
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { leds[0] }]; # Axis A
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { leds[1] }]; # Axis B
set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { leds[2] }]; # Axis C
set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { leds[3] }]; # Axis D

## The Reset Button (BTN0)
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { reset }];
