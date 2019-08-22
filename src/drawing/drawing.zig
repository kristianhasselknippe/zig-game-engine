const std = @import("std");
const print = std.debug.warn;
const fmt = std.fmt;
const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");
const builtin = @import("builtin");
const assert = std.debug.assert;

pub const VertexArray = struct {
    handle: c.GLuint,

    pub fn create() @This() {
        var vao: c.GLuint = undefined;
        c.glGenVertexArrays(1, &vao);

        return @This() {
            .handle = vao
        };
    }

    pub fn bind(self: @This()) void {
        c.glBindVertexArray(self.handle);
        print("Bound vao: <{}> \n", self.handle);
        debug_gl.assertNoError();
    }
};

fn GLBuffer(comptime bufferType: var) type {
    return struct {
        handle: c.GLuint,

        const Self = @This();

        pub fn create() Self {
            var vbo: c.GLuint = undefined;
            c.glGenBuffers(1, &vbo);
            return Self {
                .handle = vbo
            };
        }

        pub fn bind(self: Self) void {
            c.glBindBuffer(bufferType, self.handle);
            print("Bound buffer: {} <{}> \n", @typeName(@typeOf(bufferType)), self.handle);
            debug_gl.assertNoError();
        }

        //TODO: Make sure we can only call this if the buffer is bound
        pub fn setData(self: Self, comptime T: type, data: []T) void {
            c.glBufferData(bufferType, @intCast(c_long, data.len * @sizeOf(@typeOf(data))), &data[0], c.GL_STATIC_DRAW);
            debug_gl.assertNoError();
        }
    };
}

fn glTypeForZigType(comptime T: type) comptime_int {
    return switch (T) {
        f16, f32, f64 => c.GL_FLOAT,
        i16, i32, i64 => c.GL_INT,
        else => { @compileError("Type not supported as vertex layout type: " ++ @typeName(T)); }
    };
}

fn glSizeForZigType(comptime T: type) i32 {
    return switch (T) {
        f16 => 2,
        f32 => 4,
        f64 => 8,
        else => { @compileError("Type not supported as vertex layout type"); }
    };
}

fn numberOfFieldsInStruct(s: builtin.Struct) u32 {
    return s.fields.len;
}

fn ensureAllFieldsHaveTheSameSize(comptime structInfo: builtin.TypeInfo.Struct) bool {
    if (structInfo.fields.len == 0) {
        return true;
    }

    comptime const firstFieldType = structInfo.fields[0].field_type;
    inline for (structInfo.fields) |field| {
        if (field.field_type != firstFieldType) {
            return false;
        }
    }
    return true;
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
            return Shape {
                .numComponents = s.fields.len,
                .childType = s.fields[0].field_type,
            };
        },
        .Array => |a| {
            return Shape {
                .numComponents = a.len,
                .childType = a.child(),
            };
        },
        .Float => |f| {
            return Shape {
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
            return Shape {
                .numComponents = 1,
                .childType = switch (f.bits) {
                    16 => i16,
                    32 => i32,
                    64 => i64,
                    else => unreachable,
                },
            };
        },
        else => @compileError("Unsupported type" ++ @typeName(T))
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

fn enableVertexAttrib(comptime position: i32, comptime stride: i32, comptime T: type) void {
    c.glEnableVertexAttribArray(0);

    const info = @typeInfo(T);

    switch (info) {
        .Struct => |s| {
            const name = @typeName(T);
            const shape = unwrapType(T);
            const glType = glTypeForZigType(shape.childType);

            print(
                "Vertex attrib: pos: {}, numComps: {}, childType: {}, stride: {}\n",
                position,
                shape.numComponents,
                @typeName(shape.childType),
                @intCast(i32, stride)
            );
            c.glVertexAttribPointer(
                position,
                shape.numComponents,
                glTypeForZigType(shape.childType),
                c.GL_FALSE,
                stride,
                null
            );
        },
        else => {
            @compileError("enableVertexAttrib expects a struct type describing the vertex layout.");
        }
    }


}

pub fn setVertexAttribLayout(comptime T: type) void {
    switch (@typeInfo(T)) {
        .Struct => | *info | {
            inline for (info.fields) |field, i| {
                print("Name: {} - {}\n", field.name, @typeName(field.field_type));
                enableVertexAttrib(i, @sizeOf(T), field.field_type);
            }
        },
        else => unreachable
    }
}

pub fn drawElements(len: c_int) void {
    c.glDrawElements(c.GL_TRIANGLES, len, c.GL_UNSIGNED_INT, null);
}

pub const ArrayBuffer = GLBuffer(c.GL_ARRAY_BUFFER);
pub const ElementArrayBuffer = GLBuffer(c.GL_ELEMENT_ARRAY_BUFFER);
