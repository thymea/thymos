OS_NAME := thymos
target ?= x86_64

# Directories
INCLUDE_DIR := 3rdparty
BUILD_DIR := zig-out
ISO_DIR := $(BUILD_DIR)/$(target)/isodir

# Toolchain
ZIG := zig
ZIGFLAGS := -Doptimize=ReleaseSafe
AS := nasm
ASFLAGS := -f elf64
QEMU_FLAGS :=

# Ensure all variables hold valid values
ifeq ($(filter $(target),x86_64 riscv64),)
    $(error $(target) architecture not supported)
endif

.PHONY: fetchDeps kernel iso run clean

# Run/Emulate the OS in QEMU
run: iso ovmf/ovmf-code-$(target).fd
	qemu-system-$(target) \
		-drive if=pflash,unit=0,format=raw,file=ovmf/ovmf-code-$(target).fd,readonly=on \
		-cdrom $(BUILD_DIR)/$(target)/$(OS_NAME).iso \
		$(QEMUFLAGS)

# ISO
iso: limine.conf kernel
	# Create required directories
	mkdir -p $(ISO_DIR)/boot/limine $(ISO_DIR)/EFI/BOOT
	cp -v $(BUILD_DIR)/bin/kernel.elf $(ISO_DIR)/boot/
	cp -v limine.conf $(ISO_DIR)/boot/limine/

	# Copy the kernel and Limine binaries into the ISO
ifeq ($(target),x86_64)
	cp -v $(addprefix $(INCLUDE_DIR)/limine/, limine-bios.sys limine-bios-cd.bin limine-uefi-cd.bin) $(ISO_DIR)/boot/limine/
	cp -v $(addprefix $(INCLUDE_DIR)/limine/, BOOTIA32.EFI BOOTX64.EFI) $(ISO_DIR)/EFI/BOOT/

	# Create the ISO
	xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
		-apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $(BUILD_DIR)/$(target)/$(OS_NAME).iso

	# Install Limine into the ISO
	./$(INCLUDE_DIR)/limine/limine bios-install $(BUILD_DIR)/$(target)/$(OS_NAME).iso
endif
ifeq ($(target),riscv64)
	cp -v $(INCLUDE_DIR)/limine/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	cp -v $(INCLUDE_DIR)/limine/BOOTRISCV64.EFI $(ISO_DIR)/EFI/BOOT/
	xorriso -as mkisofs -R -r -J \
		-hfsplus -apm-block-size 2048 \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $(BUILD_DIR)/$(target)/$(OS_NAME).iso
endif

# Fetch dependencies which also updates existing ones
fetchDeps: $(INCLUDE_DIR)/limine
	mkdir -p $(INCLUDE_DIR)

	# SSFN - Font loader and text renderer
	wget https://gitlab.com/bztsrc/scalable-font2/-/raw/master/ssfn.h -O $(INCLUDE_DIR)/ssfn.h

	# Tiny Printf - Very small, fast and dependency free `printf` implementation for embedded systems
	wget https://raw.githubusercontent.com/mpaland/printf/refs/heads/master/printf.h -O $(INCLUDE_DIR)/printf.h
	wget https://raw.githubusercontent.com/mpaland/printf/refs/heads/master/printf.c -O src/printf.c

# UEFI firmware
ovmf/ovmf-code-$(target).fd:
	mkdir -p ovmf
	curl -Lo $@ https://github.com/osdev0/edk2-ovmf-nightly/releases/latest/download/ovmf-code-$(target).fd
	case "$(target)" in \
		aarch64) dd if=/dev/zero of=$@ bs=1 count=0 seek=67108864 2>/dev/null;; \
		riscv64) dd if=/dev/zero of=$@ bs=1 count=0 seek=33554432 2>/dev/null;; \
	esac

# Fetch and build the latest version of Limine
$(INCLUDE_DIR)/limine:
	# Limine
	git clone https://codeberg.org/Limine/Limine.git --branch=v9.x-binary --depth=1 $@
	make -C $@

	# Limine bindings for Zig
	zig fetch --save git+https://github.com/voxi0/limine-zig#trunk

# Kernel
kernel: $(BUILD_DIR)/asm.o
	$(ZIG) build $(ZIGFLAGS) -Darch=$(target)

# Helper assembly code
$(BUILD_DIR)/asm.o: src/arch/x86_64/asm.s
	mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

# Clean everything
clean:
	# Build output and cache
	rm -rf .zig-cache zig-out
