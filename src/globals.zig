// Miscellaneous
pub const TAB_SPACES: u8 = 4;

// Font
pub const font = @embedFile("fonts/unifont.sfn");
pub const GLYPH_WIDTH: u8 = 8;
pub const GLYPH_HEIGHT: u8 = 16;

// Common modules
pub const limine = @import("limine");
pub const c = @cImport({
    @cDefine("NULL", "((void*)0)");
    @cDefine("SSFN_CONSOLEBITMAP_TRUECOLOR", {});
    @cInclude("ssfn.h");
    @cInclude("printf.h");
});

// Common useful functions
// Halt CPU
pub fn halt() noreturn {
    while (true) asm volatile ("hlt");
}
