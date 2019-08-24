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
        else => @compileError("Unsupported trig type")
    }
}

test "trigTypeTests" {
    const vec = Vec3(f32) {
        .x = 30,
        .y = 20,
        .z = 10,
    };
    const res1 = trigType(@typeOf(vec));
    assert(res1 == TrigType.Vec);
}
