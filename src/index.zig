// Common modules
pub const builtin = @import("builtin");
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
pub const memory = @import("memory/index.zig");

// Common useful functions
// Halt CPU
pub fn halt() noreturn {
    while (true) {
        switch (builtin.cpu.arch) {
            .x86_64 => asm volatile ("hlt"),
            .aarch64, .riscv64 => asm volatile ("wfi"),
            .loongarch64 => asm volatile ("idle 0"),
            else => unreachable,
        }
    }
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
