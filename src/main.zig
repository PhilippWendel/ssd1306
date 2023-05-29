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
    try uart.writer().writeAll("Hello World\r\n");

    const ssd1306 = SSD1306(I2C_Writer(0x3C, 400_000).writer());
    try uart.writer().writeAll("Hello World\r\n");
    try ssd1306.init();

    try uart.writer().writeAll("clearScreen\r\n");
    try ssd1306.clearScreen(true);
    busyloop(1_000_000);
    try ssd1306.clearScreen(false);
    for (0..8) |lines| {
        for (0..128) |cols| {
            try ssd1306.wt.writeAll(&[_]u8{ 0x40, if (lines == 0 or lines == 7 or cols <= 7 or cols >= 120) 0xFF else 0x00 });
        }
    }

    try uart.writer().writeAll("Write Zig-Logo\r\n");
    try ssd1306.setMemoryAddressingMode(.horizontal);
    try ssd1306.setColumnAddress(16, 111);
    try ssd1306.setPageAddress(1, 6);
    const zig_logo = @embedFile("zig_logo.pbm");
    const zig_img = zig_logo[9..]; // Ignore pbm metadata

    // We write in 8x8 bit blocks since our image goes from left to right and then top to bottom,
    // but the display goes 8 bits down and then left to right and then top to bottom,
    for (0..48 / 8) |line| {
        for (0..96 / 8) |col| {
            const masks = [_]u8{ 0b1000_0000, 0b0100_0000, 0b0010_0000, 0b0001_0000, 0b0000_1000, 0b0000_0100, 0b0000_0010, 0b0000_0001 };
            for (masks) |mask| {
                var byte: u8 = 0;
                for (0..8) |i| {
                    if ((zig_img[line * 8 * 12 + col + 12 * i] & mask) != 0) {
                        byte |= masks[7 - i];
                    }
                }
                try ssd1306.wt.writeAll(&[_]u8{ 0x40, byte });
            }
        }
    }
    try uart.writer().writeAll("Setup scrolling\r\n");
    try ssd1306.deactivateScroll();
    try ssd1306.continuousHorizontalScrollSetup(.right, 1, 6, 0b111);
    try ssd1306.setVerticalScrollArea(8, 48);
    try ssd1306.activateScroll();

    // try ssd1306.entireDisplayOn(.resumeToRam);
    try ssd1306.setMemoryAddressingMode(.horizontal);
    try ssd1306.setColumnAddress(0, 127);
    try ssd1306.setPageAddress(0, 7);
    var contrast: u8 = 255;
    try uart.writer().writeAll("Loop\r\n");
    while (true) {
        try ssd1306.setContrast(contrast);
        contrast = if (contrast == 255) 128 else 255;
        // try ssd1306.wt.writeAll(&[_]u8{ 0x40, 0x00 });
        busyloop(1_000_000);
    }
}

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}
