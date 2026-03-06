BUILD_DIR := build

# Default target
all: kernel

# Fetch dependencies - Run this first
.PHONY: fetchDeps
fetchDeps:
	# Delete all dependencies/libraries
	# Careful not to delete `meson.build` and `printf/printf_config.h`
	rm -rf include/limine
	rm -rf include/printf/printf.h include/printf/printf.c

	# Recreate include directory
	mkdir -p include

	# Limine bootloader and protocol
	git clone https://codeberg.org/Limine/Limine.git --branch=v10.x-binary --depth=1 include/limine
	rm -rf include/limine/.git
	make -C include/limine
	wget https://codeberg.org/Limine/limine-protocol/raw/branch/trunk/include/limine.h -O include/limine/limine.h

	# SSFN text renderer
	wget https://gitlab.com/bztsrc/scalable-font2/-/raw/master/ssfn.h -O include/ssfn.h

	# Small printf implementation
	mkdir -p include/printf
	wget https://raw.githubusercontent.com/eyalroz/printf/refs/heads/master/src/printf/printf.h -O include/printf/printf.h
	wget https://raw.githubusercontent.com/eyalroz/printf/refs/heads/master/src/printf/printf.c -O include/printf/printf.c

# Build project
.PHONY: kernel
kernel:
	meson setup $(BUILD_DIR) --reconfigure
	meson compile -C $(BUILD_DIR)

# Create the bootable ISO
.PHONY: iso
iso:
	meson compile -C $(BUILD_DIR) iso

# Run the OS
.PHONY: run
run:
	meson compile -C $(BUILD_DIR) run

# Delete all build output and refresh
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
