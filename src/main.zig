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
    try uart.writer().writeAll("Init\r\n");
    try ssd1306.init(true);
    try ssd1306.clearScreen();
    // try ssd1306.setPageAddress(0, 7); // 00 22 00 FF
    // try ssd1306.setColumnAddress(0, 0); // 21 00 00
    // try ssd1306.setDisplayStartLine(0x3F); // 7F

    //const bitmap = &[_]u8{0x40} ++ &[_]u8{0xF0} ** 512;
    //try ssd1306.wt.writeAll(bitmap);
    try ssd1306.setMemoryAddressingMode(.horizontal);
    try ssd1306.setColumnAddress(20, 30);
    try ssd1306.setPageAddress(2, 4);
    for (0..30) |_| {
        try ssd1306.wt.writeAll(&[_]u8{ 0x40, 0x00 });
    }
    // try ssd1306.wt.writeAll(&[_]u8{ 0x40, 0xFF, 0xFF, 0xFF, 0xFF });

    // try ssd1306.continuousHorizontalScrollSetup(.right, 0b000, 0b111, 0b100);
    // try ssd1306.continuousVerticalAndHorizontalScrollSetup(.right, 0b000, 0b111, 0b100, 0);
    // try ssd1306.setVerticalScrollArea(0, 15);
    // try ssd1306.activateScroll();

    var contrast: u8 = 255;
    while (true) {
        try uart.writer().writeAll("Loop\r\n");
        try ssd1306.setContrast(contrast);
        contrast = if (contrast == 255) 1 else 255;
        busyloop(1_000_000);
        // try ssd1306.setDisplay(.off);
        // busyloop(1_000_000);
        // try ssd1306.setDisplay(.on);
        // busyloop(1_000_000);
        // try ssd1306.setNormalOrInverseDisplay(.inverse);
        // busyloop(1_000_000);
        // try ssd1306.setNormalOrInverseDisplay(.normal);
        // busyloop(1_000_000);
        // try ssd1306.entireDisplayOn(.resumeToRam);
        // busyloop(1_000_000);
        // // try ssd1306.entireDisplayOn(.ignoreRam);
        // busyloop(1_000_000);
        // try ssd1306.wt.writeAll(&[_]u8{ 0x40, 0xFF, 0xFF, 0xFF, 0xFF });
    }
}

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}
