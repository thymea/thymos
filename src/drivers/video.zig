const limine = @import("limine");

// Constants
const CHUNK_SIZE: u8 = 16;

// Framebuffer
export var fbRequest: limine.FramebufferRequest linksection(".limine_requests") = .{};
var fb: ?*limine.Framebuffer = null;
var pitchInPixels: u32 = 0;
var bgColor: u32 = 0x000000;
var fgColor: u32 = 0xffffff;

// Initialize everything
pub fn initVideo(backgroundColor: u32, foregroundColor: u32) void {
    // Ensure a framebuffer is present
    if (fbRequest.response) |response| {
        // Get the framebuffer
        fb = response.getFramebuffers()[0];
        pitchInPixels = @intCast(fb.?.pitch / @sizeOf(u32));

        // Set stuff
        bgColor = backgroundColor;
        fgColor = foregroundColor;
    } else @panic("No framebuffer");
}

// Clear the screen
pub fn clearScreen() void {
    drawFilledRect(0, 0, @intCast(fb.?.width), @intCast(fb.?.height), bgColor);
}

// Place a pixel
pub fn drawPixel(xpos: u64, ypos: u64, color: u32) void {
    // Calculate the absolute pixel position and color it
    const pixelPos: [*]u32 = @as([*]u32, @ptrCast(@alignCast(fb.?.address))) + (ypos * fb.?.pitch) + (xpos * fb.?.bpp);
    pixelPos[0] = color;
}

// Draw a color filled rectangle
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
