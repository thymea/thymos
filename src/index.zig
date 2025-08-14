// Common modules
pub const limine = @import("limine");
pub const c = @cImport({
    @cDefine("NULL", "((void*)0)");
    @cDefine("SSFN_CONSOLEBITMAP_TRUECOLOR", {});
    @cInclude("ssfn.h");
    @cInclude("printf.h");
});

// OS
pub const cpu = @import("cpu/index.zig");
pub const drivers = @import("drivers/index.zig");

// Common useful functions
// Halt CPU
pub fn halt() noreturn {
    while (true) asm volatile ("hlt");
}
