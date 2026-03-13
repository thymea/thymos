const root = @import("root.zig");

// Drivers
const video = @import("drivers/video.zig");

// Aliases
const c = root.c;
const arch = root.arch;
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
    try video.drawLine(0, 0, video.fbWidth, video.fbHeight, 0xff0000);
    try video.drawLine(0, 0, 0, @intCast(video.fb.height - 1), 0xff0000);
    try video.drawLine(0, @intCast(video.fb.height - 1), @intCast(video.fb.width - 1), 0, 0xff0000);
    try video.drawLine(@intCast(video.fb.width - 1), 0, @intCast(video.fb.width - 1), @intCast(video.fb.height - 1), 0xff0000);
}
