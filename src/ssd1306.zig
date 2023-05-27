const std = @import("std");

pub fn SSD1306(writer: anytype) SSD1306Struct(@TypeOf(writer)) {
    return .{ .wt = writer };
}

fn SSD1306Struct(comptime WriterType: type) type {
    return struct {
        const Self = @This();
        wt: WriterType,
        // 0x00 AE D5 80 A8 00 1F 00 D3 00 40 D8 00 14 00 20 00 A1 C8 00 DA 00 02 00 81 00 8F 00 D9 00 F1 00 DB 40 A4 A6 2E AF 00 22 00 FF 21 00 00 7F
        swt,
    };
}

// References:
// [1] https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf
