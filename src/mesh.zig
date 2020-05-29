usingnamespace @import("math.zig");
usingnamespace @import("./math/vec.zig");

const c = @import("c.zig");
const debug = @import("std").debug.warn;

pub const Vertex = Vec3;
pub const Index = u32;
pub const UV = [2]u32;

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
            debug("   vert: {},{},{}\n", .{ vert.getX(), vert.getY(), vert.getZ() });
        }
        for (self.indices) |index| {
            debug("   index: {}\n", .{index});
        }
    }
};
