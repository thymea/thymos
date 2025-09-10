OS_NAME := thymos
target ?= x86_64
cpu_x86_64 ?= host
cpu_riscv64 ?= sifive-u54
cpu_aarch64 ?= cortex-a72

# Directories
INCLUDE_DIR := 3rdparty
BUILD_DIR := zig-out
ISO_DIR := $(BUILD_DIR)/$(target)/isodir

# Toolchain
ZIGFLAGS := -Darch=$(target) -Doptimize=ReleaseSafe
QEMU_FLAGS := -serial stdio -cpu $(cpu_$(target))
QEMU_FLAGS_x86_64 := --enable-kvm
QEMU_FLAGS_riscv64 := -machine virt \
		-device ramfb -device qemu-xhci -device usb-kbd -device usb-mouse
QEMU_FLAGS_aarch64 := -machine virt \
		-device ramfb -device qemu-xhci -device usb-kbd -device usb-mouse

# Ensure all variables hold valid values
ifeq ($(filter $(target),x86_64 riscv64 aarch64),)
    $(error $(target) architecture not supported)
endif

# Run/Emulate the OS in QEMU
.PHONY: run
run: iso ovmf/ovmf-code-$(target).fd
	qemu-system-$(target) \
		-drive if=pflash,unit=0,format=raw,file=ovmf/ovmf-code-$(target).fd,readonly=on \
		-cdrom $(BUILD_DIR)/$(target)/$(OS_NAME).iso \
		$(QEMU_FLAGS) $(QEMU_FLAGS_$(target))

# ISO
.PHONY: iso
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
ifeq ($(target),aarch64)
	cp -v $(INCLUDE_DIR)/limine/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	cp -v $(INCLUDE_DIR)/limine/BOOTAA64.EFI $(ISO_DIR)/EFI/BOOT/
	xorriso -as mkisofs -R -r -J \
		-hfsplus -apm-block-size 2048 \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $(BUILD_DIR)/$(target)/$(OS_NAME).iso
endif

# Kernel
.PHONY: kernel
kernel:
	zig build $(ZIGFLAGS)

# Fetch dependencies
.PHONY: fetchDeps
fetchDeps: $(INCLUDE_DIR)/limine
	mkdir -p $(INCLUDE_DIR)

	# SSFN - Font loader and text renderer
	wget https://gitlab.com/bztsrc/scalable-font2/-/raw/master/ssfn.h -O $(INCLUDE_DIR)/ssfn.h

	# Tiny Printf - Very small, fast and dependency free `printf` implementation for embedded systems
	wget https://raw.githubusercontent.com/mpaland/printf/refs/heads/master/printf.h -O $(INCLUDE_DIR)/printf.h
	wget https://raw.githubusercontent.com/mpaland/printf/refs/heads/master/printf.c -O src/printf.c

# Get the latest version of the Limine bootloader and get the Zig bindings for the Limine protocol
$(INCLUDE_DIR)/limine:
	# Limine
	git clone https://codeberg.org/Limine/Limine.git --branch=v9.x-binary --depth=1 $@
	make -C $@

	# Limine bindings for Zig
	zig fetch --save git+https://github.com/voxi0/limine-zig#trunk

# UEFI firmware for QEMU
ovmf/ovmf-code-$(target).fd:
	mkdir -p ovmf
	curl -Lo $@ https://github.com/osdev0/edk2-ovmf-nightly/releases/latest/download/ovmf-code-$(target).fd
	case "$(target)" in \
		aarch64) dd if=/dev/zero of=$@ bs=1 count=0 seek=67108864 2>/dev/null;; \
		riscv64) dd if=/dev/zero of=$@ bs=1 count=0 seek=33554432 2>/dev/null;; \
	esac

# Clean everything
.PHONY: clean
clean:
	# Build output and cache
	rm -rf .zig-cache zig-out
