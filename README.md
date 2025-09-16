<div align="center">
    <h1>thymos</h1>
    <p align="center">
        <img src="https://img.shields.io/github/license/Voxi0/NixNvim?style=flat-square&logo=Github&label=License&labelColor=black&color=white" alt="License">
        <img src="https://img.shields.io/github/languages/code-size/Voxi0/NixNvim?style=flat-square&logo=Files&label=Size&labelColor=black&color=white" alt="Repo Size">
    </p>
</div>

A simple 64-bit hobby operating system written from scratch in Zig. Currently only supports x86 but aiming to support RISC-V and ARM in the near future.

## Features
- Works on real hardware and supports UEFI as well
- Small kernel setup GDT (Global Descriptor Table)
- IDT (Interrupt Descriptor Table) for handling software/hardware interrupts
- 8259 PIC driver for handling monitoring hardware interrupts
- Basic video driver that works with a linear framebuffer provided by Limine
- Basic PS/2 keyboard driver and a shell for user input

## Try it
[Watch the showcase/demo here](https://video.hardlimit.com/w/2PxYCaSEbWVUaoYZAronmH) to see what this operating system is currently
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
    - `qemu` - For emulating the OS to rapidly test it duh
    - `gcc` - To use makefiles and for compiling Limine binaries
    - `wget` - For fetching dependencies e.g. `ssfn.h`
    - `xorriso` - For creating the ISO

### Makefile Commands
```shell
make fetchDeps

# Build
make                                            - Compile and emulate the operating system in QEMU (x86)
make kernel                                     - Build the kernel
make iso                                        - Create bootable ISO image
make run                                        - Emulate the operating system (x86)
make run target="<architecture>" cpu="<cpu>"    - Supported architectures are `x86_64`, `riscv64` and `aarch64`
                                                - Default CPUs are already set so you don't have to manually set them

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
- [Limine](https://codeberg.org/Limine/Limine/) - Modern, advanced, portable, multiprotocol bootloader and boot manager
- [SSFN](https://gitlab.com/bztsrc/scalable-font2/) - Very fast, efficient and lightweight text renderer
- [Tiny Printf](https://github.com/eyalroz/printf) - Tiny, fast, non-dependent and fully loaded `printf` implementation
for embedded systems.

## Contributors
<div align="center">
    <a href="https://github.com/Voxi0/NixDots/graphs/contributors">
        <img src="https://contrib.rocks/image?repo=Voxi0/NixDots&max=10&columns=12&anon=0"/>
    </a>
    <p>Made with <a href="https://contrib.rocks">contrib.rocks</a></p>
</div>
