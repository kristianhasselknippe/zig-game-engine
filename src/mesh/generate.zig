usingnamespace @import("../math.zig");

const Vertex = Vec3;
const Index = usize;

const MeshBuilder = struct {
    allocator: *Allocator,
    prevMesh: Mesh,

    pub fn scaled(self: *MeshBuilder, x: f32, y: f32, z: f32) Mesh {
        var newVerts = self.allocator.alloc(Vertex, self.prevMesh.vertices.len);
        for (self.vertices) |vert,i| {
            newVerts[i] = vert.scale(vec3(x,y,z));
        }
        return Mesh {
            .vertices = newVerts,
            //indices: self.indices.iter().cloned().collect(),
        };
    }

     pub fn rotated(self: *Mesh, angle: f32, axis: *Vec3) Mesh {
         var rotMatrix =
        return Mesh {
            .vertices = self.vertices
            //indices: self.indices.iter().cloned().collect(),
         };
    }

    //  pub fn rotated_around_x(self: *Mesh, angle: f32) Mesh {
    //     self.rotated(angle, &vec3(1.0, 0.0, 0.0))
    // }

    //  pub fn rotated_around_y(self: *Mesh, angle: f32) Mesh {
    //     self.rotated(angle, &vec3(0.0, 1.0, 0.0))
    // }

    //  pub fn rotated_around_z(self: *Mesh, angle: f32) Mesh {
    //     self.rotated(angle, &vec3(0.0, 0.0, 1.0))
    // }

    //  pub fn translated(self: *Mesh, x: f32, y: f32, z: f32) Mesh {
    //     Mesh {
    //         vertices: self
    //             .vertices
    //             .iter()
    //             .map(|v| vec3(v.x + x, v.y + y, v.z + z))
    //             .collect(),
    //         normals: self.normals.iter().cloned().collect(),
    //         colors: self.colors.iter().cloned().collect(),
    //         indices: self.indices.iter().cloned().collect(),
    //     }
    // }

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

    //  pub fn create_triangle(color: *Option<Vec3>) Mesh {
    //     return Mesh {
    //         vertices: vec![
    //             vec3(0.0, 0.0, 0.0),
    //             vec3(1.0, 0.0, 0.0),
    //             vec3(1.0, 1.0, 0.0),
    //         ],
    //         normals: vec![
    //             vec3(0.0, 0.0, 1.0),
    //             vec3(0.0, 0.0, 1.0),
    //             vec3(0.0, 0.0, 1.0),
    //         ],
    //         colors: {
    //             if let &Some(color) = color {
    //                 std::vec::from_elem(color, 3)
    //             } else {
    //                 std::vec::from_elem(vec3(1.0, 0.0, 1.0), 3)
    //             }
    //         },
    //         indices: vec![0, 1, 2],
    //     };
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
     vertices: [*]Vertex,
     indices: [*]Index,
};