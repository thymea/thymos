// OS
const g = @import("globals.zig");
const video = @import("./drivers/video.zig");

// Limine
// Protocol base revision
export var baseRevision: g.limine.BaseRevision linksection(".limine_requests") = .init(3);

// Requests
export var startMarker: g.limine.RequestsStartMarker linksection(".limine_requests_start") = .{};
export var endMarker: g.limine.RequestsEndMarker linksection(".limine_requests_end") = .{};

// Halt CPU
fn halt() noreturn {
    while (true) asm volatile ("hlt");
}

// Kernel entry point
export fn _start() callconv(.C) noreturn {
    // Ensure the Limine base revision is supported
    if (!baseRevision.isSupported()) @panic("Limine base revision unsupported");

    // Initialize drivers
    video.initVideo(0x000000, 0x00ff00);
    video.resetScreen();
    _ = g.c.printf("Hello world!\n");
    _ = g.c.printf("\tThis is cool innit bruv\n");

    // Halt system
    halt();
}
