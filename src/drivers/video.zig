const g = @import("../index.zig");

// Constants
// Font
const FONT = @embedFile("../fonts/unifont.sfn");
const GLYPH_WIDTH: u8 = 8;
const GLYPH_HEIGHT: u8 = 16;

// Number of spaces in a tab character
const TAB_SPACES: u8 = 4;

// Number of pixels in one chunk
const CHUNK_SIZE: u8 = 16;

// SSFN
pub export var ssfn_src: ?*g.c.ssfn_font_t = null;
pub export var ssfn_dst: g.c.ssfn_buf_t = undefined;

// Framebuffer
export var fbRequest: g.limine.FramebufferRequest linksection(".limine_requests") = .{};
var fb: ?*g.limine.Framebuffer = null;
var pitchInPixels: u32 = 0;

// Utility/Helper functions
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
    } else @panic("No framebuffer");
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
    const pixelPos: [*]u32 = @as([*]u32, @ptrCast(@alignCast(fb.?.address))) + (ypos * fb.?.pitch) + (xpos * fb.?.bpp);
    pixelPos[0] = color;
}
pub fn drawFilledRect(xpos: u64, ypos: u64, width: u32, height: u32, color: u32) void {
    // Calculate the start position to start drawing in
    var pixelPtr: [*]u32 = @ptrFromInt(@intFromPtr(fb.?.address) + (ypos * fb.?.pitch) + (xpos * fb.?.bpp));

    // Calculate the amount of pixels to the next row
    const skip: u32 = pitchInPixels - width;

    // Calculate the number of chunks required for the rectangle
    const chunks: u32 = width / CHUNK_SIZE;
    const remainderChunks: u32 = width % CHUNK_SIZE;

    // Create an array of pixels as large as the chunk size is
    const pixelBatch: [CHUNK_SIZE]u32 = .{color} ** CHUNK_SIZE;

    // Draw the rectangle
    for (0..height) |_| {
        // Color chunks of 4 pixels
        for (0..chunks) |_| {
            @memcpy(pixelPtr, &pixelBatch);
            pixelPtr += CHUNK_SIZE;
        }

        // Color remaining pixels
        for (0..remainderChunks) |_| {
            pixelPtr[0] = color;
            pixelPtr += 1;
        }

        // Advance to the next row
        pixelPtr += skip;
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

        // Normal character
        else => {
            if ((g.c.ssfn_dst.x + GLYPH_WIDTH) > fb.?.width) _putchar('\n');
            if ((g.c.ssfn_dst.y + GLYPH_HEIGHT) > fb.?.height) resetScreen();
            _ = g.c.ssfn_putc(char);
        },
    }
}
