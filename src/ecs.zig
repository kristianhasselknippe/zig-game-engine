usingnamespace @import("debug.zig");
const std = @import("std");
const assert = std.debug.assert;
const allocator = @import("std").heap.c_allocator;
const ArrayList = @import("std").ArrayList;
const StringHashMap = @import("std").StringHashMap;

pub const Component = struct {
    update: fn (dt: f32) void,
};

const ComponentStorage = StringHashMap(Component);

pub const Entity = struct {
    components: ComponentStorage,

    pub fn new() @This() {
        return @This(){ .components = ComponentStorage.init(allocator) };
    }

    pub fn add_comp(self: *@This(), name: []const u8, component: Component) !void {
        _ = try self.components.put(name, component);
    }
};

pub const World = struct {
    components: ArrayList(Component),
    entities: ArrayList(Entity),

    pub fn new() World {
        return @This(){
            .components = ArrayList(Component).init(allocator),
            .entities = ArrayList(Entity).init(allocator),
        };
    }

    pub fn add_entity(self: *@This(), entity: Entity) !void {
        try self.entities.append(entity);
    }
};

fn test_comp_update(dt: f32) void {}

test "basic world" {
    var world = World.new();
    var entity = Entity.new();
    var comp = Component{
        .update = test_comp_update,
    };
    try entity.add_comp("test_comp", comp);
    debug_log("Entiti comps: {}", .{entity.components.size});
    assert(entity.components.size == 1);
}
