const builtin = @import("builtin");
pub const arch = switch (builtin.cpu.arch) {
    .x86_64 => @import("x86_64/index.zig"),
    else => @compileError("Unsupported target architecture"),
};
