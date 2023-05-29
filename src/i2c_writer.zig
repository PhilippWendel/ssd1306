const std = @import("std");
const microzig = @import("microzig");

pub fn I2C_Writer(comptime address: u7, comptime target_speed: u32) I2CWriterStruct {
    return .{ .address = address, .target_speed = target_speed };
}

const I2CWriterStruct = struct {
    const Self = @This();
    const Writer = std.io.Writer(
        Self,
        error{},
        write_i2c,
    );
    address: u7,
    target_speed: u32,

    fn write_i2c(self: Self, data: []const u8) !usize {
        // TODO(philippwendel) check if const is shared between all invocations of function
        const i2c = microzig.core.experimental.i2c.I2CController(0, .{}).init(.{ .target_speed = self.target_speed }) catch unreachable;
        const ssd1306 = i2c.device(self.address);
        var wt = try ssd1306.start_transfer(.write);
        try wt.writer().writeAll(data);
        wt.stop() catch {};
        busyloop(10); // Delay because it makes stuff magically work
        return data.len;
    }

    pub fn writer(self: Self) Writer {
        return .{ .context = self };
    }
};

fn busyloop(limit: u24) void {
    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("nop");
    }
}
