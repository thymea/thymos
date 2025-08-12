const builtin = @import("builtin");
const limine = @import("limine");

// OS
const video = @import("./drivers/video.zig");

// Limine
// Protocol base revision
export var baseRevision: limine.BaseRevision linksection(".limine_requests") = .init(3);

// Requests
export var startMarker: limine.RequestsStartMarker linksection(".limine_requests_start") = .{};
export var endMarker: limine.RequestsEndMarker linksection(".limine_requests_end") = .{};

// Halt CPU
fn halt() noreturn {
    while (true) asm volatile ("hlt");
}

// Kernel entry point
export fn _start() callconv(.C) noreturn {
    // Ensure the Limine base revision is supported
    if (!baseRevision.isSupported()) @panic("Limine base revision unsupported");

    // Initialize drivers
    video.initVideo(0x002500, 0xffffff);
    video.clearScreen();
    video.drawFilledRect(50, 200, 100, 70, 0xffaabb);
    video.drawPixel(10, 10, 0xffffff);

    // Halt system
    halt();
}
