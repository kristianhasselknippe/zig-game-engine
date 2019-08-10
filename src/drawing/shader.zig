const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");
const std = @import("std");
const allocator = std.heap.c_allocator;
const Mat4 = @import("../cglm.zig").Mat4;

pub fn createVertexShader(shaderData: [*]const u8) c.GLuint {
    const shader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(shader, 1, &shaderData, null);
    c.glCompileShader(shader);
    return shader;
}

pub fn createFragmentShader(shaderData: [*]const u8) c.GLuint {
    const shader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(shader, 1, &shaderData, null);
    c.glCompileShader(shader);
    return shader;
}

pub fn createDefaultShader() !c.GLuint {
    const vertexSourceString = @embedFile("../assets/shaders/default.vs");
    const vertexShaderSource = try std.cstr.addNullByte(allocator, &vertexSourceString);
    const vertexShader = createVertexShader(vertexShaderSource.ptr);
    try debug_gl.printShaderInfoLog(vertexShader);

    const fragmentShaderString = @embedFile("../assets/shaders/default.fs");
    const fragmentShaderSource = try std.cstr.addNullByte(allocator, &fragmentShaderString);
    const fragmentShader = createFragmentShader(fragmentShaderSource.ptr);
    try debug_gl.printShaderInfoLog(fragmentShader);

    var shaderProgram = c.glCreateProgram();

    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);

    try debug_gl.printProgramInfoLog(shaderProgram);

    debug_gl.assertNoError();

    c.glDeleteShader(vertexShader);
    c.glDeleteShader(fragmentShader);

    c.glUseProgram(shaderProgram);

    return shaderProgram;
}

pub fn getUniformLocation(program: c.GLuint, name: [*]const u8) c.GLint {
    return c.glGetUniformLocation(program, name);
}

pub fn setUniformMat4(program: c.GLuint, name: [*c]const u8, matrix: *Mat4) void {
    const loc = getUniformLocation(program, name);
    c.glProgramUniformMatrix4fv(program, @intCast(c.GLint, loc), 1, 0, @ptrCast([*c]const f32, matrix));
}
