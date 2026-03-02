OS_NAME ?= thymos
ARCH ?= x86_64

# Directories
SRC_DIR := src
INCLUDE_DIR := include
LIMINE_DIR := $(INCLUDE_DIR)/limine
BUILD_DIR := build
FONTS_DIR := fonts
ISO_DIR := $(BUILD_DIR)/isodir/$(ARCH)

# Toolchain
CC := $(ARCH)-elf-gcc
CXX := $(ARCH)-elf-g++
LD := ld
AS := nasm
COMMON_FLAGS := -I $(INCLUDE_DIR) -I $(SRC_DIR) -Wall -Wextra -Werror -pedantic-errors \
			-m64 -mabi=sysv -mno-80387 -mno-sse2 -mno-red-zone -mcmodel=kernel \
			-fno-builtin -fno-stack-protector -fno-stack-protector -fno-lto -fno-PIE -fno-PIC -fno-exceptions \
			-ffreestanding -ffunction-sections -fdata-sections -DPRINTF_INCLUDE_CONFIG_H=1
CFLAGS := $(COMMON_FLAGS)
CXXFLAGS := $(COMMON_FLAGS) -std=c++26 -Wno-register -fno-rtti
LDFLAGS := -nostdlib -static -z max-page-size=0x1000

# Find all source files
SRCS := $(shell find $(SRC_DIR) -name "*.cpp") $(INCLUDE_DIR)/printf/printf.c
FONTS := $(shell find $(FONTS_DIR) -name "*.sfn")
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o) $(FONTS:%=$(BUILD_DIR)/%.o)

# Architecture specific
ifeq ($(ARCH), x86_64)
	CXXFLAGS += -march=x86-64
	ASFLAGS := -f elf64
endif

# Default target
.PHONY: all
all: $(BUILD_DIR)/$(OS_NAME).iso

# Fetch dependencies
.PHONY: fetchDeps
fetchDeps:
	@echo "[DEPS] Fetching dependencies/libraries"
	@mkdir -p $(INCLUDE_DIR)

	# Limine
	@echo "[DEPS] Fetching Limine"
	@git clone https://codeberg.org/Limine/Limine.git --branch=v10.x-binary --depth=1 $(LIMINE_DIR)
	@rm -rf $(LIMINE_DIR)/.git
	@make -C $(LIMINE_DIR)
	@echo "[DEPS] Fetching Limine protocol header file"
	@wget https://codeberg.org/Limine/limine-protocol/raw/branch/trunk/include/limine.h -O $(LIMINE_DIR)/limine.h

	# SSFN text renderer
	@echo "[DEPS] Fetching SSFN header file"
	@wget https://gitlab.com/bztsrc/scalable-font2/-/raw/master/ssfn.h?ref_type=heads -O $(INCLUDE_DIR)/ssfn.h

	# Tiny printf implementation
	@echo "[DEPS] Fetching Tiny Printf implementation"
	@mkdir -p $(INCLUDE_DIR)/printf
	@wget https://raw.githubusercontent.com/eyalroz/printf/refs/heads/master/src/printf/printf.h -O $(INCLUDE_DIR)/printf/printf.h
	@wget https://raw.githubusercontent.com/eyalroz/printf/refs/heads/master/src/printf/printf.c -O $(INCLUDE_DIR)/printf/printf.c

# Emulate OS in QEMU
run: $(BUILD_DIR)/$(OS_NAME).iso
	@echo "[QEMU] Running $(OS_NAME).iso " && qemu-system-$(ARCH) -m 512 -cdrom $<

# Create bootable ISO
$(BUILD_DIR)/$(OS_NAME).iso: limine.conf kernel
	# Create required directories
	@rm -rf $(ISO_DIR)
	@mkdir -p $(ISO_DIR)/boot/limine $(ISO_DIR)/EFI/BOOT

	# Copy Limine configuration and kernel binary over
	@cp limine.conf $(ISO_DIR)/boot/limine/
	@cp $(BUILD_DIR)/$(OS_NAME) $(ISO_DIR)/boot/

	# Copy Limine files into ISO
	@cp $(addprefix $(LIMINE_DIR)/limine-, bios.sys bios-cd.bin uefi-cd.bin) $(ISO_DIR)/boot/limine/
	@cp $(addprefix $(LIMINE_DIR)/BOOT, IA32.EFI X64.EFI) $(ISO_DIR)/EFI/BOOT/

	# Create the ISO
	@xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $@
	@./$(LIMINE_DIR)/limine bios-install $@
	@echo "------------------------"
	@echo "[OK] $@ created"

# Kernel
kernel: $(SRC_DIR)/arch/$(ARCH)/linker.ld $(OBJS)
	@echo "[LD] $<" && $(LD) $(LDFLAGS) -T $< $(OBJS) -o $(BUILD_DIR)/$(OS_NAME)

# Compilation rules
$(BUILD_DIR)/%.cpp.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "[CXX] $<" && $(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo "[CC] $<" && $(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.asm.o: %.asm
	@mkdir -p $(dir $@)
	@echo "[AS] $<" && $(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.sfn.o: %.sfn
	@mkdir -p $(dir $@)
	@$(LD) -r -b binary $< -o $@

# Clean everything
.PHONY: cleanDeps clean
cleanDeps:
	@rm -rf $(addprefix $(INCLUDE_DIR)/, limine printf/printf.h printf/printf.c)
clean:
	@rm -rf $(BUILD_DIR)
