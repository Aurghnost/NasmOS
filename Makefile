# NOTES :
# faut install grub-mkrescue et xorriso avec sudo apt

ASM = nasm
LINKER = ld
EMULATOR = qemu-system-i386

ISONAME = nasmos

SRC_DIR = core/x86_64/src
INCLUDE_DIR = core/x86_64/include

CONFIG_DIR = config/x86_64

OBJ_DIR = build/obj
BIN_DIR = build/bin

ISOFILES = build/isofiles
ISOMAKER = grub-mkrescue

EXT_TO_COMPILE = nasm
EXT_OTHERS = inc ld cfg

SRC = $(foreach e,$(EXT_TO_COMPILE),$(shell find . -name "*.$(e)"))
SRC := $(SRC:./%=%)
OBJ = $(foreach e,$(EXT_TO_COMPILE),$(SRC:$(SRC_DIR)/%.$(e)=$(OBJ_DIR)/%.o))

ASMFLAGS = -f elf32
LINKERFLAGS = --nmagic -m elf_i386
QEMU_DEBUG_FLAGS = -s -S

iso_x86_64: $(BIN_DIR)/$(ISONAME).iso

.phony: iso_x86_64

$(BIN_DIR)/$(ISONAME).iso: $(ISOFILES)/boot/kernel.bin | $(BIN_DIR)
	$(ISOMAKER) -o $@ $(ISOFILES)

$(ISOFILES)/boot/kernel.bin: $(OBJ)
	ld -o $@ -T $(CONFIG_DIR)/iso/linker.ld --start-group $^ --end-group $(LINKERFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.nasm | $(OBJ_DIR)
	@mkdir -p $(dir $@)
	$(ASM) $< -o $@ $(ASMFLAGS) -I$(INCLUDE_DIR)

$(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

run: $(BIN_DIR)/$(ISONAME).iso
	$(EMULATOR) -cdrom $(BIN_DIR)/$(ISONAME).iso

.phony: run

debug: $(BIN_DIR)/$(ISONAME).iso
	$(EMULATOR) -cdrom $(BIN_DIR)/$(ISONAME).iso $(QEMU_DEBUG_FLAGS)

.phony: debug

clean:
	rm -rf $(OBJ_DIR)
	rm -rf $(BIN_DIR)
	rm -f $(ISOFILES)/boot/kernel.bin

.phony: clean

count:
	@find . -name "" $(foreach e,$(EXT_TO_COMPILE) $(EXT_OTHERS), -or -name "*.$(e)") | xargs wc -l | awk 'BEGIN {total = 0;}{if (NF == 2 && $$2 == "total") total += $$1;} END {print "Total lines count : " total}'

.phony: count
