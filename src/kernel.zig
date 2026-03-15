const root = @import("common");
const arch = @import("arch");
const colors = @import("colors");

// Drivers
const video = @import("drivers/video.zig");

// Aliases
const std = root.std;
const c = root.c;
const printf = root.printf;

/// The kernel's entry point.
export fn _start() callconv(.c) noreturn {
    // Ensure Limine base revision is supported
    if (!c.LIMINE_BASE_REVISION_SUPPORTED(root.limineBaseRev)) arch.halt();

    // Initialize the video driver
    video.init(0x000000, 0x00ff00);

    // Initialize architecture specific stuff
    arch.initCPU();

    // Draw the UI
    draw() catch |e| video.handleErr(e);

    // Halt CPU indefinitely
    arch.halt();
}

// Initializes the video driver and draws stuff
fn draw() video.VideoError!void {
    try video.clearScreen();
}

// Panic handler
pub const panic = std.debug.FullPanic(panicHandler);
fn panicHandler(msg: []const u8, firstTraceAddr: ?usize) noreturn {
    _ = firstTraceAddr;

    // Display error message
    c.ssfn_dst.fg = colors.ERR_TEXT_COLOR;
    printf("\n[PANIC] %s", msg.ptr);

    // Halt CPU indefinitely
    arch.halt();
}
