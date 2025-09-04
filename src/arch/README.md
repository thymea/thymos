## CPU Architectures
This directory stores architecture specific code used by thymos. Add support for a new architecture by creating a new directory
here with the directory being named the architecture and make sure to create an `index.zig` file inside.

### Interface
Every `index.zig` file for a CPU architecture needs to have a public `init()` function
that initializes the CPU the way it should be according to the architecture. For example,
x86 CPUs are initialized by first initializing the GDT, then the IDT, and then remap the PIC
chips for hardware interrupts.

You should also have a public `halt()` function to well, halt the CPU.

And finally, define the following public imports -
    - `io` - With `inb`, `outb` and `wait` public functions
    - `interrupts` - With a `cpuExceptionMsg` which is an array of CPU exception messages
    - `irqController`
