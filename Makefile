OS_NAME := zigOS

# Directories
INCLUDE_DIR := 3rdparty
BUILD_DIR := zig-out
ISO_DIR := $(BUILD_DIR)/isodir

# Toolchain
ZIG := zig
ZIGFLAGS := -Doptimize=ReleaseSafe
AS := nasm
ASFLAGS := -f elf64
QEMU_FLAGS := --enable-kvm -no-reboot

# Run/Emulate the OS in QEMU
run: $(BUILD_DIR)/$(OS_NAME).iso
	qemu-system-x86_64 $(QEMU_FLAGS) -drive format=raw,media=cdrom,file=$<

# ISO
$(BUILD_DIR)/$(OS_NAME).iso: fetchDeps limine.conf kernel
	# Create required directories
	mkdir -p $(ISO_DIR)/boot/limine $(ISO_DIR)/EFI/BOOT

	# Copy the kernel and Limine binaries into the ISO
	cp -v $(BUILD_DIR)/bin/kernel.elf $(ISO_DIR)/boot/
	cp -v limine.conf limine/limine-bios.sys limine/limine-bios-cd.bin limine/limine-uefi-cd.bin $(ISO_DIR)/boot/limine/
	cp -v limine/BOOTIA32.EFI limine/BOOTX64.EFI $(ISO_DIR)/EFI/BOOT/

	# Create the ISO
	xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
		-apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $@

	# Install Limine into the ISO
	./limine/limine bios-install $@

# Fetch dependencies which also updates existing ones
fetchDeps: limine
	mkdir -p $(INCLUDE_DIR)

	# SSFN - Font loader and text renderer
	wget https://gitlab.com/bztsrc/scalable-font2/-/raw/master/ssfn.h -O $(INCLUDE_DIR)/ssfn.h

	# Tiny Printf - Very small, fast and dependency free `printf` implementation for embedded systems
	wget https://raw.githubusercontent.com/mpaland/printf/refs/heads/master/printf.h -O $(INCLUDE_DIR)/printf.h
	wget https://raw.githubusercontent.com/mpaland/printf/refs/heads/master/printf.c -O src/printf.c

# Fetch and build the latest version of Limine
limine:
	# Limine
	rm -rf limine
	git clone https://github.com/limine-bootloader/limine.git --branch=v9.x-binary --depth=1 $(INCLUDE_DIR)/limine
	make -C $(INCLUDE_DIR)/limine

	# Limine bindings for Zig
	zig fetch --save git+https://github.com/48cf/limine-zig#trunk

# Kernel
kernel: $(BUILD_DIR)/asm.o
	$(ZIG) build $(ZIGFLAGS)

# Helper assembly code
$(BUILD_DIR)/asm.o: src/asm.s
	mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

# Clean everything
clean:
	# Dependencies
	rm -rf include src/printf.c

	# Build output and cache
	rm -rf .zig-cache zig-out
