const c = @import("c.zig");
const print = @import("std").debug.warn;
usingnamespace @import("math.zig");
usingnamespace @import("./math/vec.zig");
usingnamespace @import("drawing/drawing.zig");

pub const Vertex = Vec3;
pub const Index = u32;

pub const Mesh = struct {
    vertices: []Vertex,
    indices: []Index,

    pub fn free(self: *Mesh, allocator: *Allocator) void {
        allocator.free(self.vertices);
        allocator.free(self.indices);
    }

    pub fn print(self: *Mesh) void {
        debug("Mesh: {}  \n", .{mesh});
        for (mesh.vertices) |vert| {
            debug("   vert: {},{},{}\n", .{ vert.getX(), vert.getY(), vert.getZ() });
        }
        for (mesh.indices) |index| {
            debug("   index: {}\n", .{index});
        }
    }
};
