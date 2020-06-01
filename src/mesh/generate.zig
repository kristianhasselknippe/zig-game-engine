usingnamespace @import("../math.zig");
usingnamespace @import("../debug.zig");
const mesh = @import("../mesh.zig");
const Mesh = mesh.Mesh;
const Vertex = mesh.Vertex;
const Index = mesh.Index;
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const c_allocator = @import("std").heap.c_allocator;

const VertexList = ArrayList(Vertex);
const IndexList = ArrayList(Index);

pub const MeshBuilder = struct {
    allocator: *Allocator,
    vertices: VertexList,
    indices: IndexList,

    pub fn new_with_allocator(allocator: *Allocator) MeshBuilder {
        return MeshBuilder{
            .allocator = allocator,
            .vertices = VertexList.init(allocator),
            .indices = IndexList.init(allocator),
        };
    }

    pub fn new() MeshBuilder {
        return MeshBuilder.new_with_allocator(c_allocator);
    }

    pub fn display(self: @This(), tag: []const u8) void {
        debug_log("MeshBuilder: {} ", .{tag});
        for (self.vertices.items) |vert| {
            debug_log(" - Vertex: {}", .{vert});
        }
        for (self.indices.items) |index| {
            debug_log(" - Index: {}", .{index});
        }
    }

    pub fn scaled(self: *MeshBuilder, x: f32, y: f32, z: f32) *MeshBuilder {
        for (self.vertices.items) |vert, i| {
            self.vertices.items[i].pos = vert.pos.scale(vec3(x, y, z));
        }
        return self;
    }

    pub fn rotate(self: *MeshBuilder, angle: f32, axis: Vec3) *MeshBuilder {
        var rotMatrix = Mat4.rotate(angle, axis);

        for (self.vertices.items) |vert, i| {
            self.vertices.items[i].pos = vert.pos.applyMatrix(rotMatrix);
        }
        return self;
    }

    fn vertexMapper(in: Vertex) Vertex {
        debug_log("Mapping vert {}", .{in});
        return in;
    }

    fn uvMapper(in: UV) UV {
        debug_log("Mapping UV {}", .{in});
        return in;
    }

    pub fn combine(self: *MeshBuilder, other: *MeshBuilder) MeshBuilder {
        var ret = MeshBuilder.new();

        for (self.vertices.items) |vert| {
            ret.vertices.append(vert.copy()) catch unreachable;
        }
        for (other.vertices.items) |vert| {
            ret.vertices.append(vert.copy()) catch unreachable;
        }

        for (self.indices.items) |index| {
            ret.indices.append(index) catch unreachable;
        }
        for (other.indices.items) |index| {
            ret.indices.append(index + @intCast(u32, self.indices.items.len)) catch unreachable;
        }

        return ret;
    }

    pub fn build(self: *MeshBuilder) Mesh {
        return Mesh{
            .vertices = self.vertices.items,
            .indices = self.indices.items,
        };
    }

    pub fn rotated_around_x(self: *MeshBuilder, angle: f32) *MeshBuilder {
        return self.rotate(angle, vec3(1.0, 0.0, 0.0));
    }

    pub fn rotated_around_y(self: *MeshBuilder, angle: f32) *MeshBuilder {
        return self.rotate(angle, vec3(0.0, 1.0, 0.0));
    }

    pub fn rotated_around_z(self: *MeshBuilder, angle: f32) *MeshBuilder {
        return self.rotate(angle, vec3(0.0, 0.0, 1.0));
    }

    pub fn translated(self: *MeshBuilder, x: f32, y: f32, z: f32) *MeshBuilder {
        for (self.vertices.items) |vert, i| {
            self.vertices.items[i].pos = vec3(vert.pos.getX() + x, vert.pos.getY() + y, vert.pos.getZ() + z);
        }
        return self;
    }

    pub fn createTriangle() MeshBuilder {
        var self = MeshBuilder.new();

        self.vertices.append(Vertex.new(vec3(0.0, 0.0, 0.0), [2]f32{ 0.0, 0.0 })) catch unreachable;
        self.vertices.append(Vertex.new(vec3(1.0, 0.0, 0.0), [2]f32{ 1.0, 0.0 })) catch unreachable;
        self.vertices.append(Vertex.new(vec3(1.0, 1.0, 0.0), [2]f32{ 1.0, 1.0 })) catch unreachable;

        self.indices.append(0) catch unreachable;
        self.indices.append(1) catch unreachable;
        self.indices.append(2) catch unreachable;

        return self;
    }

    pub fn createSquare() MeshBuilder {
        var t2 = MeshBuilder.createTriangle().rotated_around_z(PI / 2.0).scaled(1.0, -1.0, 1.0);
        return MeshBuilder.createTriangle().combine(t2);
    }

    pub fn createBox() MeshBuilder {
        var front = MeshBuilder.createSquare();
        var back = MeshBuilder.createSquare().translated(0.0, 0.0, 1.0);
        var top = MeshBuilder.createSquare().rotated_around_x(-PI / 2.0);
        var bottom = MeshBuilder.createSquare().translated(0.0, 0.0, -1.0).rotated_around_x(-PI / 2.0);
        var left = MeshBuilder.createSquare().rotated_around_y(PI / 2.0).translated(1.0, 0.0, 0.0);
        var right = MeshBuilder.createSquare().rotated_around_y(PI / 2.0);
        return front.combine(back).combine(top).combine(bottom).combine(left).combine(right);
    }

    //  fn create_ring(color: *Option<Vec3>, resolution: u32) Mesh {
    //     let angle_per_segment = PI * 2.0 / (resolution as f32);
    //     let scale = 1.0 / resolution as f32;
    //     (0..resolution).fold(Self::create_square(color), |prev, curr| {
    //         let angle = angle_per_segment * curr as f32;
    //         println!("Angle: {}", angle);
    //         println!("   pos: {}, {}", angle.cos(), angle.sin());
    //         prev.combine(&Mesh::create_square(color).rotated_around_y(angle / 2.0).translated(angle.cos(), 1.0, angle.sin()))
    //     })
    // }
};

const assert = @import("std").debug.assert;

test "append" {
    var l = ArrayList(i32).init(c_allocator);
    assert(l.items.len == 0);
    try l.append(5);
    assert(l.items.len == 1);
    try l.append(4);
    try l.append(3);
    try l.append(2);
    assert(l.items.len == 4);
}

test "combine 1" {
    var t1 = MeshBuilder.createTriangle();
    var t2 = MeshBuilder.createTriangle();
    var combined = t1.combine(&t2);
    var combinedLength = t1.vertices.items.len + t2.vertices.items.len;
    debug_log("Combined length {}", .{combinedLength});
    assert(combined.vertices.items.len == combinedLength);

    for (t1.vertices.items) |vert, i| {
        assert(vert.equals(combined.vertices.items[i]));
    }
}
