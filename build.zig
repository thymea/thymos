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
            targetQuery.cpu_features_sub = std.Target.x86.featureSet(&.{ .mmx, .avx, .avx2, .sse, .sse2 });
        },
        .riscv64 => {
            targetQuery.cpu_model = .baseline;
            targetQuery.cpu_features_sub = std.Target.riscv.featureSet(&.{ .a, .c, .d, .e, .f });
            targetQuery.cpu_features_add = std.Target.riscv.featureSet(&.{.m});
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
        .red_zone = false,
        .target = b.resolveTargetQuery(targetQuery),
        .optimize = optimize,
        .imports = &.{
            .{ .name = "limine", .module = limineDep.module("limine") },
        },
    });

    // Kernel binary/executable
    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = kernelMod,
    });

    // x86 specific
    if (cpuArch == std.Target.Cpu.Arch.x86_64) {
        kernelMod.code_model = .kernel;
        kernel.addObjectFile(b.path("zig-out/asm.o"));
    }

    // Add C + Assembly libraries/code
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
