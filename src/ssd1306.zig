const std = @import("std");

const command: u8 = 0x00;

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

pub fn setContrast(c: u8) [3]u8 {
    return [_]u8{ command, @enumToInt(FC.SetContrastControll), c };
}

pub fn displayOn() [2]u8 {
    return [_]u8{ command, @enumToInt(FC.DisplayOn) };
}

pub fn displayOff() [2]u8 {
    return [_]u8{ command, @enumToInt(FC.DisplayOff) };
}

const AddressingMode = enum {
    page,
    horizontal,
    vertical,
};
pub fn addressingMode(mode: AddressingMode) [2]u8 {
    return switch (mode) {
        .page => [_]u8{
            0x20, 0b100
        },
        .horizontal => [_]u8{
            0x20, 0x00
        },
        .vertical => [_]u8{
            0x20, 0x01
        },
    };
}

pub fn verticalAddressing() [2]u8 {
    return [_]u8{
        0x20,
    };
}

// References:
// [1] https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf
