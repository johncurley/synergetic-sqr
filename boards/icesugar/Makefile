# SPU-13 Synthesis Makefile: iCeSugar (iCE40UP5K)
# v3.3.47 "Universal Reification"

# Target Selection: spu13_top (Phase 1.1) or icesugar_full_manifold (Phase 1.2)
TOP = spu13_top
PROJ = spu13_icesugar
PCF = spu13_icesugar_v2.pcf

ifeq ($(TOP), icesugar_full_manifold)
    PCF = spu13_icesugar_full.pcf
endif

DEVICE = up5k
PACKAGE = sg48

# RTL Sources
RTL_DIR = ../../rtl
SRC = $(TOP).v \
      $(RTL_DIR)/spu_fractal_clk.v \
      $(RTL_DIR)/spu_harmonic_handshake.v \
      $(RTL_DIR)/spu_bowman_sequencer.v \
      $(RTL_DIR)/spu_coherence_ecc.v \
      $(RTL_DIR)/spu_core.v \
      $(RTL_DIR)/spu_ecc.v \
      $(RTL_DIR)/spu_permute.v \
      $(RTL_DIR)/spu_permute_13.v \
      $(RTL_DIR)/spu_smul_13.v \
      $(RTL_DIR)/spu_rational_trig.v \
      $(RTL_DIR)/spu_geometry_fluidizer.v \
      $(RTL_DIR)/spu_gram_controller.v \
      $(RTL_DIR)/spu_fluid_solver.v \
      $(RTL_DIR)/spu_annealer.v \
      $(RTL_DIR)/spu_tensegrity_balancer.v \
      $(RTL_DIR)/spu_harmonic_vis.v \
      $(RTL_DIR)/spu_identity_monad.v \
      $(RTL_DIR)/spu_fractal_bypass.v \
      $(RTL_DIR)/spu_self_test.v \
      $(RTL_DIR)/spu_io_bridge.v \
      $(RTL_DIR)/surd_uart_tx.v \
      $(RTL_DIR)/surd_multiplier.v \
      $(RTL_DIR)/spu_rational_snap.v \
      $(RTL_DIR)/spu_proprioception.v \
      $(RTL_DIR)/spu_validator.v

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
