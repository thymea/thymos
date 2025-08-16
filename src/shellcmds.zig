const g = @import("index.zig");

// Print stuff to the screen
pub fn cmdEcho(argc: u8, argv: [][*]u8) void {
    for (1..argc) |i| _ = g.c.printf("%s ", argv[i]);
    _ = g.c.printf("\n");
}

// Clear the screen
pub fn cmdClear(_: u8, _: [][*]u8) void {
    g.drivers.video.resetScreen();
}
