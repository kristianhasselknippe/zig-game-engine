usingnamespace @import(("../typeUtils.zig"));
usingnamespace @import(("./vec.zig"));
const assert = @import((("std"))).debug.assert;
const math = @import("std").math;

pub const mat4_identity = Mat4{
    .data = .{
        [_]f32 {1.0, 0.0, 0.0, 0.0},
        [_]f32 {0.0, 1.0, 0.0, 0.0},
        [_]f32 {0.0, 0.0, 1.0, 0.0},
        [_]f32 {0.0, 0.0, 0.0, 1.0},
    },
};

/// Creates a matrix for an orthographic parallel viewing volume.
pub fn mat4Ortho(left: f32, right: f32, bottom: f32, top: f32) Mat4 {
    var m = mat4_identity;
    m.data[0][0] = 2.0 / (right - left);
    m.data[1][1] = 2.0 / (top - bottom);
    m.data[2][2] = -1.0;
    m.data[0][3] = -(right + left) / (right - left);
    m.data[1][3] = -(top + bottom) / (top - bottom);
    return m;
}

pub const Mat4 = struct {
    data: [4][4]f32,

    /// matrix multiplication
    pub fn mult(m: Mat4, other: Mat4) Mat4 {
        return Mat4{
            .data = [16]f32{
                m.data[0][0] * other.data[0][0] + m.data[0][1] * other.data[1][0] + m.data[0][2] * other.data[2][0] + m.data[0][3] * other.data[3][0],
                m.data[0][0] * other.data[0][1] + m.data[0][1] * other.data[1][1] + m.data[0][2] * other.data[2][1] + m.data[0][3] * other.data[3][1],
                m.data[0][0] * other.data[0][2] + m.data[0][1] * other.data[1][2] + m.data[0][2] * other.data[2][2] + m.data[0][3] * other.data[3][2],
                m.data[0][0] * other.data[0][3] + m.data[0][1] * other.data[1][3] + m.data[0][2] * other.data[2][3] + m.data[0][3] * other.data[3][3],

                m.data[1][0] * other.data[0][0] + m.data[1][1] * other.data[1][0] + m.data[1][2] * other.data[2][0] + m.data[1][3] * other.data[3][0],
                m.data[1][0] * other.data[0][1] + m.data[1][1] * other.data[1][1] + m.data[1][2] * other.data[2][1] + m.data[1][3] * other.data[3][1],
                m.data[1][0] * other.data[0][2] + m.data[1][1] * other.data[1][2] + m.data[1][2] * other.data[2][2] + m.data[1][3] * other.data[3][2],
                m.data[1][0] * other.data[0][3] + m.data[1][1] * other.data[1][3] + m.data[1][2] * other.data[2][3] + m.data[1][3] * other.data[3][3],

                m.data[2][0] * other.data[0][0] + m.data[2][1] * other.data[1][0] + m.data[2][2] * other.data[2][0] + m.data[2][3] * other.data[3][0],
                m.data[2][0] * other.data[0][1] + m.data[2][1] * other.data[1][1] + m.data[2][2] * other.data[2][1] + m.data[2][3] * other.data[3][1],
                m.data[2][0] * other.data[0][2] + m.data[2][1] * other.data[1][2] + m.data[2][2] * other.data[2][2] + m.data[2][3] * other.data[3][2],
                m.data[2][0] * other.data[0][3] + m.data[2][1] * other.data[1][3] + m.data[2][2] * other.data[2][3] + m.data[2][3] * other.data[3][3],

                m.data[3][0] * other.data[0][0] + m.data[3][1] * other.data[1][0] + m.data[3][2] * other.data[2][0] + m.data[3][3] * other.data[3][0],
                m.data[3][0] * other.data[0][1] + m.data[3][1] * other.data[1][1] + m.data[3][2] * other.data[2][1] + m.data[3][3] * other.data[3][1],
                m.data[3][0] * other.data[0][2] + m.data[3][1] * other.data[1][2] + m.data[3][2] * other.data[2][2] + m.data[3][3] * other.data[3][2],
                m.data[3][0] * other.data[0][3] + m.data[3][1] * other.data[1][3] + m.data[3][2] * other.data[2][3] + m.data[3][3] * other.data[3][3],
            },
        };
    }

    pub fn flat_data(self: *Mat4) [16]f32 {
        return @castPtr([16]f32, self.data);
    }

    /// Builds a rotation 4 * 4 matrix created from an axis vector and an angle.
    /// Input matrix multiplied by this rotation matrix.
    /// angle: Rotation angle expressed in radians.
    /// axis: Rotation axis, recommended to be normalized.
    pub fn rotate(m: Mat4, angle: f32, axis_unnormalized: Vec3) Mat4 {
        const cos = math.cos(angle);
        const s = math.sin(angle);
        const axis = axis_unnormalized.normalize();
        const temp = axis.scale(1.0 - cos);

        const rot = Mat4{
            .data = [_][4]f32{
                [_]f32{ cos + temp.data[0] * axis.data[0], 0.0 + temp.data[1] * axis.data[0] - s * axis.data[2], 0.0 + temp.data[2] * axis.data[0] + s * axis.data[1], 0.0 },
                [_]f32{ 0.0 + temp.data[0] * axis.data[1] + s * axis.data[2], cos + temp.data[1] * axis.data[1], 0.0 + temp.data[2] * axis.data[1] - s * axis.data[0], 0.0 },
                [_]f32{ 0.0 + temp.data[0] * axis.data[2] - s * axis.data[1], 0.0 + temp.data[1] * axis.data[2] + s * axis.data[0], cos + temp.data[2] * axis.data[2], 0.0 },
                [_]f32{ 0.0, 0.0, 0.0, 0.0 },
            },
        };

        return Mat4{
            .data = [_][4]f32{
                [_]f32{
                    m.data[0][0] * rot.data[0][0] + m.data[0][1] * rot.data[1][0] + m.data[0][2] * rot.data[2][0],
                    m.data[0][0] * rot.data[0][1] + m.data[0][1] * rot.data[1][1] + m.data[0][2] * rot.data[2][1],
                    m.data[0][0] * rot.data[0][2] + m.data[0][1] * rot.data[1][2] + m.data[0][2] * rot.data[2][2],
                    m.data[0][3],
                },
                [_]f32{
                    m.data[1][0] * rot.data[0][0] + m.data[1][1] * rot.data[1][0] + m.data[1][2] * rot.data[2][0],
                    m.data[1][0] * rot.data[0][1] + m.data[1][1] * rot.data[1][1] + m.data[1][2] * rot.data[2][1],
                    m.data[1][0] * rot.data[0][2] + m.data[1][1] * rot.data[1][2] + m.data[1][2] * rot.data[2][2],
                    m.data[1][3],
                },
                [_]f32{
                    m.data[2][0] * rot.data[0][0] + m.data[2][1] * rot.data[1][0] + m.data[2][2] * rot.data[2][0],
                    m.data[2][0] * rot.data[0][1] + m.data[2][1] * rot.data[1][1] + m.data[2][2] * rot.data[2][1],
                    m.data[2][0] * rot.data[0][2] + m.data[2][1] * rot.data[1][2] + m.data[2][2] * rot.data[2][2],
                    m.data[2][3],
                },
                [_]f32{
                    m.data[3][0] * rot.data[0][0] + m.data[3][1] * rot.data[1][0] + m.data[3][2] * rot.data[2][0],
                    m.data[3][0] * rot.data[0][1] + m.data[3][1] * rot.data[1][1] + m.data[3][2] * rot.data[2][1],
                    m.data[3][0] * rot.data[0][2] + m.data[3][1] * rot.data[1][2] + m.data[3][2] * rot.data[2][2],
                    m.data[3][3],
                },
            },
        };
    }

    /// Builds a translation 4 * 4 matrix created from a vector of 3 components.
    /// Input matrix multiplied by this translation matrix.
    pub fn translate(m: Mat4, x: f32, y: f32, z: f32) Mat4 {
        return Mat4{
            .data = [_][4]f32{
                [_]f32{ m.data[0][0], m.data[0][1], m.data[0][2], m.data[0][3] + m.data[0][0] * x + m.data[0][1] * y + m.data[0][2] * z },
                [_]f32{ m.data[1][0], m.data[1][1], m.data[1][2], m.data[1][3] + m.data[1][0] * x + m.data[1][1] * y + m.data[1][2] * z },
                [_]f32{ m.data[2][0], m.data[2][1], m.data[2][2], m.data[2][3] + m.data[2][0] * x + m.data[2][1] * y + m.data[2][2] * z },
                [_]f32{ m.data[3][0], m.data[3][1], m.data[3][2], m.data[3][3] },
            },
        };
    }

    pub fn translation(x: f32, y: f32, z: f32) Mat4 {
        return Mat4{
            .data = [4][4]f32{
                [4]f32{ 1.0, 0.0, 0.0, 0.0 },
                [4]f32{ 0.0, 1.0, 0.0, 0.0 },
                [4]f32{ 0.0, 0.0, 1.0, 0.0 },
                [4]f32{ x, y, z, 1.0 },
            },
        };
    }

    pub fn perspective(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const yScale = 1.0 / math.tan(fov / 2);
        const xScale = yScale / aspect;
        const nearmfar = near - far;
        const m = Mat4{
            .data = [4][4]f32{
                [_]f32{ xScale, 0, 0, 0 },
                [_]f32{ 0, yScale, 0, 0 },
                [_]f32{ 0, 0, (far + near) / nearmfar, -1 },
                [_]f32{ 0, 0, 2 * far * near / nearmfar, 0 },
            },
        };
        return m;
    }

    pub fn translateByVec(m: Mat4, v: Vec3) Mat4 {
        return m.translate(v.data[0], v.data[1], v.data[2]);
    }

    /// Builds a scale 4 * 4 matrix created from 3 scalars.
    /// Input matrix multiplied by this scale matrix.
    pub fn scale(m: Mat4, x: f32, y: f32, z: f32) Mat4 {
        return Mat4{
            .data = [_][4]f32{
                [_]f32{ m.data[0][0] * x, m.data[0][1] * y, m.data[0][2] * z, m.data[0][3] },
                [_]f32{ m.data[1][0] * x, m.data[1][1] * y, m.data[1][2] * z, m.data[1][3] },
                [_]f32{ m.data[2][0] * x, m.data[2][1] * y, m.data[2][2] * z, m.data[2][3] },
                [_]f32{ m.data[3][0] * x, m.data[3][1] * y, m.data[3][2] * z, m.data[3][3] },
            },
        };
    }

    pub fn transpose(m: Mat4) Mat4 {
        return Mat4{
            .data = [_][4]f32{
                [_]f32{ m.data[0][0], m.data[1][0], m.data[2][0], m.data[3][0] },
                [_]f32{ m.data[0][1], m.data[1][1], m.data[2][1], m.data[3][1] },
                [_]f32{ m.data[0][2], m.data[1][2], m.data[2][2], m.data[3][2] },
                [_]f32{ m.data[0][3], m.data[1][3], m.data[2][3], m.data[3][3] },
            },
        };
    }
};
