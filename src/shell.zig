const g = @import("index.zig");
const shellCommands = @import("shellcmds.zig");

// Types
const cmdHandler_t = *const fn (argc: u8, argv: [][*]u8) void;
const shellCmd_t = struct {
    name: [:0]const u8,
    desc: [:0]const u8,
    handler: cmdHandler_t,
};

// Constants
const MAX_INPUT_SIZE: usize = 512;
const MAX_PROMPT_SIZE: u8 = 30;
const MAX_COMMANDS: u8 = 50;

// Shell prompt
const shellPrompt: [:0]const u8 = "thymos> ";

// Input buffer
var inputBuffer: [MAX_INPUT_SIZE]u8 = undefined;
var inputIndex: u16 = 0;

// Shell commands
pub var shellCmds: [MAX_COMMANDS]shellCmd_t = undefined;
pub var shellCmdCount: u8 = 0;

// Initialize the shell
pub fn init() void {
    // Register shell keyboard callback
    g.drivers.keyboard.registerKeyCallback(shellKeyCallback);

    // Display shell prompt and register all commands
    _ = g.c.printf("%s", shellPrompt.ptr);
    shellCommands.registerAllCmds();
}

// Register a command
pub fn registerCmd(cmd: shellCmd_t) void {
    if (shellCmdCount != MAX_COMMANDS) {
        shellCmds[shellCmdCount] = cmd;
        shellCmdCount += 1;
    }
}

// Parse a command and call the handler registered to it
fn parseCmd(cmd: [*:0]u8) void {
    // Argument count and string
    var argc: u8 = 0;
    var argv: [MAX_INPUT_SIZE][*]u8 = undefined;

    // Trim leading spaces
    var p: [*:0]u8 = cmd;
    while (p[0] == ' ') : (p += 1) {}

    // Split command into arguments
    while (p[0] != 0 and argc < MAX_INPUT_SIZE) {
        // Add 1 word to `argv`
        argv[argc] = p;
        argc += 1;

        // Find next space
        while (p[0] != 0 and p[0] != ' ') : (p += 1) {}
        if (p[0] == 0) break;

        // Null terminate the token
        p[0] = 0;
        p += 1;

        // Skip multiple spaces
        while (p[0] == ' ') : (p += 1) {}
    }

    // No command entered
    if (argc == 0) return;

    // Call the handler registered to the command
    for (0..shellCmdCount) |i| {
        if (g.strEq(argv[0], shellCmds[i].name)) {
            shellCmds[i].handler(argc, argv[0..argc]);
            return;
        }
    }

    // Unknown command
    _ = g.c.printf("Unknown command: %s\n", argv[0]);
    _ = g.c.printf("Try `help`\n");
}

// Keyboard key callback
fn shellKeyCallback(key: u8, pressed: bool) void {
    switch (key) {
        // Enter/Return
        '\n' => {
            if (pressed) {
                _ = g.c.printf("\n");

                // Null-terminate and parse command
                inputBuffer[inputIndex] = 0;
                parseCmd(inputBuffer[0..inputIndex :0]);

                // Clear input buffer
                inputIndex = 0;
                @memset(inputBuffer[0..inputIndex], 0);

                // Redisplay shell prompt
                _ = g.c.printf("%s", shellPrompt.ptr);
            }
        },

        // Backspace
        0x08 => {
            if (pressed and inputIndex > 0) {
                _ = g.c.printf("%c", @as(c_int, 0x08));
                inputIndex -= 1;
                inputBuffer[inputIndex] = 0;
            }
        },

        // Normal
        else => {
            if (pressed and inputIndex < (MAX_INPUT_SIZE - 1)) {
                _ = g.c.printf("%c", key);
                inputBuffer[inputIndex] = key;
                inputIndex += 1;
            }
        },
    }
}
