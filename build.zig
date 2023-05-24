const std = @import("std");
const atmega = @import("deps/microchip-atmega/build.zig");

// the hardware support package should have microzig as a dependency
const microzig = @import("deps/microchip-atmega/deps/microzig/build.zig");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});

    // Tests
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/ssd1306.test.zig" },
        .target =  b.standardTargetOptions(.{}),
        .optimize = optimize,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    var exe = microzig.addEmbeddedExecutable(b, .{
        .name = "my-executable",
        .source_file = .{
            .path = "src/main.zig",
        },
        .backing = .{
            .board = atmega.boards.arduino_uno,

            // instead of a board, you can use the raw chip as well
            // .chip = atmega.chips.atmega328p,
        },
        .optimize = optimize,
    });
    exe.installArtifact(b);
}
