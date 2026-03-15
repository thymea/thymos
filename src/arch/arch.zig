// Import architecture specific stuff depending on build target
const builtin = @import("builtin");
const arch = switch (builtin.cpu.arch) {
    .x86_64 => @import("x86_64/index.zig"),
    else => @compileError("Unsupported target architecture"),
};

// Export architecture specific functions
pub const initCPU = arch.initCPU;
pub const halt = arch.halt;
