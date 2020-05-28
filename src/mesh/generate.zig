usingnamespace @import("../math.zig");
const mesh = @import("../mesh.zig");
const Mesh = mesh.Mesh;
const Vertex = mesh.Vertex;
const Index = mesh.Index;
const std = @import("std");
const Allocator = std.mem.Allocator;
const debug = std.debug.warn;

pub fn SimpleList(comptime T: type) type {
    return struct {
        allocator: *Allocator,
        data: []T,

        pub fn new(allocator: *Allocator) !@This() {
            var initialData = try allocator.alloc(T, 0);
            return @This(){
                .data = initialData,
                .allocator = allocator,
            };
        }

        pub fn free(self: *@This(), allocator: *Allocator) void {
            allocator.free(self.data);
        }

        pub fn extend(self: *@This(), num: usize) !void {
            self.data = try self.allocator.realloc(self.data, num + self.data.len);
        }
    };
}

const VertexList = SimpleList(Vertex);
const IndexList = SimpleList(Index);

pub const MeshBuilder = struct {
    allocator: *Allocator,
    vertices: VertexList,
    indices: IndexList,

    pub fn new(allocator: *Allocator) MeshBuilder {
        return MeshBuilder{
            .allocator = allocator,
            .vertices = VertexList.new(allocator) catch unreachable,
            .indices = IndexList.new(allocator) catch unreachable,
        };
    }

    pub fn scaled(self: *MeshBuilder, x: f32, y: f32, z: f32) *MeshBuilder {
        for (self.vertices.data) |vert, i| {
            self.vertices.data[i] = vert.scale(vec3(x, y, z));
        }
        return self;
    }

    pub fn rotate(self: *MeshBuilder, angle: f32, axis: *Vec3) *MeshBuilder {
        var rotMatrix = Mat4.rotate(angle, axis.*);
        for (self.vertices.data) |vert, i| {
            self.vertices.data[i] = vert.applyMatrix(rotMatrix);
        }
        return self;
    }

    pub fn createTriangle(self: *MeshBuilder) *MeshBuilder {
        self.vertices.extend(3) catch unreachable;
        self.vertices.data[0] = vec3(0.0, 0.0, 0.0);
        self.vertices.data[1] = vec3(1.0, 0.0, 0.0);
        self.vertices.data[2] = vec3(1.0, 1.0, 0.0);

        self.indices.extend(3) catch unreachable;
        self.indices.data[0] = 0;
        self.indices.data[1] = 1;
        self.indices.data[2] = 2;

        return self;
    }

    pub fn combine(self: *MeshBuilder, other: *MeshBuilder) *MeshBuilder {
        const index_len = @intCast(Index, self.indices.data.len);
        self.vertices.extend(other.vertices.data.len) catch unreachable;
        for (self.vertices.data) |vert, i| {
            self.vertices.data[i] = vert;
        }
        for (other.vertices.data) |vert, i| {
            self.vertices.data[i + other.vertices.data.len] = vert;
        }

        self.indices.extend(other.indices.data.len) catch unreachable;
        for (self.indices.data) |index, i| {
            self.indices.data[i] = index;
        }
        for (other.indices.data) |index, i| {
            self.indices.data[i + other.indices.data.len] = index + index_len;
        }

        return self;
    }

    pub fn build(self: *MeshBuilder) Mesh {
        return Mesh{
            .vertices = self.vertices.data,
            .indices = self.indices.data,
        };
    }

    pub fn rotated_around_x(self: *MeshBuilder, angle: f32) *MeshBuilder {
        return self.rotate(angle, &vec3(1.0, 0.0, 0.0));
    }

    pub fn rotated_around_y(self: *MeshBuilder, angle: f32) *MeshBuilder {
        return self.rotate(angle, &vec3(0.0, 1.0, 0.0));
    }

    pub fn rotated_around_z(self: *MeshBuilder, angle: f32) *MeshBuilder {
        return self.rotate(angle, &vec3(0.0, 0.0, 1.0));
    }

    pub fn translated(self: *MeshBuilder, x: f32, y: f32, z: f32) *MeshBuilder {
        for (self.vertices.data) |vert, i| {
            self.vertices.data[i] = vec3(vert.getX() + x, vert.getY() + y, vert.getZ() + z);
        }
        return self;
    }

    pub fn createSquare(self: *MeshBuilder) *MeshBuilder {
        var t1 = MeshBuilder.new(self.allocator).createTriangle();
        var t2 = MeshBuilder.new(self.allocator).createTriangle().rotated_around_z(PI / 2.0).scaled(1.0, -1.0, 1.0);
        return t1.combine(t2);
    }

    //  pub fn with_color(self: *Mesh, color: *Vec3) Mesh {
    //     Mesh {
    //         vertices self.vertices.iter().cloned().collect(),
    //         normals: self.normals.iter().cloned().collect(),
    //         colors: std::vec::from_elem(color.clone(), self.verticeslen()),
    //         indices: self.indices.iter().cloned().collect(),

    //    }
    // }

    //  fn create_box(color: *Option<Vec3>) Mesh {
    //     Self::create_square(color)
    //         //.combine(self: *Mesh::create_square().translated(0.0, 0.0, 1.0))
    //         .combine(self: *Mesh::create_square(&Some(vec3(0.0, 1.0, 0.0))).rotated_around_y(PI / 2.0))
    //         .combine(self: *Mesh::create_square(&Some(vec3(1.0, 1.0, 0.0))).rotated_around_x(-PI / 2.0))

    //         .combine(self: *Mesh::create_square(&Some(vec3(1.0, 0.0, 0.0))).translated(0.0, 0.0, -1.0))
    //         .combine(self: *Mesh::create_square(&Some(vec3(0.0, 1.0, 1.0))).translated(0.0,0.0,1.0).rotated_around_y(PI / 2.0))
    //         .combine(self: *Mesh::create_square(&Some(vec3(1.0, 1.0, 1.0))).translated(0.0,0.0,1.0).rotated_around_x(-PI / 2.0))
    // }

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
