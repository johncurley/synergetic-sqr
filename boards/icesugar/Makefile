# SPU-13 Synthesis Makefile: iCeSugar (iCE40UP5K)
# v3.1.32 "Laminar Build"

PROJ = spu13_icesugar
TOP  = spu13_top
PCF  = spu13_icesugar_v2.pcf
DEVICE = up5k
PACKAGE = sg48

# RTL Sources
SRC = spu13_top.v \
      ../../rtl/spu_fractal_clk.v \
      ../../rtl/spu_coherence_ecc.v \
      ../../rtl/spu_rational_trig.v \
      ../../rtl/spu_geometry_fluidizer.v \
      ../../rtl/spu_gram_controller.v \
      ../../rtl/spu_fluid_solver.v \
      ../../rtl/spu_annealer.v \
      ../../rtl/spu_tensegrity_balancer.v \
      ../../rtl/spu_harmonic_vis.v \
      ../../rtl/spu_identity_monad.v

all: $(PROJ).bin

$(PROJ).json: $(SRC)
	yosys -p "synth_ice40 -top $(TOP) -json $@" $(SRC)

$(PROJ).asc: $(PROJ).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

$(PROJ).bin: $(PROJ).asc
	icetime -d $(DEVICE) -P $(PACKAGE) -t $<
	icepack $< $@

prog: $(PROJ).bin
	icesprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.PHONY: all prog clean
