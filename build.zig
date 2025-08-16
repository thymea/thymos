const std = @import("std");

// Constants
const x86_FEATURE: type = std.Target.x86.Feature;
const INCLUDE_DIR: []const u8 = "3rdparty";

// Build graph
pub fn build(b: *std.Build) void {
    // Options
    const cpuArch = b.option(std.Target.Cpu.Arch, "arch", "Architecture to build MonOS for") orelse std.Target.Cpu.Arch.x86_64;

    // Build target and optimization mode
    const optimize = b.standardOptimizeOption(.{});
    const targetQuery = std.Target.Query{
        .cpu_arch = cpuArch,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_add = std.Target.x86.featureSet(&.{.soft_float}),
        .cpu_features_sub = std.Target.x86.featureSet(&.{ .mmx, .avx, .avx2, .sse, .sse2 }),
    };

    // Dependencies
    const limineDep = b.dependency("limine_zig", .{
        .api_revision = 3,
        .allow_deprecated = false,
        .no_pointers = false,
    });

    // Modules
    const kernelMod = b.createModule(.{
        .root_source_file = b.path("src/kernel.zig"),
        .code_model = .kernel,
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

    // Add C + Assembly libraries/code
    kernel.addIncludePath(b.path(INCLUDE_DIR));
    kernel.addCSourceFile(.{ .file = b.path("src/printf.c"), .flags = &.{} });
    kernel.addObjectFile(b.path("zig-out/asm.o"));

    // Install the kernel
    kernel.setLinkerScript(b.path(b.fmt("src/linker-{s}.ld", .{@tagName(cpuArch)})));
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
