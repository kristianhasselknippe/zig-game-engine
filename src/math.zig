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
