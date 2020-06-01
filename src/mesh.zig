usingnamespace @import("math.zig");
usingnamespace @import("./math/vec.zig");

const c = @import("c.zig");
const debug = @import("std").debug.warn;

pub const Vertex = struct {
    pos: Vec3,
    uv: [2]f32,

    pub fn new(pos: Vec3, uv: [2]f32) Vertex {
        return @This(){
            .pos = pos,
            .uv = uv,
        };
    }

    pub fn copy(self: Vertex) @This() {
        return Vertex{
            .pos = self.pos.copy(),
            .uv = [2]f32{ self.uv[0], self.uv[1] },
        };
    }
};

pub const Index = u32;

pub const Mesh = struct {
    vertices: []Vertex,
    indices: []Index,

    pub fn free(self: *Mesh, allocator: *Allocator) void {
        allocator.free(self.vertices);
        allocator.free(self.indices);
    }

    pub fn print(self: *Mesh) void {
        debug("Mesh: {}  \n", .{self});
        for (self.vertices) |vert| {
            debug("   vert: p({},{},{}), uv({},{})\n", .{ vert.pos.getX(), vert.pos.getY(), vert.pos.getZ(), vert.uv[0], vert.uv[1] });
        }
        for (self.indices) |index| {
            debug("   index: {}\n", .{index});
        }
    }
};
