const std = @import("std");
const c = @import("c.zig");

const print = std.debug.warn;

pub fn main() anyerror!void {
    print("Hello, world \n");
}
