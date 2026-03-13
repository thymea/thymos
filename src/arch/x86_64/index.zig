const gdt = @import("gdt.zig");

/// Initialize the CPU
pub fn initCPU() void {
    gdt.init();
}

/// Halts the CPU indefinitely after stopping all interrupts
pub fn halt() noreturn {
    while (true) asm volatile ("cli; hlt");
}
