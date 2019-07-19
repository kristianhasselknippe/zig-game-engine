const std = @import("std");
const c = @import("c.zig");
const debug_gl = @import("debug_gl.zig");

const debug = std.debug.warn;
const panic = std.debug.panic;
const sleep = std.time.sleep;

var window: *c.GLFWwindow = undefined;
const window_width = 900;
const window_height = 600;

extern fn errorCallback(err: c_int, description: [*c]const u8) void {
    panic("Error: {}\n", description);
}

fn Vec3(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        z: T
    };
}

const Vertex = Vec3(f32);

const data = [_]Vertex{
        Vertex { .x = -1.0, .y = -1.0, .z = 0.0 },
        Vertex { .x = 1.0, .y = -1.0, .z = 0.0 },
        Vertex { .x = 0.0, .y = 1.0, .z = 0.0 }
    };

    const indices = [_]c.GLuint {
        0,1,2,0,2,3
    };

pub fn init() void {

    var vao: c.GLuint = undefined;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    var vbo: c.GLuint = undefined;
    c.glGenBuffers(1, &vbo);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);

    c.glBufferData(c.GL_ARRAY_BUFFER, 4 * data.len, &data[0], c.GL_STATIC_DRAW);
    var ebo: c.GLuint = undefined;
    c.glGenBuffers(1, &ebo);
    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, ebo);
    c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER,  4 * indices.len, &indices[0], c.GL_STATIC_DRAW);
}

pub fn createVertexShader(shaderData: [*]const u8) void {
    const shader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(shader, 1, &shaderData, null);
    c.glCompileShader(shader);
}

pub fn createFragmentShader(shaderData: [*]const u8) void {
    const shader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(shader, 1, &shaderData, null);
    c.glCompileShader(shader);
}

pub fn draw() void {
    c.glDrawElements(c.GL_TRIANGLES, 3, c.GL_UNSIGNED_INT, &indices);
}

pub fn enableVertexAttrib() void {
    // 1st attribute buffer : vertices
    c.glEnableVertexAttribArray(0);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vertexbuffer);
    c.glVertexAttribPointer(
        0,                  // attribute 0. No particular reason for 0, but must match the layout in the shader.
        3,                  // size
        c.GL_FLOAT,           // type
        c.GL_FALSE,           // normalized?
        0,                  // stride
        0            // array buffer offset
    );
    // Draw the triangle !
    c.glDrawArrays(c.GL_TRIANGLES, 0, 3); // Starting from vertex 0; 3 vertices total -> 1 triangle
    c.glDisableVertexAttribArray(0);
}

pub fn main() anyerror!void {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GL_FALSE) {
        panic("GLFW init failure\n");
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 2);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);
    c.glfwWindowHint(c.GLFW_OPENGL_DEBUG_CONTEXT, debug_gl.is_on);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_DEPTH_BITS, 0);
    c.glfwWindowHint(c.GLFW_STENCIL_BITS, 8);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GL_FALSE);
    c.glfwWindowHint(c.GLFW_DOUBLEBUFFER, c.GL_TRUE);

    window = c.glfwCreateWindow(window_width, window_height, c"Game", null, null) orelse {
        panic("unable to create window\n");
    };

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);

    const start_time = c.glfwGetTime();
    var prev_time = start_time;

     init();
    var shouldQuit = false;

    const vertexShader =
        c\\#version 330 core
        c\\layout (location = 0) in vec3 aPos;
        c\\void main()
        c\\{
        c\\    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
        c\\}
    ;
    createVertexShader(vertexShader);

    const fragmentShader =
        c\\#version 330 core
        c\\out vec4 FragColor;
        c\\void main()
        c\\{
        c\\    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
        c\\}
    ;
    createFragmentShader(fragmentShader);

    c.glClearColor(1.0,0.0,1.0,1.0);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE and !shouldQuit) {

        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT | c.GL_STENCIL_BUFFER_BIT);
        const quitKeyPressed = c.glfwGetKey(window, c.GLFW_KEY_Q);
        if (quitKeyPressed == c.GLFW_PRESS) {
            shouldQuit = true;
        }

        draw();
        const now_time = c.glfwGetTime();
        const elapsed = now_time - prev_time;
        prev_time = now_time;

        //nextFrame(t, elapsed);

        //draw(t, @This());
        c.glColorMask(c.GL_TRUE, c.GL_TRUE, c.GL_TRUE, c.GL_TRUE);
        c.glDepthMask(c.GL_TRUE);
        c.glfwSwapBuffers(window);

        c.glfwPollEvents();

        sleep(10 * 1000 * 1000);
    }

    defer c.glfwDestroyWindow(window);
}
