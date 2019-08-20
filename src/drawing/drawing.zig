const print = @import("std").debug.warn;
const fmt = @import("std").fmt;
const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");
const builtin = @import("builtin");

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

fn glTypeForZigType(comptime T: type) type {
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

fn structFieldToVertexAttribComp(pos: i32, comptime field: type, stride: i32) void {
    const size = glSizeForZigType(field);
    const glType = glTypeForZigType(field);
    c.glVertexAttribPointer(pos, // attribute 0. No particular reason for 0, but must match the layout in the shader.
                            size,
                            glType,
                            c.GL_FALSE, // normalized?
                            stride, // stride
                            ull // array buffer offset
                            );
}

const Shape = struct {
    numComponents: usize,
    sizePerComponent: usize,
};

fn ensureAllFieldsHaveTheSameSize(structInfo: builtin.Struct) bool {
    if (structInfo.len() == 0) {
        return true;
    }

    firstFieldType = structInfo.fields[0].field_type;
    for (structInfo.fields) |field| {
        if (field.field_type != firstFieldType) {
            return false
        }
    }
    return true
}

fn unwrapType(comptime T: type) type {
    switch (t) {
        .Struct => |s| {
            if (!ensureAllFieldsHaveTheSameSize(s)) {
                @compileError("Expected all fields of a vertex attribute struct to have the same size."); //TODO: remove this requirement if possible
            }
            return Shape {
                .numComponents = s.fields.len(),
                .sizePerComponent = s.fields.
            }
        },
        .Array => |a| {
            return Shape {
                .numComponents = a.len(),
                .sizePerComponent = a.child()
            };
        },
        .Float => |f| {},
        .Int => |i| {}, 
    }
}

pub fn enableVertexAttrib(comptime T: type) void {
    c.glEnableVertexAttribArray(0);

    const info = @typeInfo(T);

    switch (info) {
        .Struct => |s| {
            comptime var position = 0;
            const stride = @sizeOf(T);
            inline for (s.fields) |field| {
                print("Struct field({}): {} with stride {}", @intCast(i32, position), field.name, @intCast(i32, stride));
                structFieldToVertexAttribComp(position, field.field_type, stride);
                //c.glVertexAttribPointer(position, // attribute 0. No particular reason for 0, but must match the layout in the shader.
                //                        3, // size
                //                        glTypeForZigType(field.field_type), // type
                //                        c.GL_FALSE, // normalized?
                //                        0, // stride
                //                        null // array buffer offset
                //                        );
                position += 1;
            }
        },
        else => {
            @compileError("enableVertexAttrib expects a struct type describing the vertex layout.");
        }
    }
    
    
}

pub fn setVertexAttribLayout(comptime T: type) void {
    switch (@typeInfo(T)) {
        .Struct => | *info | {
            inline for (info.fields) |field| {
                print("Name: {} - {}\n", field.name, @typeName(field.field_type));
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
