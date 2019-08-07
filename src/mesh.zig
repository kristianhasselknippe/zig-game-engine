const c = @import("c.zig");
use @import("math.zig");

pub const TexCoord = Vec2(f32);

pub const Vertex = Vec3(f32);

fn Mesh(T: type) type {
    return struct {
        vertices: [*]Vertex,
        indices: [*]c.GLuint,
    };
}
