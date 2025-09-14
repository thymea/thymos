// Common modules
pub const builtin = @import("builtin");
pub const limine = @import("limine");
pub const c = @cImport({
    @cDefine("NULL", "((void*)0)");
    @cDefine("SSFN_CONSOLEBITMAP_TRUECOLOR", {});
    @cInclude("ssfn.h");

    @cDefine("PRINTF_ALIAS_STANDARD_FUNCTION_NAMES_HARD", "1");
    @cInclude("printf/printf.h");
});

// OS
pub const arch = @import("arch/index.zig").Arch;
pub const drivers = @import("drivers/index.zig");
pub const memory = @import("memory/index.zig");

// Common useful functions
// Check if two strings are equal
pub fn strEq(a: [*]const u8, b: [:0]const u8) bool {
    var i: usize = 0;
    while (true) {
        if (a[i] != b[i]) return false;
        if (a[i] == 0) return true;
        i += 1;
    }
}
