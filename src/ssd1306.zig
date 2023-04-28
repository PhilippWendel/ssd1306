const std = @import("std");

// Design
// pass device or writer/reader
pub fn SSD1306() type {
    return struct {
        pub fn init(wt: anytype) !type {
            return Struct{
                wt = wt,
                pub fn deinit() void {
                    Self.wt.stop() catch {};
                }
                fn write(data: []const u8) !void {
                    try Self.wt.writer().writeAll(data);
                }
            };
        }
    };
}
const ControlByte = struct {
    Co: u1, //Continuation bit
    @"D/C#": u1, // Data / Command Selection bit
    six_0: u6 = 0,
};

const data_bytes_only = ControlByte{ .Co = 0, .@"D/C#" = 1 };

// [1, p. 28]
pub const FundamentalCommands = enum(u8) {
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
    pub fn asBytes(command: FundamentalCommands) [2]u8 {
        return [_]u8{ 0x00, @enumToInt(command) };
    }
};

// References:
// [1] https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf
