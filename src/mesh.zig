const c = @import("c.zig");
const print = @import("std").debug.warn;
use @import("math.zig");
use @import("drawing/drawing.zig");

pub const TexCoord = Vec2(f32);

pub const Vertex = struct {
    position: Vec3(f32),
    uvCoord: Vec2(f32),
};

pub const Element = c.GLuint;

pub const Mesh = struct {
    const Self = @This();

    vertices: []Vertex,
    indices: []c.GLuint,

    vao: ?ArrayBuffer = null,
    ebo: ?ElementArrayBuffer = null,

    pub fn uploadData(self: Self) void {
        var this = self;
        this.vao = ArrayBuffer.create();
        this.vao.?.bind();
        this.vao.?.setData(Vertex, this.vertices);

        this.ebo = ElementArrayBuffer.create();
        this.ebo.?.bind();
        this.ebo.?.setData(Element, this.indices);
    }

    pub fn draw(self: Self) void {
        const numTriangles = @divFloor(@intCast(i32, self.indices.len), 3);
        print("Drawing triangles {}\n", numTriangles);
        drawElements(numTriangles);
    }
};
