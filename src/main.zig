const std = @import("std");
const microzig = @import("microzig");
const interfaces = microzig.core.experimental;
const I2C_Writer = @import("i2c_writer.zig").I2C_Writer;
const SSD1306 = @import("ssd1306.zig").SSD1306;
// `microzig.config`: comptime access to configuration
// `microzig.chip`: access to register definitions, generated code
// `microzig.board`: access to board information
// `microzig.hal`: access to hand-written code for interacting with the hardware
// `microzig.cpu`: access to AVR5 specific functions

pub fn main() !void {
    const uart = interfaces.uart.Uart(0, .{}).init(.{
        .baud_rate = 115200,
        .stop_bits = .one,
        .parity = null,
        .data_bits = .eight,
    }) catch unreachable;
    try uart.writer().writeAll("Hallo Welt\r\n");

    const ssd1306 = SSD1306(I2C_Writer(0x3C, 100_000).writer());
    // try ssd1306.init();
    try uart.writer().writeAll("Init\r\n");
    // const bitmap = &[_]u8{0x40} ++ &[_]u8{0xF0} ** 512;
    // try ssd1306.wt.writeAll(bitmap);

    var contrast: u8 = 255;
    while (true) {
        try uart.writer().writeAll("Loop\r\n");
        try ssd1306.setContrast(contrast);
        contrast = if (contrast == 255) 1 else 255;
        busyloop(1_000_000);
        try ssd1306.setDisplay(.off);
        busyloop(1_000_000);
        try ssd1306.setDisplay(.on);
        busyloop(1_000_000);
        try ssd1306.setNormalOrInverseDisplay(.inverse);
        busyloop(1_000_000);
        try ssd1306.setNormalOrInverseDisplay(.normal);
        busyloop(1_000_000);
        try ssd1306.entireDisplayOn(.resumeToRam);
        busyloop(1_000_000);
        try ssd1306.entireDisplayOn(.ignoreRam);
        busyloop(1_000_000);
    }
}

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}
