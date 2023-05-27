const std = @import("std");

pub fn SSD1306(writer: anytype) SSD1306Struct(@TypeOf(writer)) {
    return .{ .wt = writer };
}

fn SSD1306Struct(comptime WriterType: type) type {
    return struct {
        const Self = @This();
        wt: WriterType,
        // 0x00 AE D5 80 A8 00 1F 00 D3 00 40 D8 00 14 00 20 00 A1 C8 00 DA 00 02 00 81 00 8F 00 D9 00 F1 00 DB 40 A4 A6 2E AF 00 22 00 FF 21 00 00 7F
        pub fn init(self: Self) !void {
            if (true) {
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
                    try self.wt.writeAll(c);
                }
            } else {
                // 00 DA 00 02 00 81 00 8F 00 D9 00 F1 00 DB 40 A4 A6 2E AF 00 22 00 FF 21 00 00 7F
                try self.display(.off); // 00 AE
                try self.setDisplayClockDivideAndOscillatorFrequency(0x80); // D5 80
                try self.setMultiplexRatio(15); // A8 00
                try self.setHigherColumnStartAddressForPageAddressingMode(0xF); // 00 1F
                try self.setDisplayOffset(0); // 00 D3 00
                try self.setDisplayStartLine(0); // 40
                // D8 ???
                try self.setHigherColumnStartAddressForPageAddressingMode(0x4); // 00 14
                try self.addressingMode(.horizontal); // 00 20 00
                try self.setSegmentRemap(.segTo127); // 00 A1
                try self.setCOMOutputScanDirection(.remapped); // 00 C8
            }
        }

        pub fn setContrast(self: Self, c: u8) !void {
            try self.wt.writeAll(&[_]u8{ command, @enumToInt(FC.SetContrastControll), c });
        }

        const DisplayState = enum { on, off, normal, inverse };
        pub fn display(self: Self, state: DisplayState) !void {
            try self.wt.writeAll(&[_]u8{ command, switch (state) {
                .on => @enumToInt(FC.DisplayOn),
                .off => @enumToInt(FC.DisplayOff),
                .normal => 0xa6,
                .inverse => 0xa7,
            } });
        }
        //TODO(philippwendel) make each into own function and split input or make union
        pub fn setDisplayClockDivideAndOscillatorFrequency(self: Self, c: u8) !void {
            try self.wt.writeAll(&[_]u8{ command, 0xD5, c });
        }
        pub fn setMultiplexRatio(self: Self, c: u5) !void {
            if (c <= 14) return error.InvalidEntry;
            try self.wt.writeAll(&[_]u8{ command, 0xA8, c });
        }
        pub fn setHigherColumnStartAddressForPageAddressingMode(self: Self, c: u4) !void {
            var byte = 0b0001_0000 | @as(u8, c);
            try self.wt.writeAll(&[_]u8{ command, byte });
        }
        pub fn setDisplayOffset(self: Self, c: u5) !void {
            try self.wt.writeAll(&[_]u8{ command, 0xD3, c });
        }
        pub fn setDisplayStartLine(self: Self, c: u6) !void {
            var byte = 0x40 | @as(u8, c);
            try self.wt.writeAll(&[_]u8{ command, byte });
        }
        const AddressingMode = enum { page, horizontal, vertical };
        pub fn addressingMode(self: Self, mode: AddressingMode) !void {
            try self.wt.writeAll(&[_]u8{ command, 0x20, switch (mode) {
                .page => 0b10,
                .horizontal => 0x00,
                .vertical => 0x01,
            } });
        }
        pub fn setSegmentRemap(self: Self, r: enum { segTo0, segTo127 }) !void {
            try self.wt.writeAll(&[_]u8{ command, switch (r) {
                .segTo0 => 0xA0,
                .segTo127 => 0xA1,
            } });
        }
        pub fn (self: Self, byte: u8) !void {
            try self.wt.writeAll(&[_]u8{ @bitcast(u8, ControllByte{ .Co = 1, .@"D/C#" = 1 }), byte });
        }
        pub fn setCOMOutputScanDirection(self: Self, r: enum { normal, remapped }) !void {
            try self.wt.writeAll(&[_]u8{ command, switch (r) {
                .normal => 0xC0,
                .remapped => 0xC8,
            } });
        }
    };
}

const ControllByte = packed struct {
    // If the Co bit is set as logic “0”, the transmission of the following information will contain data bytes only
    Co: u1,
    // The D/C# bit determines the next data byte is acted as a command or a data.
    // If the D/C# bit is set to logic “0”, it defines the following data byte as a command.
    // If the D/C# bit is set to logic “1”, it defines the following data byte as a data which will be stored at the GDDRAM.
    @"D/C#": enum(u1) { Command = 0, Data = 1 },
    data: u6 = 0b00_0000,
};
// [1, p. 28]
pub const FC = enum(u8) {
    /// Double byte command to select 1 out of 256 contrast steps.
    /// Contrast increases as the value increases.
    /// (RESET = 7Fh )
    SetContrastControll = 0x81,
    /// Resume to RAM content display
    /// Output follows RAM content
    EntrireDisplayOnFollowRamContent = 0xA4,
    /// Entire display ON
    /// Output ignores RAM content
    EntrireDisplayOnIgnoreRamContent = 0xA5,
    /// Normal display (RESET)
    /// 0 in RAM: OFF in display panel
    NormalDisplay = 0xA6,
    /// Normal display (RESET)
    /// 1 in RAM: ON in display pane
    InverseDisplay = 0xA7,
    /// Display OFF (sleep mode) (RESET)
    DisplayOff = 0xAE,
    /// Display ON in normal mode
    DisplayOn = 0xAF,
};

const Address = error{ StartToLarge, EndToLarge };

// Constants
const command: u8 = 0x00;
const data = ControllByte{ .Co = 0, .@"D/C#" = .Data };

// References:
// [1] https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf

test "constants" {
    try std.testing.expectEqual(0x00, command);
    try std.testing.expectEqual(0x40, data.raw);

    try std.testing.expectEqual(0x81, @enumToInt(FC.SetContrastControll));
    try std.testing.expectEqual(0xA4, @enumToInt(FC.EntrireDisplayOnFollowRamContent));
    try std.testing.expectEqual(0xA5, @enumToInt(FC.EntrireDisplayOnIgnoreRamContent));
    try std.testing.expectEqual(0xA6, @enumToInt(FC.NormalDisplay));
    try std.testing.expectEqual(0xA7, @enumToInt(FC.InverseDisplay));
    try std.testing.expectEqual(0xAE, @enumToInt(FC.DisplayOff));
    try std.testing.expectEqual(0xAF, @enumToInt(FC.DisplayOn));
}

test "init" {
    // Arrange
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();
    const expected_data = &[_]u8{ 0x00, 0xAE, 0xD5, 0x80, 0xA8, 0x00, 0x1F, 0x00, 0xD3, 0x00, 0x40, 0x8D, 0x00, 0x14, 0x00, 0x20, 0x00, 0xA1, 0xC8, 0x00, 0xDA, 0x00, 0x02, 0x00, 0x81, 0x00, 0x8F, 0x00, 0xD9, 0x00, 0xF1, 0x00, 0xDB, 0x40, 0xA4, 0xA6, 0x2E, 0xAF, 0x00, 0x22, 0x00, 0xFF, 0x21, 0x00, 0x00, 0x7F };
    // Act
    const ssd1306 = SSD1306(output.writer());
    try ssd1306.init();
    // Assert
    try std.testing.expectEqualSlices(u8, output.items, expected_data);
}
