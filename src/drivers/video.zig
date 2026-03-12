//! This is a basic framebuffer driver that allows us to draw some primitive shapes and text on the screen
//! Until a proper GPU driver is loaded, the framebuffer is all there is for rendering anything.

const root = @import("../root.zig");
const utils = @import("../utils.zig");
const colors = @import("../colors.zig");
const c = root.c;
const printf = root.printf;

// Request a linear framebuffer
export var fbRequest: c.limine_framebuffer_request linksection(".limine_requests") = .{
    .id = root.LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0,
};

// Framebuffer
var fb: *c.limine_framebuffer = undefined;
var pixelsPerRow: usize = 0;

// Font
const FONT = @embedFile("../fonts/unifont.sfn");
const FONT_WIDTH: u8 = 8;
const FONT_HEIGHT: u8 = 16;

/// Initialize the framebuffer by fetching the first one available. If there are none available then the OS is halted indefinitely.
/// This function also initializes SSFN which is a library for rendering text on the screen. It uses `.sfn` font files.
pub fn init(bgColor: u32, fgColor: u32) void {
    // Fetch the first available framebuffer
    const fbResponse: *c.limine_framebuffer_response = @ptrCast(fbRequest.response orelse utils.halt());
    fb = @ptrCast(fbResponse.framebuffers[0]);
    pixelsPerRow = fb.pitch / (fb.bpp / 8);

    // Initialize SSFN - Text renderer
    c.ssfn_src = @ptrCast(@constCast(FONT));
    c.ssfn_dst.ptr = @ptrCast(fb.address);
    c.ssfn_dst.w = @intCast(fb.width);
    c.ssfn_dst.h = @intCast(fb.height);
    c.ssfn_dst.p = @intCast(fb.pitch);
    c.ssfn_dst.x = 0;
    c.ssfn_dst.y = 0;
    c.ssfn_dst.bg = bgColor;
    c.ssfn_dst.fg = fgColor;
}

// Drawing
pub fn drawPixel(xpos: usize, ypos: usize, color: u32) void {
    const fbPtr: [*]u32 = @ptrCast(@alignCast(fb.address));
    fbPtr[ypos * pixelsPerRow + xpos] = color;
}
pub fn drawRect(xpos: usize, ypos: usize, width: usize, height: usize, color: u32) void {
    var fbPtr: [*]u32 = @ptrCast(@alignCast(fb.address));
    fbPtr += ypos * pixelsPerRow;
    for (ypos..ypos + height) |_| {
        @memset(fbPtr[xpos .. xpos + width], color);
        fbPtr += pixelsPerRow;
    }
}
pub fn drawLine(xpos1: isize, ypos1: isize, xpos2: isize, ypos2: isize, color: u32) void {
    // Ensure line doesn't start too far to the left or too far to the right
    if (xpos1 < 0 or xpos2 < 0) {
        c.ssfn_dst.fg = colors.ERR_TEXT_COLOR;
        printf("\n[ERROR]: Attempted to position one of the points of a line too far to the left\n");
        c.ssfn_dst.fg = colors.TEXT_COLOR;
        return;
    } else if (xpos1 > fb.width or xpos2 > fb.width) {
        c.ssfn_dst.fg = colors.ERR_TEXT_COLOR;
        printf("\n[ERROR]: Attempted to position one of the points of a line too far to the right\n");
        c.ssfn_dst.fg = colors.TEXT_COLOR;
        return;
    }

    // Ensure line doesn't start too high up or too low done
    if (ypos1 < 0 or ypos2 < 0) {
        c.ssfn_dst.fg = colors.ERR_TEXT_COLOR;
        printf("\n[ERROR]: Attempted to position one of the points of a line too high up\n");
        c.ssfn_dst.fg = colors.TEXT_COLOR;
        return;
    } else if (ypos1 > fb.height or ypos2 > fb.height) {
        c.ssfn_dst.fg = colors.ERR_TEXT_COLOR;
        printf("\n[ERROR]: Attempted to position one of the points of a line too low down\n");
        c.ssfn_dst.fg = colors.TEXT_COLOR;
        return;
    }

    // Calculate change between X and Y position of the two points
    const dx: isize = xpos2 - xpos1;
    const dy: isize = ypos2 - ypos1;

    // Check if the line is above or below the ideal mathematical line
    var D: isize = 2 * dy - dx;
    var y: isize = ypos1;
    for (@as(usize, @intCast(xpos1))..@as(usize, @intCast(xpos2))) |x| {
        drawPixel(@intCast(x), @intCast(y), color);
        // the ideal line has crossed above the current pixel's midpoint
        if (D > 0) {
            y += 1;
            D += 2 * (dy - dx);
        }

        // `y` stays the same and we just move horizontally
        else D += 2 * dy;
    }
}

// Handy functions
/// Resets the text cursor position and clears the screen by drawing a rectangle that has the same color as the background over everything
pub fn clearScreen() void {
    c.ssfn_dst.x = 0;
    c.ssfn_dst.y = 0;
    drawRect(0, 0, fb.width, fb.height, c.ssfn_dst.bg);
}

/// Putchar implementation which is required for printf.
/// This function is responsible for handling all special characters and drawing each character to the screen.
export fn putchar_(char: u8) callconv(.c) void {
	// Figure out the next cursor position
    const isXOffScreen: bool = (c.ssfn_dst.x + FONT_WIDTH) > fb.width;
    const isYOffScreen: bool = (c.ssfn_dst.y + FONT_HEIGHT) > fb.height;

	// Handle special characters
    switch (char) {
        // Newline
        '\n' => {
            // Go to the beginning of the next line
            c.ssfn_dst.x = 0;
            if (isYOffScreen) {
                clearScreen();
            } else c.ssfn_dst.y += FONT_HEIGHT;
        },

        // Backspace
        '\x08' => {
            if ((c.ssfn_dst.x - FONT_WIDTH) < 0) {
                return;
            }
            c.ssfn_dst.x -= FONT_WIDTH;
            drawRect(@intCast(c.ssfn_dst.x), @intCast(c.ssfn_dst.y), FONT_WIDTH, FONT_HEIGHT, c.ssfn_dst.bg);
        },

        // Normal character
        else => {
            // Ensure character stays inside the screen/framebuffer
            if (isYOffScreen) clearScreen();
            if (isXOffScreen) _ = c.ssfn_putc('\n');

            // Render the character
            _ = c.ssfn_putc(char);
        },
    }
}
