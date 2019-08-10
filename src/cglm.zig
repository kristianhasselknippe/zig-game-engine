const c = @import("c.zig");
const malloc = @import("std").c.malloc;
const print = @import("std").debug.warn;
const allocator = @import("std").heap.c_allocator;

pub fn perspective(fovy: f32, aspect: f32, nearVal: f32, farVal: f32) *c.mat4 {
    var out = @ptrCast(*c.mat4, @alignCast(16, (malloc(@sizeOf(c.mat4)))));
    c.glmc_perspective(fovy, aspect, nearVal, farVal, &out[0]);
    return out;
}
