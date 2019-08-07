const c = @import("c.zig");
const print = @import("std").debug.warn;

pub fn mat4_identity() c.mat4 {
    var out = c.GLM_MAT4_IDENTITY_INIT;
    c.glmc_mat4_identity(&out);
    return out;
}

pub fn perspective(fovy: f32, aspect: f32, nearVal: f32, farVal: f32) c.mat4 {
    var out: c.mat4 = [4][4]f32{
        [4]f32{ 1.0, 0.0, 0.0, 0.0},
        [4]f32{ 0.0, 1.0, 0.0, 0.0},
        [4]f32{ 0.0, 0.0, 1.0, 0.0},
        [4]f32{ 0.0, 0.0, 0.0, 1.0}
    };
    print("Hei {} {}\n", out[0][0], out[1][0]);
    need to align the data
    c.glmc_perspective(fovy, aspect, nearVal, farVal, &out);
    print("test");
    print("Foobar {}\n", out);
    return out;
}
