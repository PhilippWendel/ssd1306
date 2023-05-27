const std = @import("std");

pub fn SSD1306(writer: anytype) SSD1306Struct(@TypeOf(writer)) {
    return .{ .wt = writer };
}

fn SSD1306Struct(comptime WriterType: type) type {
    return struct {
        const Self = @This();
        wt: WriterType,
        // 0x00 AE D5 80 A8 00 1F 00 D3 00 40 D8 00 14 00 20 00 A1 C8 00 DA 00 02 00 81 00 8F 00 D9 00 F1 00 DB 40 A4 A6 2E AF 00 22 00 FF 21 00 00 7F

        // Fundamental Commands
        pub fn setContrast(self: Self, contrast: u8) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), 0x81, contrast });
        }

        pub fn entireDisplayOn(self: Self, mode: DisplayOnMode) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), @enumToInt(mode) });
        }

        pub fn setNormalOrInverseDisplay(self: Self, mode: NormalOrInverseDisplay) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), @enumToInt(mode) });
        }

        pub fn setDisplay(self: Self, mode: DisplayMode) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), @enumToInt(mode) });
        }

        // Scrolling Commands
        pub fn continuousHorizontalScrollSetup(self: Self, direction: HorizontalScrollDirection, start_page: u3, end_page: u3, frame_frequency: u3) !void {
            if (end_page < start_page) return PageError.EndPageIsSmallerThanStartPage;
            try self.wt.writeAll(&[_]u8{
                @bitCast(u8, ControlByte{}),
                @enumToInt(direction),
                0x00, // Dummy byte
                @as(u8, start_page),
                @as(u8, frame_frequency),
                @as(u8, end_page),
                0x00, // Dummy byte
                0xFF, // Dummy byte
            });
        }

        pub fn continuousVerticalAndHorizontalScrollSetup(self: Self, direction: VerticalAndHorizontalScrollDirection, start_page: u3, end_page: u3, frame_frequency: u3, vertical_scrolling_offset: u6) !void {
            try self.wt.writeAll(&[_]u8{
                @bitCast(u8, ControlByte{}),
                @enumToInt(direction),
                0x00, // Dummy byte
                @as(u8, start_page),
                @as(u8, frame_frequency),
                @as(u8, end_page),
                @as(u8, vertical_scrolling_offset),
            });
        }

        pub fn deactivateScroll(self: Self) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), 0x2E });
        }

        pub fn activateScroll(self: Self) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), 0x2F });
        }

        pub fn setVerticalScrollArea(self: Self, start_row: u6, num_of_rows: u7) !void {
            try self.wt.writeAll(&[_]u8{ @bitCast(u8, ControlByte{}), 0xA3, @as(u8, start_row), @as(u8, num_of_rows) });
        }

        // TODO(philippwendel) Addressing Setting Commands

        // TODO(philippwendel) Hardware Configuration Commands
    };
}

const ControlByte = packed struct(u8) {
    Co: u1 = 0,
    DC: u1 = 0,
    unused: u6 = 0,
};

// Fundamental Commands
const DisplayOnMode = enum(u8) { resumeToRam = 0xA4, ignoreRam = 0xA5 };
const NormalOrInverseDisplay = enum(u8) { normal = 0xA6, inverse = 0xA7 };
const DisplayMode = enum(u8) { off = 0xAE, on = 0xAF };

// Scrolling Commands
const HorizontalScrollDirection = enum(u8) { right = 0x26, left = 0x27 };
const VerticalAndHorizontalScrollDirection = enum(u8) { right = 0x29, left = 0x2A };
const PageError = error{
    EndPageIsSmallerThanStartPage,
};

// Tests

// Fundamental Commands
test "setContrast" {
    // Arrange
    for ([_]u8{ 0, 128, 255 }) |contrast| {
        var output = std.ArrayList(u8).init(std.testing.allocator);
        defer output.deinit();
        const expected_data = &[_]u8{ 0x00, 0x81, contrast };
        // Act
        const ssd1306 = SSD1306(output.writer());
        try ssd1306.setContrast(contrast);
        // Assert
        try std.testing.expectEqualSlices(u8, output.items, expected_data);
    }
}

