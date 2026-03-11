# SPU-13 Sovereign Forge: Master Makefile (v1.0)
# Target: iCE40UP5K (iCeSugar Standard)
# Objective: Shielded Development with Automated Backups.

PROJ = spu13_cortex
TOP = top
DEVICE = up5k
PACKAGE = sg48
PCF = hw/boards/icesugar/spu13_icesugar_v2.pcf

# Source Directories
CORE_DIR = hw/core
BOARD_DIR = hw/boards/icesugar

# Toolchain
YOSYS = yosys
NEXTPNR = nextpnr-ice40
ICEPACK = icepack
ICEPROG = icesprog # Change to iceprog if using FTDI directly

# 1. Synthesis (Behavioral -> Gate Level)
$(PROJ).json: $(BOARD_DIR)/spu13_cortex.v $(CORE_DIR)/*.v
	$(YOSYS) -ql design.log -p "synth_ice40 -top $(TOP) -json $@" $^

# 2. Place & Route (Gate Level -> Physical Map)
$(PROJ).asc: $(PROJ).json $(PCF)
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

# 3. Packaging (Physical Map -> Bitstream)
$(PROJ).bin: $(PROJ).asc
	$(ICEPACK) $< $@

# --- THE SHIELDED COMMANDS ---

# 4. PROTECT: Full 8MB Backup (The Birth Certificate)
# Run this ONCE before any soul-swapping.
protect:
	@echo "[SHIELD] Commencing Full Flash Audit..."
	$(ICEPROG) -r golden_birth_certificate.bin
	@echo "[SUCCESS] Birth Certificate archived."

# 5. STRIKE: Flash only the Bitstream (The Body)
# This targets the start of the flash but respects the boot-vector.
strike: $(PROJ).bin
	@echo "[SHIELD] Striking the Hardware Vessel..."
	$(ICEPROG) $<

# 6. BAPTIZE: Flash only the User Soul (The Mind)
# Targets the 0x100000 offset to protect the Ghost Kernel.
baptize: software/hello_manifold.hex
	@echo "[SHIELD] Injecting User Soul at 0x100000..."
	$(ICEPROG) -o 0x100000 $<

# --- CLEANUP ---
clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin design.log

.PHONY: all strike baptize protect clean
