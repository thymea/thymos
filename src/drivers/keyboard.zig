const cpu = @import("../cpu/index.zig");
const pic = @import("../drivers/index.zig").pic;

// Types
const keyCallback_t = *const fn (key: u8, pressed: bool) void;

// Constants
const KB_PORT_DATA: u8 = 0x60;
const KB_PORT_STATUS: u8 = 0x64;
const KB_PORT_COMMAND: u8 = 0x64;
const KB_CMD_ENABLE_SCANNING: u8 = 0xF4;
const KB_CMD_DISABLE_SCANNING: u8 = 0xF;
const KB_SCANCODE_RELEASE_MASK: u8 = 0x80;

// Special characters
const KB_SCANCODE_LEFT_SHIFT: u8 = 0x2A;
const KB_SCANCODE_RIGHT_SHIFT: u8 = 0x36;
const KB_SCANCODE_CAPS_LOCK: u8 = 0x3A;
const KB_SCANCODE_BACKSPACE: u8 = 0x0E;
const KB_SCANCODE_ENTER: u8 = 0x1C;
const KB_SCANCODE_LEFT_ARROW: u8 = 0x4B;
const KB_SCANCODE_RIGHT_ARROW: u8 = 0x4D;
const KB_SCANCODE_UP_ARROW: u8 = 0x48;
const KB_SCANCODE_DOWN_ARROW: u8 = 0x50;

// ASCII keymap
const ASCII_MAP_LOWER: [81]u8 = .{
    0,    27,  '1', '2', '3', '4', '5', '6', '7', '8', '9',  '0', '-', '=',  0x08,
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',  '[', ']', '\n', 0,
    'a',  's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0,   '\\', 'z',
    'x',  'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,   '*',  0,   ' ', 0,    0,
    0,    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,    0,
    0,    0,   0,   0,   0,   0,
};
const ASCII_MAP_UPPER: [81]u8 = .{
    0,    27,  '!', '@', '#', '$', '%', '^', '&', '*', '(',  ')', '_', '+',  0x08,
    '\t', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',  '{', '}', '\n', 0,
    'A',  'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '\"', '~', 0,   '|',  'Z',
    'X',  'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0,   '*',  0,   ' ', 0,    0,
    0,    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,    0,
    0,    0,   0,   0,   0,   0,
};

// Keyboard state
var shiftOn: bool = false;
var capsLockOn: bool = false;

// Key callback
var keyCallback: ?keyCallback_t = null;

// Keyboard interrupt request handler
fn kbIrqHandler(irqNum: u8) void {
    // Get keyboard data
    const scancodeRaw: u8 = cpu.io.inb(KB_PORT_DATA);
    const scancode: u8 = scancodeRaw & ~KB_SCANCODE_RELEASE_MASK;
    const pressed: bool = (scancodeRaw & KB_SCANCODE_RELEASE_MASK) == 0;

    // Process scancode
    var key: u8 = 0;
    switch (scancode) {
        // Special characters
        KB_SCANCODE_LEFT_SHIFT => shiftOn = pressed,
        KB_SCANCODE_RIGHT_SHIFT => shiftOn = pressed,
        KB_SCANCODE_CAPS_LOCK => capsLockOn = !capsLockOn,
        KB_SCANCODE_BACKSPACE => key = 0x08,
        KB_SCANCODE_ENTER => key = '\n',

        // Normal
        else => {
            if (pressed and scancode < ASCII_MAP_LOWER.len) {
                // Translate scancode to ASCII
                key = if (shiftOn or capsLockOn) ASCII_MAP_UPPER[scancode] else ASCII_MAP_LOWER[scancode];
            }
        },
    }

    // Call the key callback function if it's registered
    if (keyCallback) |callback| callback(key, pressed);

    // Interrupt has been handled
    pic.sendEOI(irqNum);
}

// Initialize everything
pub fn init() void {
    // Register the keyboard handler and unmask/enable keyboard interrupts
    cpu.idt.irqRegisterHandler(1, @constCast(&kbIrqHandler));
    pic.unmaskIRQ(1);

    // Clear keyboard data register
    while ((cpu.io.inb(KB_PORT_STATUS) & 0x1) != 0) _ = cpu.io.inb(KB_PORT_DATA);

    // Enable keyboard scanning to get scancodes
    cpu.io.outb(KB_PORT_DATA, KB_CMD_ENABLE_SCANNING);
}

// Register/Deregister key callback handler
pub fn registerKeyCallback(callback: keyCallback_t) void {
    keyCallback = callback;
}
pub fn deregisterKeyCallback() void {
    keyCallback = null;
}

// Deregister the keyboard handler and mask/disable keyboard interrupts
pub fn disableKb() void {
    cpu.idt.irqDeregisterHandler(1);
    pic.maskIRQ(1);
}
