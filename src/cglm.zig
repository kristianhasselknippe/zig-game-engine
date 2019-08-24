const c = @import("c.zig");
const malloc = @import("std").c.malloc;
const std = @import("std");
const print = std.debug.warn;
const allocator = std.heap.c_allocator;
const assert = std.debug.assert;
use @import("math.zig");

pub const Mat4 = [4][4]f32;

pub fn printMat4(input: Mat4) void {
    for (input) |row| {
        for (row) |item| {
            print("{},", item);
        }
        print("\n");
    }
}

pub fn allocMat4() *Mat4 {
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
    c.glmc_perspective(fovy, aspect, nearVal, farVal, &out[0]);
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

pub fn translation(by: Vec3(f32)) *Mat4 {
    const out = allocMat4();
    out[0][3] += by.x;
    out[1][3] += by.y;
    out[2][3] += by.z;

    out[0][0] = 1;
    out[1][1] = 1;
    out[2][2] = 1;
    out[3][3] = 1;
    return out;
}

pub fn translate(mat: *Mat4, by: Vec3(f32)) *Mat4 {
    mat[0][3] += by.x;
    mat[1][3] += by.y;
    mat[2][3] += by.z;
    return mat;
}

//  pub fn mul(a: *Mat4, b: *Mat4) *Mat4 {
//     var out = allocMat4();
//     c.glmc_mat4_mul(a,b,out);
//     return out;
// }

pub fn mul(a: *Mat4, b: *Mat4) *Mat4 {
    const res = allocMat4();
    var i: usize = 0;
    while (i < a.len):(i+=1) {
        var j: usize = 0;
        while (j < a.len):(j+=1) {
            var k: usize = 0;
            while (k < a.len):(k+=1) {
                res[i][j] += a[i][k] * b[k][j];
            }
        }
    }
    return res;
}

test "cglm.euler" {
    const foo = euler(150, 0, 0);
    print("\nEuler\n");
    printMat4(foo.*);
}

test "cglm.translation" {
    var vec = Vec3(f32) {
        .x = 10,
        .y = 5,
        .z = 2
    };
    const foo = translation(vec);
    print("\nTranslation\n");
    printMat4(foo.*);
    assert(foo[3][0] == 10);
    assert(foo[3][1] == 5);
    assert(foo[3][2] == 2);
    
}

test "cglm.translate" {
    var mat = allocMat4();
    var vec = Vec3(f32) {
        .x = 10,
        .y = 5,
        .z = 2
    };
    const foo = translate(mat, vec);
    assert(foo[3][0] == 10);
    assert(foo[3][1] == 5);
    assert(foo[3][2] == 2);
}

test "mat4_mul" {
    const m1 = allocMat4();
    const m2 = allocMat4();
    m1[0][0] = 5;
    m1[1][1] = 2;
    m1[0][3] = 10;
    m2[0][0] = 3;
    m2[1][1] = 2;
    m2[2][1] = 2;
    const out = mul(m1, m2);

    print("\n");
    printMat4(out.*);
    assert(out[0][0] == 15);
    assert(out[1][1] == 4);
    assert(out[2][1] == 4);
    assert(out[0][3] == 30);
}

test "cglm.translateBy" {
    var vec = Vec3(f32) {
        .x = 10,
        .y = 5,
        .z = 2
    };
    var orig = translation(vec);
    const foo = translate(orig, vec);
    assert(foo[3][0] == 20);
    assert(foo[3][1] == 10);
    assert(foo[3][2] == 4);
}
