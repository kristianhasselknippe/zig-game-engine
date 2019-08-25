const c = @import("c.zig");
const print = @import("std").debug.warn;
use @import("math.zig");
use @import("drawing/drawing.zig");

pub const TexCoord = Vec2(f32);

pub const Vertex = struct {
    position: Vec3,
    uvCoord: Vec2,
};

// TODO: Made ^^ work instead of needing this
const VertexLayout = struct {
    position: struct {
        x: f32,
        y: f32,
        z: f32,
    },
    uvCoord: struct {
        u: f32,
        v: f32,
    },
};

pub const Element = c.GLuint;

pub const Mesh = struct {
    const Self = @This();

    vertices: []Vertex,
    indices: []c.GLuint,

    vao: ?ArrayBuffer = null,
    ebo: ?ElementArrayBuffer = null,

    pub fn bind(self: *Self) void {
        var this = self;
        this.vao.?.bind();
        this.ebo.?.bind();
    }

    pub fn uploadData(self: *Self) void {
        var this = self;
        this.vao = ArrayBuffer.create();
        this.vao.?.bind();
        this.vao.?.setData(Vertex, this.vertices);

        this.ebo = ElementArrayBuffer.create();
        this.ebo.?.bind();
        this.ebo.?.setData(Element, this.indices);
    }

    pub fn draw(self: *Self, comptime vertexLayout: type) void {
        var this = self;
        const numTriangles = @divFloor(@intCast(i32, self.indices.len), 3);
        this.bind();
        setVertexAttribLayout(VertexLayout);
        drawElements(numTriangles);
    }
};
