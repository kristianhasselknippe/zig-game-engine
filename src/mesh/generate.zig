usingnamespace @import("../math.zig");
const Allocator = @import("std").mem.Allocator;

pub const Vertex = Vec3;
pub const Index = u32;

pub const MeshBuilder = struct {
    allocator: *Allocator,
    vertices: ?[]Vertex,
    indices: ?[]Index,

    pub fn new(allocator: *Allocator) MeshBuilder {
        return MeshBuilder {
            .allocator = allocator,
            .vertices = null,
            .indices = null,
        };
    }

    pub fn scaled(self: *MeshBuilder, x: f32, y: f32, z: f32) *MeshBuilder {
        var newVerts = self.allocator.alloc(Vertex, self.prevMesh.vertices.len);
        for (self.vertices) |vert,i| {
            newVerts[i] = vert.scale(vec3(x,y,z));
        }
        if (self.vertices != null) {
            self.allocator.free(self.vertices);
        }
        self.vertices = newVerts;
        return self;
    }

     pub fn rotate(self: *MeshBuilder, angle: f32, axis: *Vec3) *MeshBuilder {
         var newVerts = self.allocator.alloc(Vertex, self.vertices.?.len) catch unreachable;
         var rotMatrix = Mat4.rotate(angle, axis.*);
             for (self.vertices.?) |vert,i| {
                 newVerts[i] = vert.applyMatrix(rotMatrix);
             }

         self.vertices = newVerts;
         return self;
    }

    pub fn create_triangle(self: *MeshBuilder) *MeshBuilder {
        var vertices = self.allocator.alloc(Vertex, 3) catch unreachable;
        vertices[0] = vec3(0.0, 0.0, 0.0);
        vertices[1] = vec3(1.0, 0.0, 0.0);
        vertices[2] = vec3(1.0, 1.0, 0.0);
        if (self.vertices != null) {
            self.allocator.free(self.vertices.?);
        }

        var indices = self.allocator.alloc(Index, 3) catch unreachable;
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        if (self.indices != null) {
            self.allocator.free(self.indices.?);
        }

        self.vertices = vertices;
        self.indices = indices;
        return self;
    }

    pub fn combine(self: *MeshBuilder, other: *MeshBuilder) *MeshBuilder {
        var vertices = self.allocator.alloc(Vertex, self.vertices.?.len + other.vertices.?.len) catch unreachable;
        var indices = self.allocator.alloc(Index, self.indices.?.len + other.indices.?.len) catch unreachable;
        for (self.vertices.?) |vert, i| {
            vertices[i] = vert;
        }
        for (other.vertices.?) |vert, i| {
            vertices[i + self.vertices.?.len] = vert;
        }

        for (self.indices.?) |index, i| {
            indices[i] = index;
        }
        for (other.indices.?) |index, i| {
            indices[i + self.indices.?.len] = index + @intCast(Index, self.indices.?.len);
        }

        self.allocator.free(self.vertices.?);
        other.allocator.free(other.vertices.?);
        self.allocator.free(self.indices.?);
        other.allocator.free(other.indices.?);

        self.vertices = vertices;
        self.indices = indices;
        return self;
    }

    pub fn build(self: *MeshBuilder) Mesh {
        return Mesh {
            .vertices = self.vertices.?,
            .indices = self.indices.?,
        };
    }

    pub fn rotated_around_x(self: *Mesh, angle: f32) MeshBiulder {
        self.rotated(angle, &vec3(1.0, 0.0, 0.0));
    }

    pub fn rotated_around_y(self: *Mesh, angle: f32) MeshBiulder {
        self.rotated(angle, &vec3(0.0, 1.0, 0.0));
    }

    pub fn rotated_around_z(self: *Mesh, angle: f32) *MeshBuilder {
        self.rotated(angle, &vec3(0.0, 0.0, 1.0));
    }

    pub fn translated(self: *MeshBuilder, x: f32, y: f32, z: f32) *MeshBuilder {
        var newVerts = self.allocator.alloc(Vertex, self.vertices.?.len) catch unreachable;
        for (self.vertices.?) |vert,i| {
            newVerts[i] = vec3(vert.getX() + x, vert.getY() + y, vert.getZ() + z);
        }
        self.allocator.free(self.vertices.?);

        self.vertices = newVerts;
        return self;
    }

    //  pub fn combine(self: *Mesh, other: *Mesh) Mesh {
    //     let m1 = self.clone();
    //     let m2 = other.clone();

    //     let m1_indices_len = m1.indices.len() as u16;

    //     Mesh {
    //         vertices: [m1.vertices, m2.vertices].concat(),
    //         normals: [m1.normals, m2.normals].concat(),
    //         colors: [m1.colors, m2.colors].concat(),
    //         indices: [
    //             m1.indices,
    //             m2.indices
    //                 .iter()
    //                 .map(|e| (e + m1_indices_len) as u16)
    //                 .collect(),
    //         ]
    //         .concat(),
    //     }
    // }

    //  pub fn with_color(self: *Mesh, color: *Vec3) Mesh {
    //     Mesh {
    //         vertices: self.vertices.iter().cloned().collect(),
    //         normals: self.normals.iter().cloned().collect(),
    //         colors: std::vec::from_elem(color.clone(), self.vertices.len()),
    //         indices: self.indices.iter().cloned().collect(),

    //    }
    // }



    //  fn create_square(color: *Option<Vec3>) Mesh {
    //     let t1 = Self::create_triangle(color);
    //     let t2 = Self::create_triangle(color)
    //         .rotated_around_z(PI / 2.0)
    //         .scaled(-1.0, 1.0, 1.0);
    //     t1.combine(&t2)
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

const Mesh = struct {
    vertices: []Vertex,
    indices: []Index,

    pub fn free(self: *Mesh, allocator: *Allocator) void {
        allocator.free(self.vertices);
        allocator.free(self.indices);
    }
};
