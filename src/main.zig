const PngImage = @import("image.zig").PngImage;
const debug_log = @import("debug.zig").debug_log;
const std = @import("std");
const math = std.math;
const c = @import("c.zig");
const Mat4 = @import("math/mat.zig").Mat4;
const debug_gl = @import("debug_gl.zig");
const assets = @import("assets.zig");
const Shader = @import("drawing/shader.zig");
const panic = std.debug.panic;
const debug = std.debug.warn;
const sleep = std.time.sleep;
const c_allocator = @import("std").heap.c_allocator;
const Window = @import("window.zig").Window;
const gl = @import("drawing/gl.zig");
const Vertex = @import("mesh.zig").Vertex;
const Index = @import("mesh.zig").Index;
const MeshBuilder = @import("mesh/generate.zig").MeshBuilder;
const World = @import("ecs.zig").World;
const vec = @import("math/vec.zig");
const vec3 = vec.vec3;

var window: Window = undefined;
const window_width = 900;
const window_height = 600;

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {any}\n", .{description});
}

fn initGlOptions() void {
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 2);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);
    c.glfwWindowHint(c.GLFW_OPENGL_DEBUG_CONTEXT, debug_gl.is_on);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_DEPTH_BITS, 8);
    c.glfwWindowHint(c.GLFW_STENCIL_BITS, 8);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GL_TRUE);
    c.glfwWindowHint(c.GLFW_DOUBLEBUFFER, c.GL_TRUE);
}

pub fn main() anyerror!void {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GL_FALSE) {
        @panic("GLFW init failure\n");
    }
    defer c.glfwTerminate();

    initGlOptions();

    window = Window.new(window_width, window_height);
    defer window.destroy();

    window.makeContextCurrent();

    c.glfwSwapInterval(1);

    c.glEnable(c.GL_DEPTH_TEST);
    c.glDepthFunc(c.GL_LESS);
    c.glDisable(c.GL_CULL_FACE);

    const start_time = c.glfwGetTime();
    var prev_time = start_time;

    var shouldQuit = false;

    var foo = .{
        2, 2, 3,
    };

    const shader = Shader.createDefaultShader() catch @panic("Unable to create default shader");
    const projection = Mat4.perspective(1.0, 1, 0.1, 1000);

    const vao = gl.VertexArray.create();
    vao.bind();
    vao.enable();

    debug_gl.assertNoError();

    var vertex_buffer = gl.ArrayBuffer.create();
    vertex_buffer.bind();
    var ebo = gl.ElementArrayBuffer.create();
    ebo.bind();

    var offsetToUV = @intToPtr(*const c_void, @byteOffsetOf(Vertex, "uv"));
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, @sizeOf(Vertex), null);
    c.glEnableVertexAttribArray(0);
    c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, @sizeOf(Vertex), offsetToUV);
    c.glEnableVertexAttribArray(1);

    debug_gl.assertNoError();

    c.glClearColor(1.0, 1.0, 0.5, 1.0);

    const theImage = PngImage.create(@embedFile("./assets/testimg.png"));
    debug_log("We have loaded an image ", .{});

    var x: f32 = 0.0;
    var acc: f32 = 0.0;

    var windowSize = window.getWindowSize();

    c.glViewport(0, 0, @intCast(c_int, windowSize.width), @intCast(c_int, windowSize.height));

    var mesh = MeshBuilder.createBox().build();
    mesh.print();

    debug_log("Size of f32: {}", .{@sizeOf(f32)});
    debug_log("Size ofvertex: {}", .{@sizeOf(Vertex)});

    vertex_buffer.setData(Vertex, mesh.vertices);
    ebo.setData(Index, mesh.indices);

    //var world = World.new();

    var z_pos: f32 = -1;
    while (!window.shouldClose() and !shouldQuit) {
        x = @cos(acc);
        acc += 0.01;

        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT | c.GL_STENCIL_BUFFER_BIT);
        const quitKeyPressed = window.getQuitKeyPress();
        if (quitKeyPressed == c.GLFW_PRESS) {
            shouldQuit = true;
        }

        z_pos = @cos(acc) * 2;

        var projection_matrix = Mat4.perspective(60.0, 1.0, 0.1, 1000.0);
        var view_matrix = Mat4.translation(0.5, 0.0, -2);
        var model_matrix = Mat4.rotate(z_pos, vec3(1.0, z_pos, 0.0)).mult(Mat4.translation(0.0, 0.0, 0.0));
        shader.setUniform("projection", projection_matrix);
        shader.setUniform("view", view_matrix);
        shader.setUniform("model", model_matrix);

        gl.drawElements(@intCast(c_int, mesh.indices.len));

        const now_time = c.glfwGetTime();
        const elapsed = now_time - prev_time;
        prev_time = now_time;

        window.swapBuffers();

        c.glfwPollEvents();

        sleep(10 * 1000 * 1000);
    }
}
