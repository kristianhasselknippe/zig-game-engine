usingnamespace @import("debug.zig");
const std = @import("std");
const assert = std.debug.assert;
const allocator = @import("std").heap.c_allocator;
const ArrayList = @import("std").ArrayList;
const StringHashMap = @import("std").StringHashMap;

const ID = i32;

pub fn ComponentStorage(comptime T: type) type {
    return ArrayList(struct {
        entity_id: ID,
        data: T,
    });
}

var id_counter: ID = 0;
pub const Entity = struct {
    id: ID,

    pub fn new() @This() {
        var ret = @This(){
            .id = id_counter
        };
        id_counter = id_counter + 1;
        return ret;
    }
};

pub const World = struct {
    component_storages: ArrayList(*void),
    pub fn new() World {
        return @This(){
            .component_storages = ArrayList(*void).init(allocator),
        };
    }

    pub fn add_component_storage(self: *@This(), storageContainer: var) void {
        self.component_storages.append(@ptrCast(*void, storageContainer));
    }
};

const TestComponent = ArrayList(struct {
    foo: f32
});

test "basic world" {
    var world = World.new();
    world.add_component_storage(TestComponent.init(allocator));
}
