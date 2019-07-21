const std = @import("std");
const print = std.debug.warn;
const c = @import("c.zig");
const debug_gl = @import("debug_gl.zig");
const assets = @import("assets.zig");
const drawing = @import("drawing/drawing.zig");
const shader = @import("drawing/shader.zig");

const debug = std.debug.warn;
const panic = std.debug.panic;
const sleep = std.time.sleep;

var window: *c.GLFWwindow = undefined;
const window_width = 900;
const window_height = 600;

extern fn errorCallback(err: c_int, description: [*c]const u8) void {
    panic("Error: {}\n", description);
}

fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,
    };
}

fn Vec3(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        z: T,
    };
}

const TexCoord = Vec2(f32);

const Vertex = Vec3(f32);

var data = [_]Vertex{
        Vertex{ .x = -1.0, .y = -1.0, .z = 0.0 },
        Vertex{ .x = 1.0, .y = -1.0, .z = 0.0 },
        Vertex{ .x = 0.0, .y = 1.0, .z = 0.0 },
};

var indices = [_]c.GLuint{
    0, 1, 2,
};

pub fn init() void {

    var vao = drawing.VertexArray.create();
    vao.bind();

    const vbo = drawing.ArrayBuffer.create();
    vbo.bind();
    vbo.setData(Vertex, data[0..data.len]);

    const ebo = drawing.ElementArrayBuffer.create();
    ebo.bind();
    ebo.setData(c.GLuint, indices[0..indices.len]);
}

fn initGlOptions() void {
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 2);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);
    c.glfwWindowHint(c.GLFW_OPENGL_DEBUG_CONTEXT, debug_gl.is_on);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_DEPTH_BITS, 0);
    c.glfwWindowHint(c.GLFW_STENCIL_BITS, 8);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GL_FALSE);
    c.glfwWindowHint(c.GLFW_DOUBLEBUFFER, c.GL_TRUE);
}

const VertexAttribLayout = struct {
    pos: Vertex,
    texCoord: TexCoord
};

pub fn main() anyerror!void {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GL_FALSE) {
        panic("GLFW init failure\n");
    }
    defer c.glfwTerminate();

    initGlOptions();

    window = c.glfwCreateWindow(window_width, window_height, c"Game", null, null) orelse {
        panic("unable to create window\n");
    };

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);

    const start_time = c.glfwGetTime();
    var prev_time = start_time;

    init();
    var shouldQuit = false;

    const defaultShader = shader.createDefaultShader();

    assets.importSomething();

    drawing.setVertexAttribLayout(VertexAttribLayout);

    c.glClearColor(1.0, 0.0, 1.0, 1.0);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE and !shouldQuit) {
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT | c.GL_STENCIL_BUFFER_BIT);
        const quitKeyPressed = c.glfwGetKey(window, c.GLFW_KEY_Q);
        if (quitKeyPressed == c.GLFW_PRESS) {
            shouldQuit = true;
        }

        drawing.enableVertexAttrib();

        drawing.drawElements(indices.len);

        const now_time = c.glfwGetTime();
        const elapsed = now_time - prev_time;
        prev_time = now_time;

        c.glfwSwapBuffers(window);

        c.glfwPollEvents();

        sleep(10 * 1000 * 1000);
    }

    defer c.glfwDestroyWindow(window);
}
