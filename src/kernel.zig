// OS
const g = @import("index.zig");

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
    g.cpu.gdt.init();
    g.cpu.idt.init();
    asm volatile ("sti");
    g.drivers.video.init(0x191724, 0xe0def4);

    // Clear the screen and print stuff
    g.drivers.video.resetScreen();
    _ = g.c.printf("Hello world!\n");

    // Halt system
    while (true) {}
}

// Handle interrupts
export fn interruptHandler(irqNum: u8, _: usize) void {
    // The 32 CPU exceptions
    if (irqNum < 32) {
        _ = g.c.printf("\nFATAL: %s\n", g.cpu.idt.cpuExceptionMsg[irqNum].ptr);
    }

    // The 16 hardware interrupts
    else if (irqNum < 48) {
        if (g.cpu.idt.irqHandlers[irqNum - 32]) |handler| {
            handler(irqNum);
        } else _ = g.c.printf("No handler for IRQ: %d\n", (irqNum - 32));
    }

    // Unknown interrupt
    else _ = g.c.printf("Invalid interrupt: %d\n", irqNum);

    // Disable interrupts and halt system
    asm volatile ("cli");
    g.halt();
}
