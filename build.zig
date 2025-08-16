const std = @import("std");

// Constants
const x86_FEATURE: type = std.Target.x86.Feature;
const INCLUDE_DIR: []const u8 = "3rdparty";

// Build graph
pub fn build(b: *std.Build) void {
    // CPU features
    // Enabled
    var enabledFeatures = std.Target.Cpu.Feature.Set.empty;
    enabledFeatures.addFeature(@intFromEnum(x86_FEATURE.soft_float));

    // Disabled
    var disabledFeatures = std.Target.Cpu.Feature.Set.empty;
    disabledFeatures.addFeature(@intFromEnum(x86_FEATURE.mmx));
    disabledFeatures.addFeature(@intFromEnum(x86_FEATURE.sse));
    disabledFeatures.addFeature(@intFromEnum(x86_FEATURE.sse2));
    disabledFeatures.addFeature(@intFromEnum(x86_FEATURE.avx));
    disabledFeatures.addFeature(@intFromEnum(x86_FEATURE.avx2));

    // Build target and optimization mode
    const optimize = b.standardOptimizeOption(.{});
    const targetQuery = std.Target.Query{
        .cpu_arch = std.Target.Cpu.Arch.x86_64,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_add = enabledFeatures,
        .cpu_features_sub = disabledFeatures,
    };

    // Dependencies
    const limine = b.dependency("limine_zig", .{
        .api_revision = 3,
        .allow_deprecated = false,
        .no_pointers = false,
    });

    // Modules
    const limineMod = limine.module("limine");
    const kernelMod = b.createModule(.{
        .root_source_file = b.path("src/kernel.zig"),
        .code_model = .kernel,
        .target = b.resolveTargetQuery(targetQuery),
        .optimize = optimize,
    });

    // Kernel binary/executable
    const kernel = b.addExecutable(.{ .name = "kernel.elf", .root_module = kernelMod });

    // Add C + Assembly libraries/code
    kernel.addIncludePath(b.path(INCLUDE_DIR));
    kernel.addCSourceFile(.{ .file = b.path("src/printf.c"), .flags = &.{} });
    kernel.addObjectFile(b.path("zig-out/asm.o"));

    // Add imports
    kernelMod.addImport("limine", limineMod);

    // Install the kernel
    kernel.setLinkerScript(b.path("src/linker.ld"));
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
