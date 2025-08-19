const g = @import("index.zig");
const shell = @import("shell.zig");

// Constants
const argv_t: type = [][*]u8;

pub fn registerAllCmds() void {
    // Basic
    shell.registerCmd(.{
        .name = "help",
        .desc = "Display all available commands",
        .handler = cmdHelp,
    });
    shell.registerCmd(.{
        .name = "clear",
        .desc = "Clear the screen",
        .handler = cmdClear,
    });
    shell.registerCmd(.{
        .name = "echo",
        .desc = "Print everything that comes after `echo`",
        .handler = cmdEcho,
    });

    // Set colors
    shell.registerCmd(.{
        .name = "setFgColor",
        .desc = "Set foreground/text color, accepts a hex code e.g. `ff0000` (RED)",
        .handler = setFgColor,
    });
    shell.registerCmd(.{
        .name = "setBgColor",
        .desc = "Set background color, accepts a hex code e.g. `ff0000` (RED)",
        .handler = setBgColor,
    });
}

// Display information about all registered commands
fn cmdHelp(_: u8, _: argv_t) void {
    for (0..shell.shellCmdCount) |i| {
        _ = g.c.printf("%s - %s\n", shell.shellCmds[i].name.ptr, shell.shellCmds[i].desc.ptr);
    }
}

// Clear the screen
fn cmdClear(_: u8, _: argv_t) void {
    g.drivers.video.resetScreen();
}

// Print stuff to the screen
fn cmdEcho(argc: u8, argv: argv_t) void {
    for (1..argc) |i| _ = g.c.printf("%s ", argv[i]);
    _ = g.c.printf("\n");
}

// Set colors
fn setBgColor(argc: u8, argv: argv_t) void {
    // Hex
    if (argc == 2) {
        g.drivers.video.setBgColor(g.drivers.video.strToHex(argv[1]));
        g.drivers.video.resetScreen();
    }

    // RGB
    else if (argc == 4) {}

    // Invalid argument
    else _ = g.c.printf("Invalid color\n");
}
fn setFgColor(argc: u8, argv: argv_t) void {
    // Hex
    if (argc == 2) {
        g.drivers.video.setFgColor(g.drivers.video.strToHex(argv[1]));
    }

    // RGB
    else if (argc == 4) {}

    // Invalid argument
    else _ = g.c.printf("Invalid color\n");
}
