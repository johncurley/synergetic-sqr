# SPU-13 Synthesis Makefile: Tang Nano 20k (GW2A-18)
# v4.0.0 "Universal Parity"

# Configurable Targets
TOP ?= blinky_symmetry
PROJ = spu13_tang20k
CST = Laminar_v1.cst
DEVICE = GW2A-LV18PG256C8/I7
FAMILY = GW2A-18

# RTL Sources
SRC_DIR = ../icesugar

ifeq ($(TOP),blinky_symmetry)
  SRC = $(SRC_DIR)/blinky_symmetry.v
else ifeq ($(TOP),spu13_minimal_core)
  SRC = $(SRC_DIR)/spu13_minimal_core.v
else
  SRC = top.v
endif

all: $(PROJ).fs

$(PROJ).json: $(SRC)
	yosys -p "read_verilog $(SRC); synth_gowin -top $(TOP) -json $@"

$(PROJ).pnr: $(PROJ).json $(CST)
	nextpnr-gowin --device $(DEVICE) --family $(FAMILY) --json $< --cst $(CST) --write $@

$(PROJ).fs: $(PROJ).pnr
	gowin_pack -d $(FAMILY) -o $@ $<

flash: $(PROJ).fs
	openFPGALoader -b tangnano20k $<

clean:
	rm -f $(PROJ).json $(PROJ).pnr $(PROJ).fs

.PHONY: all flash clean
