const std = @import("std");

pub const DrawContext = struct {
    pub fn draw(self: *DrawContext) void {
        std.debug.warn("Testing\n", .{});
    }
};
