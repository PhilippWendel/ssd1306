const microzig = @import("microzig");
const interfaces = microzig.core.experimental;

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
        // try wt.writer().writeAll(&.{ 0x00, 0xAE, 0xD5 , 0x80 , 0xA8 });

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
    }

    while (true) {
        busyloop();
    }
}

fn busyloop() void {
    const limit = 1_000_000;

    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
        // @import("std").mem.doNotOptimizeAway(i);
    }
}

fn SSD1306(i2c: interfaces.i2c.I2Controller) struct {
    const device = i2c.device(0x3C);
    var wt: asdf = undefined;
    fn write(data: []u8) !void {
        try wt.writer.writeAll(data); 
    }
    pub fn init() !void {

    }
}