test "entireDisplayOn" {
    // Arrange
    for ([_]u8{ 0xA4, 0xA5 }, [_]DisplayOnMode{ DisplayOnMode.resumeToRam, DisplayOnMode.ignoreRam }) |data, mode| {
        var output = std.ArrayList(u8).init(std.testing.allocator);
        defer output.deinit();
        const expected_data = &[_]u8{ 0x00, data };
        // Act
        const ssd1306 = SSD1306(output.writer());
        try ssd1306.entireDisplayOn(mode);
        // Assert
        try std.testing.expectEqualSlices(u8, output.items, expected_data);
    }
}

test "setNormalOrInverseDisplay" {
    // Arrange
    for ([_]u8{ 0xA6, 0xA7 }, [_]NormalOrInverseDisplay{ NormalOrInverseDisplay.normal, NormalOrInverseDisplay.inverse }) |data, mode| {
        var output = std.ArrayList(u8).init(std.testing.allocator);
        defer output.deinit();
        const expected_data = &[_]u8{ 0x00, data };
        // Act
        const ssd1306 = SSD1306(output.writer());
        try ssd1306.setNormalOrInverseDisplay(mode);
        // Assert
        try std.testing.expectEqualSlices(u8, output.items, expected_data);
    }
}

test "setDisplay" {
    // Arrange
    for ([_]u8{ 0xAF, 0xAE }, [_]DisplayMode{ DisplayMode.on, DisplayMode.off }) |data, mode| {
        var output = std.ArrayList(u8).init(std.testing.allocator);
        defer output.deinit();
        const expected_data = &[_]u8{ 0x00, data };
        // Act
        const ssd1306 = SSD1306(output.writer());
        try ssd1306.setDisplay(mode);
        // Assert
        try std.testing.expectEqualSlices(u8, output.items, expected_data);
    }
}

// Scrolling Commands
// TODO(philippwendel) Test more values and error
test "continuousHorizontalScrollSetup" {
    // Arrange
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();
    const expected_data = &[_]u8{ 0x00, 0x26, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF };
    // Act
    const ssd1306 = SSD1306(output.writer());
    try ssd1306.continuousHorizontalScrollSetup(.right, 0, 0, 0);
    // Assert
    try std.testing.expectEqualSlices(u8, output.items, expected_data);
}

test "continuousVerticalAndHorizontalScrollSetup" {
    // Arrange
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();
    const expected_data = &[_]u8{ 0x00, 0x29, 0x00, 0x01, 0x3, 0x2, 0x4 };
    // Act
    const ssd1306 = SSD1306(output.writer());
    try ssd1306.continuousVerticalAndHorizontalScrollSetup(.right, 1, 2, 3, 4);
    // Assert
    try std.testing.expectEqualSlices(u8, output.items, expected_data);
}

test "deactivateScroll" {
    // Arrange
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();
    const expected_data = &[_]u8{ 0x00, 0x2E };
    // Act
    const ssd1306 = SSD1306(output.writer());
    try ssd1306.deactivateScroll();
    // Assert
    try std.testing.expectEqualSlices(u8, output.items, expected_data);
}

test "activateScroll" {
    // Arrange
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();
    const expected_data = &[_]u8{ 0x00, 0x2F };
    // Act
    const ssd1306 = SSD1306(output.writer());
    try ssd1306.activateScroll();
    // Assert
    try std.testing.expectEqualSlices(u8, output.items, expected_data);
}

test "setVerticalScrollArea" {
    // Arrange
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();
    const expected_data = &[_]u8{ 0x00, 0xA3, 0x00, 0x0F };
    // Act
    const ssd1306 = SSD1306(output.writer());
    try ssd1306.setVerticalScrollArea(0, 15);
    // Assert
    try std.testing.expectEqualSlices(u8, output.items, expected_data);
}

// References:
// [1] https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf
