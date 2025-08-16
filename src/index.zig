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

// Check if two strings are equal
pub fn strEq(a: [*]const u8, b: [:0]const u8) bool {
    var i: usize = 0;
    while (true) {
        if (a[i] != b[i]) return false;
        if (a[i] == 0) return true;
        i += 1;
    }
}
