const c = @import("c.zig");
const malloc = @import("std").c.malloc;
const print = @import("std").debug.warn;
const allocator = @import("std").heap.c_allocator;

pub const Mat4 = c.mat4;

pub fn printMat4(input: Mat4) void {
    for (input) |row| {
        for (row) |item| {
            print("{},", item);
        }
        print("\n");
    }
}

pub fn perspective(fovy: f32, aspect: f32, nearVal: f32, farVal: f32) *Mat4 {
    var out = allocator.alloc(Mat4, 1) catch @panic("Error allocating");

    print("Before init \n");
    printMat4(out[0]);
    var x: usize = 0;
    while (x < 4) : (x += 1) {
        var y: usize = 0;
        while (y < 4) : (y += 1) {
            out[0][x][y] = 0;
        }
    }
    print("After init \n");

    c.glmc_perspective(fovy, aspect, nearVal, farVal, &out[0]);
    print("After glmc perspective \n");
    printMat4(out[0]);
    return &out[0];
}

test "perspective" {
    
}
