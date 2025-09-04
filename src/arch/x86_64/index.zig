const gdt = @import("gdt.zig");
pub const io = @import("io.zig");
pub const interrupts = @import("idt.zig");
pub const irqController = @import("pic.zig");

// x86 specific functions
pub fn init() void {
    asm volatile ("cli");
    gdt.init();
    interrupts.init();
    irqController.remap(32, 48);
    asm volatile ("sti");
}
pub fn halt() noreturn {
    asm volatile ("cli");
    while (true) asm volatile ("hlt");
}
