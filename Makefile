OS_NAME := zigOS

# Directories
BUILD_DIR := zig-out
ISO_DIR := $(BUILD_DIR)/isodir

# Toolchain
ZIG := zig
ZIGFLAGS := -Doptimize=ReleaseSafe
AS := nasm
ASFLAGS := -f elf64

# Run/Emulate the OS in QEMU
run: $(BUILD_DIR)/$(OS_NAME).iso
	qemu-system-x86_64 --enable-kvm -no-reboot -usb -drive format=raw,media=cdrom,file=$<

# ISO
$(BUILD_DIR)/$(OS_NAME).iso: limine limine.conf kernel
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

# Fetch and build the latest version of Limine
limine:
	rm -rf limine
	git clone https://github.com/limine-bootloader/limine.git --branch=v9.x-binary --depth=1
	make -C limine

# Kernel
kernel: $(BUILD_DIR)/asm.o
	$(ZIG) build $(ZIGFLAGS)
$(BUILD_DIR)/asm.o: src/asm.s
	mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

# Remove Limine and all build output
clean:
	rm -rf limine .zig-cache zig-out
