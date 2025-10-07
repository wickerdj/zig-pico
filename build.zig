const std = @import("std");
const microzig = @import("microzig");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    // Get MicroZig dependency
    const microzig_dep = b.dependency("microzig", .{});
    const mz = microzig_dep.module("microzig");

    // Create firmware using MicroZig
    const firmware = microzig.addFirmware(b, .{
        .name = "pico_app",
        .target = microzig_dep.builder.dependency("microzig-bsp-rpi-pico", .{}).artifact("rp2040"),
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    // Install the firmware
    microzig.installFirmware(b, firmware, .{});

    // Create UF2 file for drag-and-drop flashing
    const uf2_step = b.step("uf2", "Generate UF2 file for Pico");
    const uf2 = b.addSystemCommand(&[_][]const u8{
        "elf2uf2",
    });
    uf2.addArtifactArg(firmware.artifact);
    const uf2_output = uf2.addOutputFileArg("pico_app.uf2");

    const install_uf2 = b.addInstallFile(uf2_output, "pico_app.uf2");
    uf2_step.dependOn(&install_uf2.step);
    b.getInstallStep().dependOn(uf2_step);
}
