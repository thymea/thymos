# thymos
A simple x86 64-bit hobby operating system written from scratch in Zig.

## Features
- Works on real hardware and supports UEFI as well
- Small kernel setup GDT (Global Descriptor Table)
- IDT (Interrupt Descriptor Table) for handling software/hardware interrupts
- 8259 PIC driver for handling monitoring hardware interrupts
- Basic video driver that works with a linear framebuffer provided by Limine
- Basic PS/2 keyboard driver and a shell for user input

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
