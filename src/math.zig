usingnamespace @import("./typeUtils.zig");
const assert = @import("std").debug.assert;
const math = @import("std").math;

pub const Mat4 = struct {
    data: [4][4]f32,

    /// matrix multiplication
    pub fn mult(m: Mat4, other: Mat4) Mat4 {
        return Mat4{
            .data = [_][4]f32{
                [_]f32{
                    m.data[0][0] * other.data[0][0] + m.data[0][1] * other.data[1][0] + m.data[0][2] * other.data[2][0] + m.data[0][3] * other.data[3][0],
                    m.data[0][0] * other.data[0][1] + m.data[0][1] * other.data[1][1] + m.data[0][2] * other.data[2][1] + m.data[0][3] * other.data[3][1],
                    m.data[0][0] * other.data[0][2] + m.data[0][1] * other.data[1][2] + m.data[0][2] * other.data[2][2] + m.data[0][3] * other.data[3][2],
                    m.data[0][0] * other.data[0][3] + m.data[0][1] * other.data[1][3] + m.data[0][2] * other.data[2][3] + m.data[0][3] * other.data[3][3],
                },
                [_]f32{
                    m.data[1][0] * other.data[0][0] + m.data[1][1] * other.data[1][0] + m.data[1][2] * other.data[2][0] + m.data[1][3] * other.data[3][0],
                    m.data[1][0] * other.data[0][1] + m.data[1][1] * other.data[1][1] + m.data[1][2] * other.data[2][1] + m.data[1][3] * other.data[3][1],
                    m.data[1][0] * other.data[0][2] + m.data[1][1] * other.data[1][2] + m.data[1][2] * other.data[2][2] + m.data[1][3] * other.data[3][2],
                    m.data[1][0] * other.data[0][3] + m.data[1][1] * other.data[1][3] + m.data[1][2] * other.data[2][3] + m.data[1][3] * other.data[3][3],
                },
                [_]f32{
                    m.data[2][0] * other.data[0][0] + m.data[2][1] * other.data[1][0] + m.data[2][2] * other.data[2][0] + m.data[2][3] * other.data[3][0],
                    m.data[2][0] * other.data[0][1] + m.data[2][1] * other.data[1][1] + m.data[2][2] * other.data[2][1] + m.data[2][3] * other.data[3][1],
                    m.data[2][0] * other.data[0][2] + m.data[2][1] * other.data[1][2] + m.data[2][2] * other.data[2][2] + m.data[2][3] * other.data[3][2],
                    m.data[2][0] * other.data[0][3] + m.data[2][1] * other.data[1][3] + m.data[2][2] * other.data[2][3] + m.data[2][3] * other.data[3][3],
                },
                [_]f32{
                    m.data[3][0] * other.data[0][0] + m.data[3][1] * other.data[1][0] + m.data[3][2] * other.data[2][0] + m.data[3][3] * other.data[3][0],
                    m.data[3][0] * other.data[0][1] + m.data[3][1] * other.data[1][1] + m.data[3][2] * other.data[2][1] + m.data[3][3] * other.data[3][1],
                    m.data[3][0] * other.data[0][2] + m.data[3][1] * other.data[1][2] + m.data[3][2] * other.data[2][2] + m.data[3][3] * other.data[3][2],
                    m.data[3][0] * other.data[0][3] + m.data[3][1] * other.data[1][3] + m.data[3][2] * other.data[2][3] + m.data[3][3] * other.data[3][3],
                },
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
            .data = [_][4]f32{
                [_]f32{ 1.0, 0.0, 0.0, 0.0 },
                [_]f32{ 0.0, 1.0, 0.0, 0.0 },
                [_]f32{ 0.0, 0.0, 1.0, 0.0 },
                [_]f32{ x, y, z, 1.0 },
            },
        };
    }

    pub fn perspective(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const yScale = 1.0 / math.tan(fov / 2);
        const xScale = yScale / aspect;
        const nearmfar = near - far;
        const m = Mat4{
            .data = [_][4]f32{
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

pub const mat4_identity = Mat4{
    .data = [_][4]f32{
        [_]f32{ 1.0, 0.0, 0.0, 0.0 },
        [_]f32{ 0.0, 1.0, 0.0, 0.0 },
        [_]f32{ 0.0, 0.0, 1.0, 0.0 },
        [_]f32{ 0.0, 0.0, 0.0, 1.0 },
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

pub const Vec2 = struct {
    data: [2]f32,
};

pub const Vec3 = struct {
    data: [3]f32,

    pub fn normalize(v: Vec3) Vec3 {
        return v.scale(1.0 / math.sqrt(v.dot(v)));
    }

    pub fn scale(v: Vec3, factor: var) Vec3 {
        switch (@TypeOf(factor)) {
            Vec3 => {
                return Vec3{
                    .data = [_]f32{
                        v.data[0] * scalar,
                        v.data[1] * scalar,
                        v.data[2] * scalar,
                    },
                };
            },
            else => {
                switch (@typeInfo(@TypeOf(factor))) {
                    .Float, .Int => {
                        return Vec3{
                            .data = [_]f32{
                                v.data[0] * factor,
                                v.data[1] * factor,
                                v.data[2] * factor,
                            },
                        };
                    },
                    else => @compileError("Scale is only supported with numbers and another Vec3"),
                }
            },
        }
    }

    pub fn dot(v: Vec3, other: Vec3) f32 {
        return v.data[0] * other.data[0] +
            v.data[1] * other.data[1] +
            v.data[2] * other.data[2];
    }

    pub fn length(v: Vec3) f32 {
        return math.sqrt(v.dot(v));
    }

    /// returns the cross product
    pub fn cross(v: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .data = [_]f32{
                v.data[1] * other.data[2] - other.data[1] * v.data[2],
                v.data[2] * other.data[0] - other.data[2] * v.data[0],
                v.data[0] * other.data[1] - other.data[0] * v.data[1],
            },
        };
    }

    pub fn add(v: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .data = [_]f32{
                v.data[0] + other.data[0],
                v.data[1] + other.data[1],
                v.data[2] + other.data[2],
            },
        };
    }

    pub fn applyMatrix(self: *Vec3, m: Mat4) Vec3 {
        var x = self.x;
        var y = self.y;
        var z = self.z;
        var e = m.flat_data();

        var w = 1 / (e[3] * x + e[7] * y + e[11] * z + e[15]);

        return vec3((e[0] * x + e[4] * y + e[8] * z + e[12]) * w, (e[1] * x + e[5] * y + e[9] * z + e[13]) * w, (e[2] * x + e[6] * y + e[10] * z + e[14]) * w);
    }
};

pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return Vec3{
        .data = [_]f32{
            x,
            y,
            z,
        },
    };
}

pub const Vec4 = struct {
    data: [4]f32,
};

pub fn vec4(xa: f32, xb: f32, xc: f32, xd: f32) Vec4 {
    return Vec4{
        .data = [_]f32{
            xa,
            xb,
            xc,
            xd,
        },
    };
}

fn testScale() void {
    @setFnTest(this, true);

    const m = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.840188, 0.911647, 0.277775, 0.364784 },
            [_]f32{ 0.394383, 0.197551, 0.55397, 0.513401 },
            [_]f32{ 0.783099, 0.335223, 0.477397, 0.95223 },
            [_]f32{ 0.79844, 0.76823, 0.628871, 0.916195 },
        },
    };
    const expected = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.118973, 0.653922, 0.176585, 0.364784 },
            [_]f32{ 0.0558456, 0.141703, 0.352165, 0.513401 },
            [_]f32{ 0.110889, 0.240454, 0.303487, 0.95223 },
            [_]f32{ 0.113061, 0.551049, 0.399781, 0.916195 },
        },
    };
    const answer = m.scale(0.141603, 0.717297, 0.635712);
    assert_matrix_eq(answer, expected);
}

