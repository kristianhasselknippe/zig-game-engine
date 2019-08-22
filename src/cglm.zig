const c = @import("c.zig");
const malloc = @import("std").c.malloc;
const print = @import("std").debug.warn;
const allocator = @import("std").heap.c_allocator;
use @import("math.zig");

pub const Mat4 = c.mat4;

pub fn printMat4(input: Mat4) void {
    for (input) |row| {
        for (row) |item| {
            print("{},", item);
        }
        print("\n");
    }
}

fn allocMat4() *Mat4 {
    const ret = allocator.alloc(Mat4, 1) catch @panic("Error allocating");
    var x: usize = 0;
    while (x < 4) : (x += 1) {
        var y: usize = 0;
        while (y < 4) : (y += 1) {
            ret[0][x][y] = 0;
        }
    }
    return &ret[0];
}

pub fn perspective(fovy: f32, aspect: f32, nearVal: f32, farVal: f32) *Mat4 {
    var out = allocMat4();

    print("Before init \n");
    printMat4(out.*);
    
    print("After init \n");

    c.glmc_perspective(fovy, aspect, nearVal, farVal, &out[0]);
    print("After glmc perspective \n");
    printMat4(out.*);
    return out;
}

pub fn euler(pitch: f32, yaw: f32, roll: f32) *Mat4 {
    var out = allocMat4();
    var rot = Vec3(f32) {
        .x = pitch,
        .y = yaw,
        .z = roll
    };
    c.glmc_euler(
        @ptrCast([*c]f32, &rot),
        &out[0]
    );
    return out;

}
