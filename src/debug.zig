const debug = @import("std").debug.warn;

pub fn debug_log(comptime msg: []const u8, args: anytype) void {
    debug(msg ++ "\n", args);
}
