# SPU-13 Synthesis Makefile: OrangeCrab (ECP5-25F)
# v4.0.0 "Universal Parity"

# Configurable Targets
# Options: 
#   TOP=blinky_symmetry (Laminar Hello World)
#   TOP=spu13_minimal_core (Laminar Kernel v1.0)
TOP ?= blinky_symmetry
PROJ = spu13_orangecrab
PCF = Laminar_v1.lpf
DEVICE = 25k
PACKAGE = CSFBGA285

# RTL Sources
RTL_DIR = ../../rtl
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
	yosys -p "synth_ecp5 -top $(TOP) -json $@" $(SRC)

$(PROJ).config: $(PROJ).json $(PCF)
	nextpnr-ecp5 --$(DEVICE) --package $(PACKAGE) --json $< --lpf $(PCF) --textcfg $@

$(PROJ).bit: $(PROJ).config
	ecppack $< $@

flash: $(PROJ).bit
	dfu-util -D $<

clean:
	rm -f $(PROJ).json $(PROJ).config $(PROJ).bit

.PHONY: all flash clean
