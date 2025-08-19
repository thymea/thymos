# thymos
A simple x86 64-bit hobby operating system written from scratch in Zig.

## Features
- Works on real hardware and supports UEFI as well
- Small kernel setup GDT (Global Descriptor Table)
- IDT (Interrupt Descriptor Table) for handling software/hardware interrupts
- 8259 PIC driver for handling monitoring hardware interrupts
- Basic video driver that works with a linear framebuffer provided by Limine
- Basic PS/2 keyboard driver and a shell for user input

## Try it
[Watch the showcase/demo here](https://video.hardlimit.com/w/2PxYCaSEbWVUaoYZAronmH) to see what `thymos` is currently
capable of. I wouldn't be surprised if you're unimpressed because there's nothing fancy going on :)

### Virtual (Recommended)
- Download `thymos.iso` from the latest release in the [releases page](https://github.com/thymea/thymos/releases)
- Download [QEMU](https://www.qemu.org/download/) to emulate the OS
- Run `qemu-system-x86_64 -cdrom thymos.iso` to boot thymos in QEMU

### Bare-metal
- Download `thymos.iso` from the latest release in the [releases page](https://github.com/thymea/thymos/releases)
- Flash `thymos.iso` to a flash drive
- Plug into computer and boot into flash drive. The steps required to do this depends on the hardware

## Development
### Setting everything up
It's recommended you have the [Nix](https://nixos.org/download/) package manager installed along with [flakes](https://nixos.wiki/wiki/Flakes)
enabled since the primary development environment is set up with a Nix flake.

After installing Nix and enabling flakes, just run `nix develop` in the root of the project directory. Run `nix flake update` to update all
flake dependencies to use the latest version of all packages that the development environment provides.

If you can't or don't want to use Nix then you'll need to download the following tools manually ->
    - `zig` - To compile the kernel itself. It's written in Zig obviously
    - `nasm` - Assembler since some things are written in x86 assembly ('Twas unavoidable sadly)
    - `qemu` - For emulating the OS to rapidly test it duh
    - `gcc` - To use makefiles for compiling Limine binaries
    - `wget` - For fetching dependencies e.g. `ssfn.h`
    - `xorriso` - For creating the ISO

### Makefile Commands
```shell
# RUN THIS COMMAND FIRST TO FETCH ALL THE REQUIRED LIBRARIES e.g. Limine bootloader
make fetchDeps

# Build
make            - Compile and run/emulate thymos in QEMU
make kernel     - Build the kernel
make iso        - Create bootable ISO image

# Remove build output, cache and project dependencies e.g. Limine
make clean
```

## TODO
- Memory management
- Filesystem drivers
- Networking
- LibC and porting software
- More modern APIC driver instead of 8259 PIC driver
- ACPI for power management

## Acknowledgements
- [Limine](https://limine-bootloader.org/) - Modern bootloader + boot protocol. Boots the machine into 64-bit long mode
with paging and everything set up before handing over control to the kernel.
- [SSFN](https://gitlab.com/bztsrc/scalable-font2/) - Very fast, efficient and lightweight text renderer that has no
dependencies when using the minimal renderer. Even the normal renderer barely has any. Uses special `.sfn` fonts that
can be obtained from normal font files e.g. `.ttf` thanks to the provided converter tool.
- [Tiny Printf](https://github.com/mpaland/printf) - Tiny, fast, non-dependent and fully loaded `printf` implementation
for embedded systems that's extremely easy to integrate into a project.
