# CLI arguments
ROOT_DIR=$1
ARCH=$2
KERNEL=$3
ISO_NAME=$4

# Variables
BUILD_DIR=$ROOT_DIR/build
ISO_DIR=$BUILD_DIR/isodir/$ARCH
LIMINE_DIR=$ROOT_DIR/include/limine
OUTPUT=$ISO_DIR/$ISO_NAME

# Delete and recreate ISO directory
rm -rf $ISO_DIR
mkdir -p $ISO_DIR/boot/limine $ISO_DIR/EFI/BOOT

# Copy Limine bootloader config and kernel binary into ISO
cp $ROOT_DIR/limine.conf $ISO_DIR/boot/limine/
cp $KERNEL $ISO_DIR/boot/

# Copy Limine files into ISO
cp $LIMINE_DIR/limine-bios.sys $ISO_DIR/boot/limine/
cp $LIMINE_DIR/limine-bios-cd.bin $ISO_DIR/boot/limine/
cp $LIMINE_DIR/limine-uefi-cd.bin $ISO_DIR/boot/limine/
cp $LIMINE_DIR/BOOTIA32.EFI $ISO_DIR/EFI/BOOT/
cp $LIMINE_DIR/BOOTX64.EFI $ISO_DIR/EFI/BOOT/

# Create the bootable ISO and install Limine on it
xorriso -as mkisofs \
	-b boot/limine/limine-bios-cd.bin -no-emul-boot -boot-load-size 4 \
	-boot-info-table --efi-boot boot/limine/limine-uefi-cd.bin -efi-boot-part --efi-boot-image \
	--protective-msdos-label $ISO_DIR -o $OUTPUT

$LIMINE_DIR/limine bios-install $OUTPUT
