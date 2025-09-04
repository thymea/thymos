const builtin = @import("../index.zig").builtin;

// Architecture specific functions
pub const Arch = switch (builtin.cpu.arch) {
    .x86_64 => @import("x86_64/index.zig"),
    .riscv64 => @import("riscv64/index.zig"),
    else => @compileError("Unsupported CPU architecture"),
};