fn testTranslate() void {
    @setFnTest(this, true);

    const m = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.840188, 0.911647, 0.277775, 0.364784 },
            [_]f32{ 0.394383, 0.197551, 0.55397, 0.513401 },
            [_]f32{ 0.783099, 0.335223, 0.477397, 0.95223 },
            [_]f32{ 0.79844, 0.76823, 0.628871, 1.0 },
        },
    };
    const expected = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.840188, 0.911647, 0.277775, 1.31426 },
            [_]f32{ 0.394383, 0.197551, 0.55397, 1.06311 },
            [_]f32{ 0.783099, 0.335223, 0.477397, 1.60706 },
            [_]f32{ 0.79844, 0.76823, 0.628871, 1.0 },
        },
    };
    const answer = m.translate(0.141603, 0.717297, 0.635712);
    assert_matrix_eq(answer, expected);
}

fn testOrtho() void {
    @setFnTest(this, true);

    const m = mat4_ortho(0.840188, 0.394383, 0.783099, 0.79844);

    const expected = Mat4{
        .data = [_][4]f32{
            [_]f32{ -4.48627, 0.0, 0.0, 2.76931 },
            [_]f32{ 0.0, 130.371, 0.0, -103.094 },
            [_]f32{ 0.0, 0.0, -1.0, 0.0 },
            [_]f32{ 0.0, 0.0, 0.0, 1.0 },
        },
    };

    assert_matrix_eq(m, expected);
}

