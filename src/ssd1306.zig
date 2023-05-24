const std = @import("std");

pub const command: u8 = 0x00;
const data: u8 = 0b0100_0000;

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

pub fn init() [14][]const u8 {
    return [_] []const u8{
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
}

pub fn setContrast(c: u8) [3]u8 {
    return [_]u8{ command, @enumToInt(FC.SetContrastControll), c };
}

pub fn display(state: enum { on, off, normal, inverse }) [2]u8 {
    return switch (state) {
        .on => [_]u8{ command, @enumToInt(FC.DisplayOn) },
        .off => [_]u8{ command, @enumToInt(FC.DisplayOff) },
        .normal => [_]u8{ command, 0xa6 },
        .inverse => [_]u8{ command, 0xa7 },
    };
}

pub fn addressingMode(mode: enum {
    page,
    horizontal,
    vertical,
}) [3]u8 {
    return [_]u8{ command, 0x20 } ++ switch (mode) {
        .page => [_]u8{0b10},
        .horizontal => [_]u8{0x00},
        .vertical => [_]u8{0x01},
    };
}

const Address = error{ StartToLarge, EndToLarge };
pub fn setColumnStartAndEndAddress(start: u8, end: u8) Address![6]u8 {
    if (start > 127) return Address.StartToLarge;
    if (end > 127) return Address.EndToLarge;
    return [_]u8{ command, 0x21, command, start, command, end };
}

const ColumnAddress = error{ StartToLarge, EndToLarge };

pub fn setPageStartAndEndAddress(start: u8, end: u8) Address![6]u8 {
    if (start > 7) return Address.StartToLarge;
    if (end > 7) return Address.EndToLarge;
    return [_]u8{
        // Setup page start and end address
        command, 0x22,
        command, start,
        command, end,
    };
}

// References:
// [1] https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf
