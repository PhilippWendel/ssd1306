const std = @import("std");
const microzig = @import("microzig");
const interfaces = microzig.core.experimental;
const fc = @import("ssd1306.zig").FundamentalCommands;
// `microzig.config`: comptime access to configuration
// `microzig.chip`: access to register definitions, generated code
// `microzig.board`: access to board information
// `microzig.hal`: access to hand-written code for interacting with the hardware
// `microzig.cpu`: access to AVR5 specific functions

pub fn main() !void {
    const uart = try interfaces.uart.Uart(0, .{}).init(.{
        .baud_rate = 115200,
        .stop_bits = .one,
        .parity = null,
        .data_bits = .eight,
    });
    try uart.writer().writeAll("Hello microzig!\r\n");

    const i2c = try interfaces.i2c.I2CController(0, .{}).init(.{ .target_speed = 100_000 });
    try uart.writer().writeAll("Hello microzig!\r\n");
    const ssd1306 = i2c.device(0x3C);

    {
        var wt = try ssd1306.start_transfer(.write);
        defer wt.stop() catch {};
        try wt.writer().writeAll(&.{ 0x00, 0xAE, 0xD5, 0x80, 0xA8 });

        try wt.writer().writeAll(&.{ 0x00, 0xAE, 0xD5, 0x80, 0xA8 });
        try wt.writer().writeAll(&.{ 0x00, 0x1F });
        try wt.writer().writeAll(&.{ 0x00, 0xD3, 0x00, 0x40, 0x8D });
        try wt.writer().writeAll(&.{ 0x00, 0x14 });
        try wt.writer().writeAll(&.{ 0x00, 0x20, 0x00, 0xA1, 0xC8 });
        try wt.writer().writeAll(&.{ 0x00, 0xDA });
        try wt.writer().writeAll(&.{ 0x00, 0x02 });
        try wt.writer().writeAll(&.{ 0x00, 0x81 });
        try wt.writer().writeAll(&.{ 0x00, 0x8F });
        try wt.writer().writeAll(&.{ 0x00, 0xD9 });
        try wt.writer().writeAll(&.{ 0x00, 0xF1 });
        try wt.writer().writeAll(&.{ 0x00, 0xDB, 0x40, 0xA4, 0xA6, 0x2E, 0xAF });
        try wt.writer().writeAll(&.{ 0x00, 0x22, 0x00, 0xFF, 0x21, 0x00 });
        try wt.writer().writeAll(&.{ 0x00, 0x7F });
        try wt.writer().writeAll(&.{ 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xE0, 0xF0, 0xFC, 0xFE, 0xFF, 0xFF, 0xF8, 0xC0, 0x00, 0x00, 0x00, 0x00 });
        try wt.writer().writeAll(&.{ 0x00, 0xAE, 0xD5, 0x80, 0xA8 });
    }

    var state = fc.DisplayOn;
    var contrast: u8 = 255;
    while (true) {
        {
            var wt = try ssd1306.start_transfer(.write);
            defer wt.stop() catch {};
            const c = fc.asBytes(fc.SetContrastControll);
            try wt.writer().writeAll(&.{ c[0], c[1], contrast });
            try wt.writer().writeByte(contrast);
        }
        contrast = if (contrast == 255) 10 else 255;

        busyloop(1_000_000);
        try uart.writer().print("Display {}\r\n", .{state});
        {
            var wt = try ssd1306.start_transfer(.write);
            defer wt.stop() catch {};
            try wt.writer().writeAll(&fc.asBytes(state));
        }
        state = if (state == fc.DisplayOff) fc.DisplayOn else fc.DisplayOff;
    }
}

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}
