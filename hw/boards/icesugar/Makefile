# SPU-13 Synthesis Makefile: iCeSugar (iCE40UP5K)
# v4.0.0 "The Sovereign Pipeline"

# Configurable Targets
# Options: 
#   TOP=spu13_top (Phase 1.1)
#   TOP=icesugar_full_manifold (Phase 1.2)
#   TOP=spu13_sovereign_top (Sovereign Pipeline v4.0)
#   TOP=spu13_golden_reification (Unboxing)
#   TOP=spu13_minimal_core (Laminar Kernel v1.0)
#   TOP=blinky_symmetry (Laminar Hello World)
TOP ?= spu13_golden_reification
PROJ ?= $(if $(filter blinky_symmetry,$(TOP)),blinky,spu13_icesugar)
PCF ?= $(if $(filter blinky_symmetry spu13_minimal_core spu13_sovereign_top,$(TOP)),Laminar_v1.pcf,spu13_icesugar_full.pcf)
DEVICE = up5k
PACKAGE = sg48

# RTL Sources
RTL_DIR = ../../rtl

SRC_SOVEREIGN = spu13_sovereign_top.v \
                spread_rotor.v \
                $(RTL_DIR)/spu_quadrance_calc.v \
                $(RTL_DIR)/spu_quad_adder.v

SRC_BASE = $(RTL_DIR)/spu_fractal_clk.v \
           $(RTL_DIR)/spu_harmonic_handshake.v \
           $(RTL_DIR)/spu_bowman_sequencer.v \
           $(RTL_DIR)/spu_coherence_ecc.v \
           $(RTL_DIR)/spu_core.v \
           $(RTL_DIR)/spu_ecc.v \
           $(RTL_DIR)/spu_permute.v \
           $(RTL_DIR)/spu_permute_13.v \
           $(RTL_DIR)/spu_smul_13.v \
           $(RTL_DIR)/spu_lattice_13.v \
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
           $(RTL_DIR)/spu_validator.v \
           $(RTL_DIR)/spu_metabolic_sense.v \
           $(RTL_DIR)/spu_thalamus.v \
           $(RTL_DIR)/spu_harmonic_transducer.v \
           $(RTL_DIR)/spu_laminar_power.v \
           $(RTL_DIR)/spu_laminar_gate.v \
           $(RTL_DIR)/spu_oled_visualizer.v \
           $(RTL_DIR)/spu_viscosity_monitor.v \
           $(RTL_DIR)/spu_laminar_buffer.v

ifeq ($(TOP),blinky_symmetry)
  SRC = blinky_symmetry.v
else ifeq ($(TOP),spu13_minimal_core)
  SRC = spu13_minimal_core.v
else ifeq ($(TOP),spu13_sovereign_top)
  SRC = $(SRC_SOVEREIGN)
else
  SRC = $(TOP).v $(SRC_BASE)
endif

all: $(PROJ).bin

# 0. Data Generation: Bridging the Gap
luts:
	python3 generate_rotor_luts.py

# 1. Synthesis: The Logical Sip
$(PROJ).json: $(SRC) luts
	yosys -p "synth_ice40 -top $(TOP) -json $@" $(SRC)

# 2. Place & Route: The Geometric Lattice
$(PROJ).asc: $(PROJ).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $< --pcf $(PCF) --asc $@

# 3. Bitstream: The Physical Bitstream
$(PROJ).bin: $(PROJ).asc
	icepack $< $@

# 4. Flash: The Incarnation
flash: $(PROJ).bin
	icesprog $<

# Legacy compatibility
prog: flash

# 5. Local Simulation: The Virtual Pulse
sim: $(SRC) spu13_sovereign_tb.v luts
	iverilog -o spu13_sim -s spu13_sovereign_tb $(SRC) spu13_sovereign_tb.v
	vvp spu13_sim

# 6. Reset the Void
clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin spu13_sim spu13_sovereign.vcd rotor_cos.hex rotor_sin.hex rotor_den.hex

.PHONY: all flash clean prog sim luts
