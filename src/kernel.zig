// OS
const g = @import("index.zig");
const shell = @import("kernel/shell.zig");

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
    // CPU
    g.arch.init();

    // Drivers
    // Video
    g.drivers.video.init(0x191724, 0xe0def4);
    g.drivers.video.resetScreen();

    // Keyboard
    g.drivers.keyboard.init();

    // Memory
    g.memory.pmm.init();
    const memStats = g.memory.pmm.stats();
    _ = g.c.printf("Initialized Physical Memory Manager (PMM) -\n");
    _ = g.c.printf(
        "\tTotal: %lu pages\n\tUsed: %lu pages\n\tFree: %lu pages\n",
        memStats.total,
        memStats.used,
        memStats.free,
    );

    // Shell
    _ = g.c.printf("\n");
    shell.init();
    while (true) {}
}

// Handle interrupts
export fn interruptHandler(irqNum: u8, _: usize) void {
    // The 32 CPU exceptions
    if (irqNum < 32) {
        _ = g.c.printf("\nFATAL: %s\n", g.arch.interrupts.cpuExceptionMsg[irqNum].ptr);
    }

    // The 16 hardware interrupts
    else if (irqNum < 48) {
        if (g.arch.interrupts.irqHandlers[irqNum - 32]) |handler| {
            handler(irqNum);
            g.arch.irqController.sendEOI(irqNum);
            return;
        } else _ = g.c.printf("No handler for IRQ: %d\n", (irqNum - 32));
    }

    // Unknown interrupt
    else _ = g.c.printf("Invalid interrupt: %d\n", irqNum);

    // Halt system
    g.arch.halt();
}
