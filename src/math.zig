use @import("./typeUtils.zig");
const assert = @import("std").debug.assert;

pub fn Vec2(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
    };
}

pub fn Vec3(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
        z: T,
    };
}

pub const VecType = struct {
    child: type,
    numComponents: i32,
};

pub const MatType = struct {
    child: type,
    size: i32,
};

pub const TrigTypeId = enum {
    Vec,
    Mat
};

pub const TrigType = union(TrigTypeId) {
    Vec: VecType,
    Mat: MatType,
};

pub fn trigType(comptime T: type) TrigType {
    switch (@typeInfo(T)) {
        .Struct => |s| {
            _ = ensureAllFieldsHaveTheSameSize(s);
            return TrigType {
                .Vec = VecType {
                    .child = f32,
                    .numComponents = 2,
                }
            };
        },
        .Array => |a| {
            const t = switch (a.len) {
                1,2,3,4 => TrigTypeId.Vec,
                else => TrigTypeId.Mat,
            };
        },
        else => @compileError("Unsupported trig type")
    }
}

test "trigTypeVec" {
    const vec = Vec3(f32) {
        .x = 30,
        .y = 20,
        .z = 10,
    };
    const res1 = trigType(@typeOf(vec));
    assert(res1 == TrigType.Vec);
}

test "trigTypeMat" {
    const mat = [4]f32 { 1, 2, 3, 4 };
    const res1 = trigType(@typeOf(mat));
    assert(res1 == TrigType.Mat);
}
