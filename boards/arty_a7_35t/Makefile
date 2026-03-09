# SPU-13 Synthesis Makefile: Arty A7-35T (Artix-7)
# v4.0.0 "Universal Parity"

# Configurable Targets
TOP ?= blinky_symmetry
PROJ = spu13_arty7
XDC = Laminar_v1.xdc
DEVICE = xc7a35tcsg324-1

# RTL Sources
SRC_DIR = ../icesugar

ifeq ($(TOP),blinky_symmetry)
  SRC = $(SRC_DIR)/blinky_symmetry.v
else ifeq ($(TOP),spu13_minimal_core)
  SRC = $(SRC_DIR)/spu13_minimal_core.v
else
  SRC = top.v
endif

all: $(PROJ).bit

$(PROJ).json: $(SRC)
	yosys -p "read_verilog $(SRC); synth_xilinx -top $(TOP) -json $@"

$(PROJ).fASM: $(PROJ).json $(XDC)
	nextpnr-xilinx --chip xc7a35tcsg324-1 --json $< --xdc $(XDC) --fasm $@

$(PROJ).bit: $(PROJ).fASM
	xc7frames2bit --part xc7a35tcsg324-1 --fasm $< --bitstream $@

flash: $(PROJ).bit
	openFPGALoader -b arty_a7_35t $<

clean:
	rm -f $(PROJ).json $(PROJ).fASM $(PROJ).bit

.PHONY: all flash clean
