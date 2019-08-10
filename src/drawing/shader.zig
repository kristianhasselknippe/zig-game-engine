const c = @import("../c.zig");
const debug_gl = @import("../debug_gl.zig");
const std = @import("std");
const allocator = std.heap.c_allocator;
const Mat4 = @import("../cglm.zig").Mat4;

const Shader = struct {
    handle: c.GLuint,

    pub fn init(handle: c.GLuint) @This() {
        return @This() {
            .handle = handle
        };
    }

    pub fn printShaderInfoLog(shader: Shader, ) !void {
        var infologLength: c_int = 0;
        var charsWritten: c_int = 0;

        c.glGetShaderiv(shader.handle, c.GL_INFO_LOG_LENGTH, &infologLength);

        if (infologLength > 0) {
            var infoLog = try allocator.alloc(u8, @intCast(usize, infologLength));
            c.glGetShaderInfoLog(shader.handle, infologLength, &charsWritten, @ptrCast([*c]u8, &infoLog[0]));
            std.debug.warn("Shader error\n");
            std.debug.warn("{}\n", infoLog);
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

        return @This() {
            .handle = shaderProgram
        };
    }
};

pub fn createDefaultShader() !ShaderProgram {
    const vertexSourceString = @embedFile("../assets/shaders/default.vs");
    const vertexShaderSource = try std.cstr.addNullByte(allocator, &vertexSourceString);
    const vertexShader = createVertexShader(vertexShaderSource.ptr);
    try vertexShader.printShaderInfoLog();

    const fragmentShaderString = @embedFile("../assets/shaders/default.fs");
    const fragmentShaderSource = try std.cstr.addNullByte(allocator, &fragmentShaderString);
    const fragmentShader = createFragmentShader(fragmentShaderSource.ptr);
    try fragmentShader.printShaderInfoLog();
    return ShaderProgram.init(vertexShader, fragmentShader);
}

pub fn getUniformLocation(program: ShaderProgram, name: [*]const u8) c.GLint {
    return c.glGetUniformLocation(program.handle, name);
}

pub fn setUniformMat4(program: ShaderProgram, name: [*c]const u8, matrix: *Mat4) void {
    const loc = getUniformLocation(program, name);
    c.glProgramUniformMatrix4fv(program.handle, @intCast(c.GLint, loc), 1, 0, @ptrCast([*c]const f32, matrix));
}
