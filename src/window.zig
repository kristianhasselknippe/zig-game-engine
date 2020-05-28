const c = @import("c.zig");

pub const Window = struct {
    window_handle: *c.GLFWwindow,

    pub fn new(width: i32, height: i32) @This() {
        c.glfwWindowHint(c.GLFW_SAMPLES, 4);
        const window_handle = c.glfwCreateWindow(width, height, "Game", null, null) orelse {
            @panic("unable to create window\n");
        };
        c.glEnable(c.GL_MULTISAMPLE);
        return @This(){ .window_handle = window_handle };
    }

    pub fn makeContextCurrent(self: @This()) void {
        c.glfwMakeContextCurrent(self.window_handle);
    }

    pub fn shouldClose(self: @This()) bool {
        return c.glfwWindowShouldClose(self.window_handle) == c.GL_TRUE;
    }

    pub fn getQuitKeyPress(self: @This()) i32 {
        return c.glfwGetKey(self.window_handle, c.GLFW_KEY_Q);
    }

    pub fn getKeyPress(self: @This(), key_code: i32) bool {
        var state = c.glfwGetKey(self.window_handle, key_code);
        return state == GLFW_PRESS;
    }

    pub fn getWindowSize(self: @This()) struct { width: u32, height: u32 } {
        var width: c_int = 0;
        var height: c_int = 0;
        c.glfwGetWindowSize(self.window_handle, &width, &height);
        return .{
            .width = @intCast(u32, width),
            .height = @intCast(u32, height),
        };
    }

    pub fn swapBuffers(self: @This()) void {
        c.glfwSwapBuffers(self.window_handle);
    }

    pub fn destroy(self: @This()) void {
        c.glfwDestroyWindow(self.window_handle);
    }
};
