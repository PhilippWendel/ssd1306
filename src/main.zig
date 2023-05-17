const std = @import("std");
const microzig = @import("microzig");
const interfaces = microzig.core.experimental;
const SSD1306 = @import("ssd1306.zig");
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
    const ssd1306 = i2c.device(0x3C);
    try uart.writer().writeAll("Created I2C!\r\n");

    var contrast: u8 = 255;
    try write_i2c(ssd1306, &SSD1306.init());
    while (true) {
        try write_i2c(ssd1306, &SSD1306.setContrast(contrast));
        contrast = if (contrast == 255) 10 else 255;
        busyloop(1_000_000);
        try write_i2c(ssd1306, &SSD1306.display(.inverse));
        busyloop(1_000_000);
        try write_i2c(ssd1306, &SSD1306.display(.normal));
        busyloop(1_000_000);
    }
}

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}

fn write_i2c(i2c_device: anytype, data: []const u8) !void {
    var wt = try i2c_device.start_transfer(.write);
    defer wt.stop() catch {};
    try wt.writer().writeAll(data);
}
