const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");
const std = @import("std");
const allocator = std.heap.c_allocator;
usingnamespace @import("../math.zig");

const Shader = struct {
    handle: c.GLuint,

    pub fn init(handle: c.GLuint) @This() {
        return @This(){ .handle = handle };
    }

    pub fn printShaderInfoLog(
        shader: Shader,
    ) !void {
        var infologLength: c_int = 0;
        var charsWritten: c_int = 0;

        c.glGetShaderiv(shader.handle, c.GL_INFO_LOG_LENGTH, &infologLength);

        if (infologLength > 0) {
            var infoLog = try allocator.alloc(u8, @intCast(usize, infologLength));
            c.glGetShaderInfoLog(shader.handle, infologLength, &charsWritten, @ptrCast([*c]u8, &infoLog[0]));
            std.debug.warn("Shader error\n", .{});
            std.debug.warn("{}\n", .{infoLog});
            allocator.free(infoLog);
        }
    }
};

pub fn createVertexShader(shaderData: [*]const u8) Shader {
    const shader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(shader, 1, &shaderData, null);
    c.glCompileShader(shader);
    return Shader.init(shader);
}

pub fn createFragmentShader(shaderData: [*]const u8) Shader {
    const shader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(shader, 1, &shaderData, null);
    c.glCompileShader(shader);
    return Shader.init(shader);
}

const ShaderProgram = struct {
    handle: c.GLuint,

    pub fn init(vertex: Shader, fragment: Shader) !ShaderProgram {
        var shaderProgram = c.glCreateProgram();

        c.glAttachShader(shaderProgram, vertex.handle);
        c.glAttachShader(shaderProgram, fragment.handle);
        c.glLinkProgram(shaderProgram);

        try debug_gl.printProgramInfoLog(shaderProgram);

        debug_gl.assertNoError();

        // TODO: Delete the shaders?
        //c.glDeleteShader(vertexShader);
        //c.glDeleteShader(fragmentShader);

        c.glUseProgram(shaderProgram);

        return @This(){ .handle = shaderProgram };
    }

    pub fn getUniformLocation(program: ShaderProgram, name: [*]const u8) c.GLint {
        return c.glGetUniformLocation(program.handle, name);
    }

    fn setUniformInternal(program: ShaderProgram, name: [*c]const u8, comptime uniformType: UniformTypeId, comptime primitive: UniformPrimitive, val: var) void { // TODO: Add an error set
        const loc = getUniformLocation(program, name);
        switch (uniformType) {
            .Scalar => {
                switch (primitive) {
                    .Float => c.glProgramUniform1f(program.handle, @intCast(c.GLint, loc), val),
                    .Int => c.glProgramUniform1i(program.handle, @intCast(c.GLint, loc), val),
                }
            },
            .Vec2 => {
                switch (primitive) {
                    .Float => c.glProgramUniform2f(program.handle, @intCast(c.GLint, loc), val),
                    .Int => c.glProgramUniform2i(program.handle, @intCast(c.GLint, loc), val),
                }
            },
            .Vec3 => {
                switch (primitive) {
                    .Float => c.glProgramUniform3f(program.handle, @intCast(c.GLint, loc), val),
                    .Int => c.glProgramUniform3i(program.handle, @intCast(c.GLint, loc), val),
                }
            },
            .Vec4 => {
                switch (primitive) {
                    .Float => c.glProgramUniform4f(program.handle, @intCast(c.GLint, loc), val),
                    .Int => c.glProgramUniform4i(program.handle, @intCast(c.GLint, loc), val),
                }
            },
            .Mat2x2 => {
                switch (primitive) {
                    .Float => c.glProgramUniformMatrix2fv(program.handle, @intCast(c.GLint, loc), 1, c.GL_FALSE, val),
                    .Int => @compileError("Matrix uniforms only support floats"),
                }
            },
            .Mat3x3 => {
                switch (primitive) {
                    .Float => c.glProgramUniformMatrix3fv(program.handle, @intCast(c.GLint, loc), 1, c.GL_FALSE, val),
                    .Int => @compileError("Matrix uniforms only support floats"),
                }
            },
            .Mat4x4 => {
                switch (primitive) {
                    .Float => c.glProgramUniformMatrix4fv(program.handle, @intCast(c.GLint, loc), 1, c.GL_FALSE, val),
                    .Int => @compileError("Matrix uniforms only support floats"),
                }
            },
        }
    }

    pub fn setUniform(program: ShaderProgram, name: [*c]const u8, val: var) void {
        switch (@TypeOf(val)) {
            Mat4 => setUniformInternal(program, name, UniformTypeId.Mat4x4, UniformPrimitive.Float, val.data[0][0..]),
            f32 => setUniformInternal(program, name, UniformTypeId.Scalar, UniformPrimitive.Float, val),
            else => @compileError("Unsupported uniform type " ++ @typeName(@TypeOf(val))),
        }
    }
};

pub const UniformTypeId = enum {
    Scalar,
    Vec2,
    Vec3,
    Vec4,
    Mat2x2,
    Mat3x3,
    Mat4x4,
};

pub const UniformPrimitive = enum {
    Float, Int
};

pub fn createDefaultShader() !ShaderProgram {
    const vertexShaderSource = @embedFile("../assets/shaders/default.vs");
    //const vertexShaderSource = try std.cstr.addNullByte(allocator, &vertexSourceString);
    const vertexShader = createVertexShader(vertexShaderSource);
    try vertexShader.printShaderInfoLog();

    const fragmentShaderSource = @embedFile("../assets/shaders/default.fs");
    //const fragmentShaderSource = try std.cstr.addNullByte(allocator, &fragmentShaderString);
    const fragmentShader = createFragmentShader(fragmentShaderSource);
    try fragmentShader.printShaderInfoLog();
    return ShaderProgram.init(vertexShader, fragmentShader);
}
