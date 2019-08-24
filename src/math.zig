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

        pub fn create(x: T, y: T, z: T) @This() {
            return @This() {
                .x = x,
                .y = y,
                .z = z,
            };
        }
    };
}
