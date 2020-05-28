usingnamespace @import("image.zig");
usingnamespace @import("math.zig");
usingnamespace @import("math/vec.zig");
usingnamespace @import("mesh.zig");
usingnamespace @import("mesh/generate.zig");
usingnamespace @import("drawing/gl.zig");
usingnamespace @import("debug_gl.zig");

const std = @import("std");
const print = std.debug.warn;
const c = @import("c.zig");
const fabs = std.math.fabs;
const debug_gl = @import("debug_gl.zig");
const assets = @import("assets.zig");
const Shader = @import("drawing/shader.zig");
const panic = std.debug.panic;
const debug = std.debug.warn;
const sleep = std.time.sleep;
const Drawing = @import("drawing/drawing.zig");
const c_allocator = @import("std").heap.c_allocator;

var window: *c.GLFWwindow = undefined;
const window_width = 900;
const window_height = 600;

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {}\n", .{description});
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

fn getWindowSize() struct { width: u32, height: u32 } {
    var width: c_int = 0;
    var height: c_int = 0;
    c.glfwGetWindowSize(window, &width, &height);
    return .{
        .width = @intCast(u32, width),
        .height = @intCast(u32, height),
    };
}

pub fn main() anyerror!void {
    _ = c.glfwSetErrorCallback(errorCallback);

    const dc = Drawing.DrawContext{};

    dc.draw();

    if (c.glfwInit() == c.GL_FALSE) {
        @panic("GLFW init failure\n");
    }
    defer c.glfwTerminate();

    initGlOptions();

    window = c.glfwCreateWindow(window_width, window_height, "Game", null, null) orelse {
        @panic("unable to create window\n");
    };

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);

    c.glEnable(c.GL_DEPTH_TEST);
    c.glDepthFunc(c.GL_LESS);

    c.glDisable(c.GL_CULL_FACE);

    //c.glEnable(c.GL_CULL_FACE);
    //c.glCullFace(c.GL_FRONT);

    const start_time = c.glfwGetTime();
    var prev_time = start_time;

    var shouldQuit = false;

    const shader = Shader.createDefaultShader() catch @panic("Unable to create default shader");
    const projection = Mat4.perspective(1.0, 1, 0.1, 1000);
    //TODO: Make sure we free the perspective matrix

    var yaw: f32 = 0.0;
    var roll: f32 = 0.0;
    var zoom: f32 = 0.0;

    // print("Mesh: {}  \n", .{ mesh });
    // for (mesh.vertices) |vert| {
    //     print("   vert: {},{},{}\n", .{vert.getX(), vert.getY(), vert.getZ()});
    // }
    // for (mesh.indices) |index| {
    //     print("   index: {}\n", .{ index });
    // }

    const vao = VertexArray.create();
    vao.bind();
    vao.enable();

    assertNoError();

    var vertex_buffer = ArrayBuffer.create();
    vertex_buffer.bind();
    var ebo = ElementArrayBuffer.create();
    ebo.bind();

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 0, null);

    assertNoError();

    c.glClearColor(1.0, 1.0, 0.5, 1.0);

    const theImage = PngImage.create(@embedFile("./assets/testimg.png"));
    print("We have loaded an image \n", .{});

    var x: f32 = 0.0;
    var acc: f32 = 0.0;

    var windowSize = getWindowSize();

    c.glViewport(0, 0, @intCast(c_int, windowSize.width), @intCast(c_int, windowSize.height));

    var mesh = MeshBuilder.new(c_allocator).create_triangle().rotate(3.14, &vec3(0.0, 0.0, 1.0)).combine(MeshBuilder.new(c_allocator).create_triangle()).translated(1.5 * x, 0.5, 0).build();

    vertex_buffer.setData(Vertex, mesh.vertices);
    ebo.setData(Index, mesh.indices);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE and !shouldQuit) {
        x = @cos(acc);
        acc += 0.01;

        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT | c.GL_STENCIL_BUFFER_BIT);
        const quitKeyPressed = c.glfwGetKey(window, c.GLFW_KEY_Q);
        if (quitKeyPressed == c.GLFW_PRESS) {
            shouldQuit = true;
        }

        var translation_matrix = Mat4.translation(0.5 * x, 0.0, 0.0);
        translation_matrix.display();
        shader.setUniform("view", translation_matrix);

        drawElements(@intCast(c_int, mesh.indices.len));

        const now_time = c.glfwGetTime();
        const elapsed = now_time - prev_time;
        prev_time = now_time;

        c.glfwSwapBuffers(window);

        c.glfwPollEvents();

        sleep(10 * 1000 * 1000);
    }

    defer c.glfwDestroyWindow(window);
}
