const g = @import("../index.zig");

// Constants
// Font
const FONT = @embedFile("../fonts/unifont.sfn");
const GLYPH_WIDTH: u8 = 8;
const GLYPH_HEIGHT: u8 = 16;

// Number of spaces in a tab character
const TAB_SPACES: u8 = 4;

// SSFN
pub export var ssfn_src: ?*g.c.ssfn_font_t = null;
pub export var ssfn_dst: g.c.ssfn_buf_t = undefined;

// Framebuffer
export var fbRequest: g.limine.FramebufferRequest linksection(".limine_requests") = .{};
var fb: ?*g.limine.Framebuffer = null;
var pitchInPixels: u32 = 0;

// Utility/Helper functions
pub fn strToHex(colorStr: [*]u8) u32 {
    var value: u32 = 0;
    for (colorStr[0..6]) |c| {
        var digit: u8 = 0;
        if (c >= '0' and c <= '9') {
            digit = c - '0';
        } else if (c >= 'a' and c <= 'f') {
            digit = c - 'a' + 10;
        } else if (c >= 'A' and c <= 'F') {
            digit = c - 'A' + 10;
        } else {
            _ = g.c.printf("Invalid hex digit: %s\n", colorStr);
            return 0;
        }
        value = (value << 4) | @as(u32, digit);
    }
    return value;
}
pub fn rgbToHex(red: u32, green: u32, blue: u32) u32 {
    return ((red & 0xff) << 16) + ((green & 0xff) << 8) + (blue & 0xff);
}
pub fn setBgColor(color: u32) void {
    ssfn_dst.bg = color;
}
pub fn setFgColor(color: u32) void {
    ssfn_dst.fg = color;
}

// Initialize everything
pub fn init(backgroundColor: u32, foregroundColor: u32) void {
    // Ensure a framebuffer is present
    if (fbRequest.response) |response| {
        // Get the framebuffer
        fb = response.getFramebuffers()[0];
        pitchInPixels = @intCast(fb.?.pitch / @sizeOf(u32));

        // Initialize SSFN - Text renderer
        g.c.ssfn_src = @ptrCast(@constCast(&FONT[0]));
        g.c.ssfn_dst.ptr = @ptrCast(fb.?.address);
        g.c.ssfn_dst.w = @intCast(fb.?.width);
        g.c.ssfn_dst.h = @intCast(fb.?.height);
        g.c.ssfn_dst.p = @intCast(fb.?.pitch);
        g.c.ssfn_dst.x = 0;
        g.c.ssfn_dst.y = 0;
        g.c.ssfn_dst.bg = backgroundColor;
        g.c.ssfn_dst.fg = foregroundColor;
    } else @panic("No framebuffer available");
}

// Clear the screen and reset cursor position
pub fn resetScreen() void {
    drawFilledRect(0, 0, @intCast(fb.?.width), @intCast(fb.?.height), g.c.ssfn_dst.bg);
    g.c.ssfn_dst.x = 0;
    g.c.ssfn_dst.y = 0;
}

// Drawing
pub fn drawPixel(xpos: u64, ypos: u64, color: u32) void {
    // Calculate the absolute pixel position and color it
    const pixels: [*]u32 = @ptrCast(@alignCast(fb.?.address));
    pixels[ypos * pitchInPixels + xpos] = color;
}
pub fn drawFilledRect(xpos: u64, ypos: u64, width: u32, height: u32, color: u32) void {
    // Clamp to valid range
    if (xpos < 0 or ypos < 0) return;
    if ((xpos + width) > fb.?.width) return;
    if ((ypos + height) > fb.?.height) return;

    // Calculate the start position to start drawing in and draw the rectangle
    var rowPtr: [*]u32 = @as([*]u32, @ptrCast(@alignCast(fb.?.address))) + ypos * pitchInPixels + xpos;
    var pixelPtr: [*]u32 = rowPtr;
    for (0..height) |_| {
        // Fill the entire row with color
        pixelPtr = rowPtr;
        for (0..width) |_| {
            pixelPtr[0] = color;
            pixelPtr += 1;
        }

        // Advance to the next row
        rowPtr += pitchInPixels;
    }
}

// Handle printing characters - Required for `printf`
export fn _putchar(char: u8) void {
    switch (char) {
        // Newline
        '\n' => {
            g.c.ssfn_dst.x = 0;
            if ((g.c.ssfn_dst.y + GLYPH_HEIGHT) > fb.?.height) {
                resetScreen();
            } else g.c.ssfn_dst.y += GLYPH_HEIGHT;
        },

        // Tab
        '\t' => {
            if ((g.c.ssfn_dst.x + (GLYPH_WIDTH * TAB_SPACES)) > fb.?.width) {
                resetScreen();
            } else {
                for (0..4) |_|
                    _putchar(' ');
            }
        },

        // Backspace
        0x08 => {
            // Move cursor back to previous character
            if (g.c.ssfn_dst.x >= GLYPH_WIDTH) {
                g.c.ssfn_dst.x -= GLYPH_WIDTH;
            } else if (g.c.ssfn_dst.y >= GLYPH_HEIGHT) {
                g.c.ssfn_dst.y -= GLYPH_HEIGHT;
                g.c.ssfn_dst.x = @intCast(fb.?.width - GLYPH_WIDTH);
            } else return;

            // Draw over the character to "erase it"
            drawFilledRect(@intCast(g.c.ssfn_dst.x), @intCast(g.c.ssfn_dst.y), GLYPH_WIDTH, GLYPH_HEIGHT, g.c.ssfn_dst.bg);
        },

        // Normal character
        else => {
            if ((g.c.ssfn_dst.x + GLYPH_WIDTH) > fb.?.width) _putchar('\n');
            if ((g.c.ssfn_dst.y + GLYPH_HEIGHT) > fb.?.height) resetScreen();
            _ = g.c.ssfn_putc(char);
        },
    }
}
