# ---- Verzeichnisse ----
SRC_DIR   ?= src
BUILD_DIR ?= build

# ---- Tools (ggf. absolute Pfade setzen) ----
PETCAT ?= petcat
C1541  ?= c1541
X64SC  ?= x64sc

# ---- Schalter ----
UPPERCASE ?=

# BASIC 2.0, Startadresse $0801 (dez 2049) => -l 0401 (hex)
PETCAT_FLAGS ?= -w2 -l 0401

# ---- Gemeinsames Diskimage ----
DISK_IMAGE    ?= $(BUILD_DIR)/disk.d64
DISK_MANIFEST ?= $(BUILD_DIR)/disk.manifest
DISK_NAME     ?= dev-disk
DISK_ID       ?= 00

# ---- Programme automatisch finden ----
BAS_FILES := $(wildcard $(SRC_DIR)/*.bas)
PROGRAMS  := $(sort $(notdir $(basename $(BAS_FILES))))
PRG_FILES := $(addprefix $(BUILD_DIR)/,$(addsuffix .prg,$(PROGRAMS)))

# Hilfsfunktion: Dateinamen im C64-Directory UPPERCASEN, wenn aktiviert
upper = $(if $(UPPERCASE),$(shell echo $(1) | tr '[:lower:]' '[:upper:]'),$(1))

#.PHONY: all list prg-all d64 clean \
        $(addprefix prg-,$(PROGRAMS)) $(addprefix run-,$(PROGRAMS))
.PHONY: all list prg-all d64 clean prg-% run-% info-%

all: list

list:
	@echo "Gefundene BASIC-Programme in $(SRC_DIR):"
	@$(if $(PROGRAMS),$(foreach p,$(PROGRAMS),echo " - $(p)";),echo " (keine *.bas gefunden)";)

# Build dir
$(BUILD_DIR):
	mkdir -p "$(BUILD_DIR)"

# ---- 1+2) BASIC -> PRG (Pattern Rule) ----
$(BUILD_DIR)/%.prg: $(SRC_DIR)/%.bas | $(BUILD_DIR)
	$(PETCAT) $(PETCAT_FLAGS) -o "$@" "$<"

prg-all: $(PRG_FILES)

# ---- Manifest: sorgt dafür, dass die Disk auch neu gebaut wird,
#      wenn Programme hinzugefügt/entfernt/umbenannt wurden ----
$(DISK_MANIFEST): | $(BUILD_DIR)
	@{ \
	  echo "DISK_NAME=$(DISK_NAME)"; \
	  echo "DISK_ID=$(DISK_ID)"; \
	  printf "%s\n" $(PROGRAMS); \
	} > "$@.tmp"
	@cmp -s "$@.tmp" "$@" 2>/dev/null || mv "$@.tmp" "$@"
	@rm -f "$@.tmp"

# ---- 3) Gemeinsames D64 bauen und ALLE PRGs reinkopieren ----
# WICHTIG: Dieses Rezept läuft NUR, wenn disk.d64 älter ist als
#          irgendein PRG oder das Manifest (oder wenn disk.d64 fehlt).
d64: $(DISK_IMAGE)

$(DISK_IMAGE): $(PRG_FILES) $(DISK_MANIFEST) | $(BUILD_DIR)
	@rm -f "$@"
	$(C1541) -format "$(DISK_NAME),$(DISK_ID)" d64 "$@"
	$(foreach p,$(PROGRAMS), \
		$(C1541) -attach "$@" -write "$(BUILD_DIR)/$(p).prg" "$(call upper,$(p))";)

# ---- Komfort-Targets je Programm ----
prg-%: $(BUILD_DIR)/%.prg

# ---- 4) VICE starten + Autostart eines Programms von der gemeinsamen Disk ----
run-%: $(DISK_IMAGE)
	@echo "Starting: $(X64SC) -autostart '$(DISK_IMAGE):$(call upper,$*)'"
	$(X64SC) -basicload -autostart "$(DISK_IMAGE):$(call upper,$*)"

clean:
	rm -f "$(BUILD_DIR)"/*.prg "$(DISK_IMAGE)" "$(DISK_MANIFEST)"

info-%:
	$(info X64SC='$(X64SC)')
	$(info DISK_IMAGE='$(DISK_IMAGE)')
	$(info stem='$*' name='$(call upper,$*)')
