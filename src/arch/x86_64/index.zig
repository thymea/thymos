const gdt = @import("gdt.zig");
const idt = @import("idt.zig");

/// Initialize the CPU
pub fn initCPU() void {
    gdt.init();
    idt.init();
}

/// Halts the CPU indefinitely after stopping all interrupts
pub fn halt() noreturn {
    while (true) asm volatile ("cli; hlt");
}
