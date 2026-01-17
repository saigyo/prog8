# ---- Verzeichnisse ----
SRC_DIR   ?= src
BUILD_DIR ?= build

# ---- Tools ----
PETCAT ?= petcat
C1541  ?= c1541
X64SC  ?= x64sc
PROG8C ?= prog8c

# BASIC 2.0, Startadresse $0801 (dez 2049) => -l 0401 (hex)
PETCAT_FLAGS ?= -w2 -l 0401

# ---- Prog8 ----
PROG8C_FLAGS ?= -target c64

# ---- Labels im Diskimage ----
BASIC_LABEL ?= ==== basic ====
P8_LABEL    ?= ==== prog8 ====
LABEL_TYPE  ?= ,s

# ---- Gemeinsames Diskimage ----
DISK_IMAGE    ?= $(BUILD_DIR)/disk.d64
DISK_MANIFEST ?= $(BUILD_DIR)/disk.manifest
DISK_NAME     ?= dev-disk
DISK_ID       ?= 00

# ---- Dateinamen im D64: optional Uppercase ----
UPPERCASE ?= 0
diskname = $(if $(filter 1,$(UPPERCASE)),$(shell printf "%s" "$(1)" | tr '[:lower:]' '[:upper:]'),$(1))

# ---- Sources finden ----
BAS_FILES := $(wildcard $(SRC_DIR)/*.bas)
P8_FILES  := $(wildcard $(SRC_DIR)/*.p8)

BASIC_PROGRAMS := $(sort $(notdir $(basename $(BAS_FILES))))
P8_PROGRAMS    := $(sort $(notdir $(basename $(P8_FILES))))

# ---- Build-Artefakte (separierte Ordner, damit es keine Pattern-Kollision gibt) ----
BASIC_PRG_DIR := $(BUILD_DIR)/basic
P8_PRG_DIR    := $(BUILD_DIR)/prog8

BASIC_PRG_FILES := $(addprefix $(BASIC_PRG_DIR)/,$(addsuffix .prg,$(BASIC_PROGRAMS)))
P8_PRG_FILES    := $(addprefix $(P8_PRG_DIR)/,$(addsuffix .prg,$(P8_PROGRAMS)))

PRG_FILES := $(BASIC_PRG_FILES) $(P8_PRG_FILES)

# ---- Phony ----
.PHONY: all list prg-all d64 clean run-% run-basic-% run-p8-% info-%

all: list

list:
	@echo "Gefundene BASIC-Programme in $(SRC_DIR):"
	@$(if $(BASIC_PROGRAMS),$(foreach p,$(BASIC_PROGRAMS),echo " - $(p)";),echo " (keine *.bas gefunden)";)
	@echo "Gefundene Prog8-Programme in $(SRC_DIR):"
	@$(if $(P8_PROGRAMS),$(foreach p,$(P8_PROGRAMS),echo " - $(p)";),echo " (keine *.p8 gefunden)";)

# ---- Build dirs ----
$(BUILD_DIR):
	mkdir -p "$(BUILD_DIR)"

$(BASIC_PRG_DIR):
	mkdir -p "$(BASIC_PRG_DIR)"

$(P8_PRG_DIR):
	mkdir -p "$(P8_PRG_DIR)"

# ---- 1+2) BASIC -> PRG ----
$(BASIC_PRG_DIR)/%.prg: $(SRC_DIR)/%.bas | $(BASIC_PRG_DIR)
	$(PETCAT) $(PETCAT_FLAGS) -o "$@" "$<"

# ---- Prog8 -> PRG ----
# prog8c schreibt in ein Output-Verzeichnis; wir erwarten dort anschließend $*.prg
$(P8_PRG_DIR)/%.prg: $(SRC_DIR)/%.p8 | $(P8_PRG_DIR)
	$(PROG8C) $(PROG8C_FLAGS) -out "$(P8_PRG_DIR)" "$<"
	@test -f "$@" || { echo "ERROR: prog8c hat '$@' nicht erzeugt"; exit 1; }

# ---- Sammel-Target für alle PRGs ----
prg-all: $(PRG_FILES)

# ---- Manifest: Disk neu bauen, wenn Programmliste oder Disk-Label/ID geändert ----
$(DISK_MANIFEST): | $(BUILD_DIR)
	@{ \
	  echo "DISK_NAME=$(DISK_NAME)"; \
	  echo "DISK_ID=$(DISK_ID)"; \
	  echo "[BASIC]"; printf "%s\n" $(BASIC_PROGRAMS); \
	  echo "[PROG8]"; printf "%s\n" $(P8_PROGRAMS); \
	} > "$@.tmp"
	@cmp -s "$@.tmp" "$@" 2>/dev/null || mv "$@.tmp" "$@"
	@rm -f "$@.tmp"

# ---- 3) Gemeinsames D64 bauen (nur wenn PRG oder Manifest neuer) ----
d64: $(DISK_IMAGE)

$(DISK_IMAGE): $(PRG_FILES) $(DISK_MANIFEST) | $(BUILD_DIR)
	@rm -f "$@"
	$(C1541) -format "$(DISK_NAME),$(DISK_ID)" d64 "$@"
	# --- BASIC ---
	$(if $(BASIC_PROGRAMS), \
		$(C1541) -attach "$@" -write /dev/null "$(BASIC_LABEL)$(LABEL_TYPE)";)
	$(foreach p,$(BASIC_PROGRAMS), \
		$(C1541) -attach "$@" -write "$(BASIC_PRG_DIR)/$(p).prg" "$(call diskname,$(p))";)
	# --- PROG8 ---
	$(if $(P8_PROGRAMS), \
		$(C1541) -attach "$@" -write /dev/null "$(P8_LABEL)$(LABEL_TYPE)";)
	$(foreach p,$(P8_PROGRAMS), \
		$(C1541) -attach "$@" -write "$(P8_PRG_DIR)/$(p).prg" "$(call diskname,$(p))";)

# ---- 4) Starten ----
# BASIC: wichtig! -basicload, damit VICE wie LOAD "name",8 lädt.
run-basic-%: $(DISK_IMAGE)
	$(X64SC) -basicload -autostart "$(DISK_IMAGE):$(call diskname,$*)"

# Prog8 (Maschinencode): ohne -basicload
run-p8-%: $(DISK_IMAGE)
	$(X64SC) -autostart "$(DISK_IMAGE):$(call diskname,$*)"

# Bequemes run-%: wählt automatisch (Prog8 gewinnt bei Namensgleichheit)
run-%: $(DISK_IMAGE)
	@case " $(P8_PROGRAMS) " in \
	  *" $* "*) $(X64SC) -autostart "$(DISK_IMAGE):$(call diskname,$*)";; \
	  *)       $(X64SC) -basicload -autostart "$(DISK_IMAGE):$(call diskname,$*)";; \
	esac

# ---- Debug ----
info-%:
	$(info X64SC='$(X64SC)')
	$(info PROG8C='$(PROG8C)')
	$(info DISK_IMAGE='$(DISK_IMAGE)')
	$(info stem='$*' diskname='$(call diskname,$*)')

clean:
	rm -f "$(BASIC_PRG_DIR)"/*.prg "$(P8_PRG_DIR)"/*.prg "$(DISK_IMAGE)" "$(DISK_MANIFEST)"
