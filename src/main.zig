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

    const init_commands = [_][]const u8{
        &[_]u8{ 0x00, 0xAE, 0xD5, 0x80, 0xA8 },
        &[_]u8{ 0x00, 0x1F },
        &[_]u8{ 0x00, 0xD3, 0x00, 0x40, 0x8D },
        &[_]u8{ 0x00, 0x14 },
        &[_]u8{ 0x00, 0x20, 0x00, 0xA1, 0xC8 },
        &[_]u8{ 0x00, 0xDA },
        &[_]u8{ 0x00, 0x02 },
        &[_]u8{ 0x00, 0x81 },
        &[_]u8{ 0x00, 0x8F },
        &[_]u8{ 0x00, 0xD9 },
        &[_]u8{ 0x00, 0xF1 },
        &[_]u8{ 0x00, 0xDB, 0x40, 0xA4, 0xA6, 0x2E, 0xAF },
        &[_]u8{ 0x00, 0x22, 0x00, 0xFF, 0x21, 0x00 },
        &[_]u8{ 0x00, 0x7F },
    };
    for (init_commands) |c| {
        try ssd1306.wt.writeAll(c);
    }

    try ssd1306.entireDisplayOn(.resumeToRam);
    try ssd1306.deactivateScroll();
    try ssd1306.continuousHorizontalScrollSetup(.right, 0b000, 0b111, 0b100);
    // try ssd1306.continuousVerticalAndHorizontalScrollSetup(.right, 0b000, 0b111, 0b100, 0);
    try ssd1306.setVerticalScrollArea(0, 15);
    try ssd1306.activateScroll();

    //const bitmap = &[_]u8{0x40} ++ &[_]u8{0xF0} ** 512;
    //try ssd1306.wt.writeAll(bitmap);
    for (0..128) |_| {
        try ssd1306.wt.writeAll(&[_]u8{ 0x40, 0xBE, 0xEF, 0x0F, 0xF0 });
    }
    var contrast: u8 = 255;
    while (true) {
        try uart.writer().writeAll("Loop\r\n");
        try ssd1306.setContrast(contrast);
        contrast = if (contrast == 255) 1 else 255;
        //busyloop(1_000_000);
        //try ssd1306.setDisplay(.off);
        busyloop(1_000_000);
        try ssd1306.setDisplay(.on);
        busyloop(1_000_000);
        try ssd1306.setNormalOrInverseDisplay(.inverse);
        busyloop(1_000_000);
        try ssd1306.setNormalOrInverseDisplay(.normal);
        busyloop(1_000_000);
        try ssd1306.entireDisplayOn(.resumeToRam);
        busyloop(1_000_000);
        // try ssd1306.entireDisplayOn(.ignoreRam);
        busyloop(1_000_000);
    }
}

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}
