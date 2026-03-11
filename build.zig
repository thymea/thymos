const std = @import("std");

// Construct build graph
pub fn build(b: *std.Build) void {
    // Constants
    const PROJECT_NAME: []const u8 = "thymos";
	const INCLUDE_DIR: []const u8 = "include";

    // Target architecture - Target is the native platform by default
    // const target = b.standardTargetOptions(.{});
	const arch = b.option(std.Target.Cpu.Arch, "arch", "Target architecture") orelse std.Target.Cpu.Arch.x86_64;
	const targetQuery: std.Target.Query = .{
		.cpu_arch = arch,
		.abi = .none,
		.os_tag = .freestanding,
	};

    // Optimization mode - Can be either `Debug`, `ReleaseSafe`, `ReleaseFast`, or `ReleaseSmall`
    const optimize = b.standardOptimizeOption(.{});

    // Modules
    const kernelMod = b.addModule(PROJECT_NAME, .{
        .root_source_file = b.path("src/kernel.zig"),
        .target = b.resolveTargetQuery(targetQuery),
        .optimize = optimize,
        .imports = &.{},

		.code_model = .kernel,
		.link_libc = false,
		.link_libcpp = false,
		.stack_check = false,
		.stack_protector = false,
		.unwind_tables = .none,
		.red_zone = false,
		.pic = false,
    });
	kernelMod.addIncludePath(b.path(INCLUDE_DIR));
	kernelMod.addCSourceFile(.{.file = b.path("src/compat.c"), .language = .c});

    // Binary
    const thymos = b.addExecutable(.{
        .name = PROJECT_NAME,
        .root_module = kernelMod,
		.linkage = .static,
    });
	thymos.setLinkerScript(b.path("src/arch/x86_64/linker.ld"));
	thymos.link_z_max_page_size = 0x1000;
	thymos.link_gc_sections = true;

    // Install binary into install prefix
    b.installArtifact(thymos);

    // Run step
    const runStep = b.step("run", "Emulate OS in QEMU");
    const runCmd = b.addRunArtifact(thymos);
    runCmd.step.dependOn(b.getInstallStep());
    runStep.dependOn(&runCmd.step);
    if (b.args) |args| runCmd.addArgs(args);

    // Test step
    const kernelTests = b.addTest(.{ .root_module = kernelMod });
    const runKernelTests = b.addRunArtifact(kernelTests);
    const testStep = b.step("test", "Run tests");
    testStep.dependOn(&runKernelTests.step);
}
