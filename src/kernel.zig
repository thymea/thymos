const root = @import("root.zig");
const utils = @import("utils.zig");

// Drivers
const video = @import("drivers/video.zig");

// Aliases
const c = root.c;
const printf = root.printf;

// Kernel entry point
export fn _start() callconv(.c) noreturn {
    // Ensure Limine base revision is supported
    if (!c.LIMINE_BASE_REVISION_SUPPORTED(root.limineBaseRev)) utils.halt();
    video.init(0x000000, 0x00ff00);
    video.clearScreen();
    printf("Hello world!");
    printf("\x08");
    video.drawLine(50, 50, 100, 50, 0xff0000);
    utils.halt();
}
