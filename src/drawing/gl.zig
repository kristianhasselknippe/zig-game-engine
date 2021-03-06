const std = @import("std");
const print = std.debug.warn;
const fmt = std.fmt;
const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");
const builtin = @import("builtin");
const assert = std.debug.assert;
usingnamespace @import("../typeUtils.zig");

pub const VertexArray = struct {
    handle: c.GLuint,

    pub fn create() @This() {
        var vao: c.GLuint = undefined;
        c.glGenVertexArrays(1, &vao);

        return @This(){ .handle = vao };
    }

    pub fn enable(self: @This()) void {
        c.glEnableVertexAttribArray(0);
        debug_gl.assertNoError();
    }

    pub fn bind(self: @This()) void {
        c.glBindVertexArray(self.handle);
        print("Bound vao: <{}> \n", .{self.handle});
        debug_gl.assertNoError();
    }
};

fn GLBuffer(comptime bufferType: anytype) type {
    return struct {
        handle: c.GLuint,

        const Self = @This();

        pub fn create() Self {
            var vbo: c.GLuint = undefined;
            c.glGenBuffers(1, &vbo);
            return Self{ .handle = vbo };
        }

        pub fn bind(self: Self) void {
            c.glBindBuffer(bufferType, self.handle);
            debug_gl.assertNoError();
        }

        //TODO: Make sure we can only call this if the buffer is bound
        pub fn setData(self: Self, comptime T: type, data: []T) void {
            const bufferLen = @intCast(c_long, data.len * @sizeOf(T));
            c.glBufferData(bufferType, bufferLen, &data[0], c.GL_STATIC_DRAW);
            debug_gl.assertNoError();
        }
    };
}

fn glTypeForZigType(comptime T: type) comptime_int {
    return switch (T) {
        f16, f32, f64 => c.GL_FLOAT,
        i16, i32, i64 => c.GL_INT,
        else => {
            @compileError("Type not supported as vertex layout type: " ++ @typeName(T));
        },
    };
}

fn glSizeForZigType(comptime T: type) i32 {
    return switch (T) {
        f16 => 2,
        f32 => 4,
        f64 => 8,
        else => {
            @compileError("Type not supported as vertex layout type");
        },
    };
}

fn numberOfFieldsInStruct(s: builtin.Struct) u32 {
    return s.fields.len;
}

const Shape = struct {
    numComponents: usize,
    childType: type,
};

fn unwrapType(comptime T: type) Shape {
    switch (@typeInfo(T)) {
        .Struct => |s| {
            comptime const areAllFieldsSameSize = ensureAllFieldsHaveTheSameSize(s);
            if (!areAllFieldsSameSize) {
                @compileError("Expected all fields of a vertex attribute struct to have the same size.");
            }
            return Shape{
                .numComponents = s.fields.len,
                .childType = s.fields[0].field_type,
            };
        },
        .Array => |a| {
            return Shape{
                .numComponents = a.len,
                .childType = a.child(),
            };
        },
        .Float => |f| {
            return Shape{
                .numComponents = 1,
                .childType = switch (f.bits) {
                    16 => f16,
                    32 => f32,
                    64 => f64,
                    else => unreachable,
                },
            };
        },
        .Int => |i| {
            return Shape{
                .numComponents = 1,
                .childType = switch (f.bits) {
                    16 => i16,
                    32 => i32,
                    64 => i64,
                    else => unreachable,
                },
            };
        },
        else => @compileError("Unsupported type" ++ @typeName(T)),
    }
}

test "unwrapTypeTest" {
    const TestStruct = struct {
        x: f32,
        y: f32,
    };

    const res = unwrapType(TestStruct);
    assert(res.numComponents == 2);
    assert(res.childType == f32);

    const res2 = unwrapType(f64);
    assert(res2.numComponents == 1);
    assert(res2.childType == f64);
}

pub fn setVertexAttribLayout(comptime T: type) void {
    debug_gl.assertNoError();
    switch (@typeInfo(T)) {
        .Struct => |*info| {
            comptime var position: i32 = 0;
            comptime const stride = @sizeOf(T);
            c.glEnableVertexAttribArray(0);
            inline for (info.fields) |field, i| {

                // TODO: Better name than T2
                const T2 = field.field_type;
                const info2 = @typeInfo(T2);

                switch (info2) {
                    .Struct => |s| {
                        const name = @typeName(T2);
                        comptime const shape = unwrapType(T2);
                        comptime const glType = glTypeForZigType(shape.childType);

                        c.glVertexAttribPointer(position, shape.numComponents, glTypeForZigType(shape.childType), c.GL_FALSE, stride, @intToPtr(?*const c_void, @byteOffsetOf(T, field.name)));
                        c.glEnableVertexAttribArray(position);
                        debug_gl.assertNoError();
                    },
                    else => {
                        @compileError("enableVertexAttrib expects a struct type describing the vertex layout.");
                    },
                }
                position += 1;
            }
        },
        else => unreachable,
    }
}

pub fn drawElements(len: c_int) void {
    c.glDrawElements(c.GL_TRIANGLES, len, c.GL_UNSIGNED_INT, null);
}

pub const ArrayBuffer = GLBuffer(c.GL_ARRAY_BUFFER);
pub const ElementArrayBuffer = GLBuffer(c.GL_ELEMENT_ARRAY_BUFFER);
