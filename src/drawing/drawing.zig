const print = @import("std").debug.warn;
const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");

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

pub fn enableVertexAttrib() void {
    c.glEnableVertexAttribArray(0);
    c.glVertexAttribPointer(0, // attribute 0. No particular reason for 0, but must match the layout in the shader.
        3, // size
        c.GL_FLOAT, // type
        c.GL_FALSE, // normalized?
        0, // stride
        null // array buffer offset
    );
}

pub fn drawElements(len: c_int) void {
    c.glDrawElements(c.GL_TRIANGLES, len, c.GL_UNSIGNED_INT, null);
}

pub const ArrayBuffer = GLBuffer(c.GL_ARRAY_BUFFER);
pub const ElementArrayBuffer = GLBuffer(c.GL_ELEMENT_ARRAY_BUFFER);
