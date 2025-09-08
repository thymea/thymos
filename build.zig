const std = @import("std");

// Constants
const INCLUDE_DIR: []const u8 = "3rdparty";

// Build graph
pub fn build(b: *std.Build) void {
    // Options
    const cpuArch = b.option(std.Target.Cpu.Arch, "arch", "Build target") orelse std.Target.Cpu.Arch.x86_64;

    // Build target and optimization mode
    const optimize = b.standardOptimizeOption(.{});
    var targetQuery = std.Target.Query{
        .cpu_arch = cpuArch,
        .os_tag = .freestanding,
        .abi = .none,
    };

    // Enable/Disable CPU features
    switch (cpuArch) {
        .x86_64 => {
            targetQuery.cpu_features_add = std.Target.x86.featureSet(&.{.soft_float});
            targetQuery.cpu_features_sub = std.Target.x86.featureSet(&.{.sse});
        },
        else => {},
    }

    // Dependencies
    const limineDep = b.dependency("limine_zig", .{
        .api_revision = 3,
        .allow_deprecated = false,
        .no_pointers = false,
    });

    // Modules
    const kernelMod = b.createModule(.{
        .root_source_file = b.path("src/kernel.zig"),
        .target = b.resolveTargetQuery(targetQuery),
        .optimize = optimize,
        .link_libc = false,
        .link_libcpp = false,
        .pic = false, // Disable position independent code
        .omit_frame_pointer = false, // Needed for stack traces

        // Disable features that are problematic in kernel space
        .red_zone = false,
        .stack_check = false,
        .stack_protector = false,

        .imports = &.{
            .{ .name = "limine", .module = limineDep.module("limine") },
        },
    });

    // Kernel binary/executable
    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = kernelMod,
        .linkage = .static,
    });

    // Delete unused sections to reduce the kernel size
    kernel.link_function_sections = true;
    kernel.link_data_sections = true;
    kernel.link_gc_sections = true;

    // Force the page size to 4kb to prevent binary bloat
    kernel.link_z_max_page_size = 0x1000;

    // Disable LTO as it can lead to issues for kernels
    kernel.want_lto = false;

    // x86 specific
    if (cpuArch == std.Target.Cpu.Arch.x86_64) {
        kernelMod.code_model = .kernel;
        kernelMod.addAssemblyFile(b.path("src/arch/x86_64/asm.s"));
    }

    // Add C libraries/code
    kernel.addIncludePath(b.path(INCLUDE_DIR));
    kernel.addCSourceFile(.{ .file = b.path("src/printf.c"), .flags = &.{} });

    // Install the kernel
    kernel.setLinkerScript(b.path(b.fmt("src/arch/{s}/linker.ld", .{@tagName(cpuArch)})));
    b.installArtifact(kernel);

    // Run step
    const runCmd = b.addRunArtifact(kernel);
    runCmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| runCmd.addArgs(args);
    const runStep = b.step("run", "Run the app");
    runStep.dependOn(&runCmd.step);

    // Test step
    const kernelUnitTests = b.addTest(.{ .root_module = kernelMod });
    const runKernelUnitTests = b.addRunArtifact(kernelUnitTests);
    const testStep = b.step("test", "Run unit tests");
    testStep.dependOn(&runKernelUnitTests.step);
}
