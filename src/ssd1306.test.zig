const std = @import("std");
const SSD1306 = @import("ssd1306.zig");

test "init" {
    // Arrange
    const expected_data = [_]u8{
        SSD1306.command, 0xA8, 0x3F, // Set MUX Ratio
        SSD1306.command, 0xD3, 0x00, // Set Display Offset
        SSD1306.command, 0x40, // Set Display Start Line
        SSD1306.command, 0xA0, // Set Segment remap
        SSD1306.command, 0xC0, // Set COM Output Scan Direction
        SSD1306.command, 0xDA, 0x02, // Set COM Pins hardware configuration
        SSD1306.command, 0x81, 0x7F, // Set Contrast Control
        SSD1306.command, 0xA4, // Disable Entire Display On
        SSD1306.command, 0xA6, // Set Normal Display
        SSD1306.command, 0xD5, 0x80, // Set Osc Frequency
        SSD1306.command, 0x8D, 0x14, // Enable charge pump regulator
        SSD1306.command, 0xAF, // Display On
    };
    // Act
    const recieved_data = SSD1306.init();
    // Assert
    try std.testing.expectEqual(expected_data, recieved_data);
}

test "setContrast" {
    // Arrange
    const vals = [_]u8{ std.math.minInt(u8), std.math.maxInt(u8), 123 };
    for (vals) |val| {
        const expected_data = [_]u8{ SSD1306.command, @enumToInt(SSD1306.FC.SetContrastControll), val };
        // Act
        const recieved_data = SSD1306.setContrast(val);
        // Assert
        try std.testing.expectEqual(expected_data, recieved_data);
    }
}