fn assertFEq(left: f32, right: f32) void {
    const diff = c.fabsf(left - right);
    assert(diff < 0.01);
}

fn assertMatrixEq(left: Mat4, right: Mat4) void {
    assert_f_eq(left.data[0][0], right.data[0][0]);
    assert_f_eq(left.data[0][1], right.data[0][1]);
    assert_f_eq(left.data[0][2], right.data[0][2]);
    assert_f_eq(left.data[0][3], right.data[0][3]);

    assert_f_eq(left.data[1][0], right.data[1][0]);
    assert_f_eq(left.data[1][1], right.data[1][1]);
    assert_f_eq(left.data[1][2], right.data[1][2]);
    assert_f_eq(left.data[1][3], right.data[1][3]);

    assert_f_eq(left.data[2][0], right.data[2][0]);
    assert_f_eq(left.data[2][1], right.data[2][1]);
    assert_f_eq(left.data[2][2], right.data[2][2]);
    assert_f_eq(left.data[2][3], right.data[2][3]);

    assert_f_eq(left.data[3][0], right.data[3][0]);
    assert_f_eq(left.data[3][1], right.data[3][1]);
    assert_f_eq(left.data[3][2], right.data[3][2]);
    assert_f_eq(left.data[3][3], right.data[3][3]);
}

fn testMult() void {
    @setFnTest(this, true);

    const m1 = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.635712, 0.717297, 0.141603, 0.606969 },
            [_]f32{ 0.0163006, 0.242887, 0.137232, 0.804177 },
            [_]f32{ 0.156679, 0.400944, 0.12979, 0.108809 },
            [_]f32{ 0.998924, 0.218257, 0.512932, 0.839112 },
        },
    };
    const m2 = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.840188, 0.394383, 0.783099, 0.79844 },
            [_]f32{ 0.911647, 0.197551, 0.335223, 0.76823 },
            [_]f32{ 0.277775, 0.55397, 0.477397, 0.628871 },
            [_]f32{ 0.364784, 0.513401, 0.95223, 0.916195 },
        },
    };
    const answer = Mat4{
        .data = [_][4]f32{
            [_]f32{ 1.44879, 0.782479, 1.38385, 1.70378 },
            [_]f32{ 0.566593, 0.543299, 0.925461, 1.02269 },
            [_]f32{ 0.572904, 0.268761, 0.422673, 0.614428 },
            [_]f32{ 1.48683, 1.15203, 1.89932, 2.05661 },
        },
    };
    const tmp = m1.mult(m2);
    assert_matrix_eq(tmp, answer);
}

fn testRotate() void {
    @setFnTest(this, true);

    const m1 = Mat4{
        .data = [_][4]f32{
            [_]f32{ 0.840188, 0.911647, 0.277775, 0.364784 },
            [_]f32{ 0.394383, 0.197551, 0.55397, 0.513401 },
            [_]f32{ 0.783099, 0.335223, 0.477397, 0.95223 },
            [_]f32{ 0.79844, 0.76823, 0.628871, 0.916195 },
        },
    };
    const angle = 0.635712;

    const axis = vec3(0.606969, 0.141603, 0.717297);

    const expected = Mat4{
        .data = [_][4]f32{
            [_]f32{ 1.17015, 0.488019, 0.0821911, 0.364784 },
            [_]f32{ 0.444151, 0.212659, 0.508874, 0.513401 },
            [_]f32{ 0.851739, 0.126319, 0.460555, 0.95223 },
            [_]f32{ 1.06829, 0.530801, 0.447396, 0.916195 },
        },
    };

    const actual = m1.rotate(angle, axis);
    assert_matrix_eq(actual, expected);
}
