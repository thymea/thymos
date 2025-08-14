// OS
const g = @import("globals.zig");
const cpu = @import("cpu/cpu.zig");
const drivers = @import("drivers/drivers.zig");

// Limine
// Protocol base revision
export var baseRevision: g.limine.BaseRevision linksection(".limine_requests") = .init(3);

// Requests
export var startMarker: g.limine.RequestsStartMarker linksection(".limine_requests_start") = .{};
export var endMarker: g.limine.RequestsEndMarker linksection(".limine_requests_end") = .{};

// Kernel entry point
export fn _start() callconv(.C) noreturn {
    // Ensure the Limine base revision is supported
    if (!baseRevision.isSupported()) @panic("Limine base revision unsupported");

    // Initialize everything
    asm volatile ("cli");
    cpu.gdt.init();
    cpu.idt.init();
    asm volatile ("sti");
    drivers.video.init(0x191724, 0xe0def4);

    // Clear the screen and print stuff
    drivers.video.resetScreen();
    _ = g.c.printf("Hello world!\n");

    // Halt system
    g.halt();
}

// Handle interrupts
export fn interruptHandler(irqNum: u8, _: usize) void {
    if (irqNum < 32) {
        _ = g.c.printf("\nFATAL: %s\n", cpu.idt.cpuExceptionMsg[irqNum].ptr);
    }

    // Disable interrupts and halt system
    asm volatile ("cli");
    g.halt();
}
