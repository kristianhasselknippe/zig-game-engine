usingnamespace @import("debug.zig");
const std = @import("std");
const assert = std.debug.assert;
const allocator = @import("std").heap.c_allocator;
const ArrayList = @import("std").ArrayList;
const StringHashMap = @import("std").StringHashMap;

const ID = i32;

fn Component(comptime T: type) type {
    return struct {
        entity_id: ID,
        data: T,

        pub fn new(data: T, entity: Entity) @This() {
            return @This(){
                .entity_id = entity.id,
                .data = data,
            };
        }
    };
}

pub fn ComponentStorage(comptime T: type) type {
    const InstanceList = ArrayList(Component(T));

    return struct {
        instances: InstanceList,

        pub fn new() @This() {
            id_counter += 1;
            return @This(){ .instances = InstanceList.init(allocator) };
        }
    };
}

var id_counter: ID = 0;
pub const Entity = struct {
    id: ID,

    pub fn new() @This() {
        var ret = @This(){ .id = id_counter };
        id_counter = id_counter + 1;
        return ret;
    }
};

const Box = struct {
    const BoxData = opaque {};

    data: *BoxData,

    pub fn new(data: anytype) !@This() {
        var ptr = try allocator.create(@TypeOf(data));
        ptr.* = data;
        return @This(){ .data = @ptrCast(*BoxData, ptr) };
    }

    pub fn unwrap(self: @This(), comptime T: type) *T {
        return @ptrCast(*T, @alignCast(@sizeOf(*T), self.data));
    }
};

pub const World = struct {
    entities: ArrayList(Entity),
    componentStorages: StringHashMap(Box),

    pub fn new() @This() {
        return @This(){
            .componentStorages = StringHashMap(Box).init(allocator),
            .entities = ArrayList(Entity).init(allocator),
        };
    }

    pub fn createEntity(self: *@This()) !Entity {
        var entity = Entity.new();
        _ = try self.entities.append(entity);
        return entity;
    }

    fn ensureCompStorageExists(self: *@This(), comptime CompType: type) !void {
        const compName = @typeName(CompType);
        if (!self.componentStorages.contains(compName)) {
            _ = try self.componentStorages.put(compName, try Box.new(ArrayList(CompType).init(allocator)));
        }
    }

    fn safeGetComponentStorage(self: *@This(), comptime CompType: type) !*ArrayList(CompType) {
        const compName = @typeName(CompType);
        try self.ensureCompStorageExists(CompType);
        if (self.componentStorages.get(compName)) |store| {
            return store.unwrap(ArrayList(CompType));
        }
        unreachable;
    }

    pub fn addComponent(self: *@This(), entity: Entity, comp: anytype) !Component(@TypeOf(comp)) {
        const CompDataType = @TypeOf(comp);
        const CompType = Component(CompDataType);

        var compStore = try self.safeGetComponentStorage(CompType);
        const newComp = CompType.new(comp, entity);
        _ = try compStore.append(newComp);

        return newComp;
    }

    pub fn print_debug_info(self: *@This()) void {
        debug_log("World: ", .{});
        debug_log(" - Num comp types: {any}", .{self.componentStorages.count()});
        var it = self.componentStorages.iterator();
        while (it.next()) |compStorage| {
            debug_log("    - strage: {any}", .{compStorage.key});
        }
    }

    pub fn getComponents(self: *@This(), comptime TComp: type) !*ArrayList(Component(TComp)) {
        return try self.safeGetComponentStorage(Component(TComp));
    }
};

const TestComp = struct {};

test "basic world" {
    var world = World.new();
    world.print_debug_info();
    var entity = try world.createEntity();
    var component = try world.addComponent(entity, TestComp{});
}

const TestComp2 = struct { foobar: i32 };

test "two comp types" {
    var world = World.new();
    var entity = try world.createEntity();
    var c1 = try world.addComponent(entity, TestComp{});
    var c2 = try world.addComponent(entity, TestComp2{ .foobar = 123 });

    var c1s = try world.getComponents(TestComp);
    var c2s = try world.getComponents(TestComp2);
    world.print_debug_info();

    assert(c1s.items.len == 1);
    assert(c2s.items.len == 1);

    var c3 = try world.addComponent(entity, TestComp2{ .foobar = 32 });
    assert(c1s.items.len == 1);
    assert(c2s.items.len == 2);
}
