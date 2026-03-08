# SPU-13 Synthesis Makefile: iCeSugar (iCE40UP5K)
# v3.1.32 "Laminar Build"

PROJ = spu13_icesugar
TOP  = icesugar_top
PCF  = icesugar.pcf
DEVICE = up5k
PACKAGE = sg48

# RTL Sources
SRC = top.v \
      ../../rtl/spu_core.v \
      ../../rtl/spu_ecc.v \
      ../../rtl/spu_permute.v \
      ../../rtl/spu_permute_13.v \
      ../../rtl/spu_smul_13.v \
      ../../rtl/spu_io_bridge.v \
      ../../rtl/surd_uart_tx.v

all: $(PROJ).bin

$(PROJ).json: $(SRC)
	yosys -p "synth_ice40 -top $(TOP) -json $@" $(SRC)

$(PROJ).asc: $(PROJ).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

prog: $(PROJ).bin
	icesprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.PHONY: all prog clean
