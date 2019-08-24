const c = @import("c.zig");
const std = @import("std");
const os = std.os;
const panic = std.debug.panic;
const builtin = @import("builtin");
const c_allocator = @import("std").heap.c_allocator;

pub const is_on = if (builtin.mode == builtin.Mode.ReleaseFast) c.GL_FALSE else c.GL_TRUE;

pub fn assertNoError() void {
    if (builtin.mode != builtin.Mode.ReleaseFast) {
        const err = c.glGetError();
        if (err != c.GL_NO_ERROR) {
            panic("GL error: {}\n", err);
        }
    }
}

pub fn printProgramInfoLog(obj: c.GLuint) !void {
    var infologLength: c_int = 0;
    var charsWritten: c_int = 0;

    c.glGetProgramiv(obj, c.GL_INFO_LOG_LENGTH, &infologLength);

    if (infologLength > 0) {
        var infoLog = try c_allocator.alloc(u8, @intCast(usize, infologLength));
        c.glGetProgramInfoLog(obj, infologLength, &charsWritten, @ptrCast([*c]u8, &infoLog[0]));
        std.debug.warn("Linker error\n");
        std.debug.warn("{}\n", infoLog);
        c_allocator.free(infoLog);
    }
}
