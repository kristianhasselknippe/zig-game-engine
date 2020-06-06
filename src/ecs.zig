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
    const BoxData = @Type(.Opaque);

    data: *BoxData,

    pub fn new(data: var) !@This() {
        var ptr = try allocator.create(@TypeOf(data));
        debug_log("Assigning data to box", .{});
        ptr.* = data;
        debug_log("done assigning dat to box: {}", .{ptr.items.len});
        return @This(){ .data = @ptrCast(*BoxData, ptr) };
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
        if (self.componentStorages.getValue(compName)) |store| {
            debug_log("Store is: {}", .{store});
            return @ptrCast(*ArrayList(CompType), @alignCast(@sizeOf(*ArrayList(CompType)), store.data));
        }
        unreachable;
    }

    pub fn addComponent(self: *@This(), entity: Entity, comp: var) !Component(@TypeOf(comp)) {
        const CompDataType = @TypeOf(comp);
        const CompType = Component(CompDataType);

        var compStore = try self.safeGetComponentStorage(CompType);
        debug_log("Comp store: {}", .{compStore});

        const newComp = CompType.new(comp, entity);
        debug_log("new comp: {}", .{newComp});
        _ = try compStore.append(newComp);

        return newComp;
    }

    pub fn print_debug_info(self: *@This()) void {
        debug_log("World: ", .{});
        debug_log(" - Num comp types: {}", .{self.componentStorages.size});
    }
};

const TestComp = struct {};

test "basic world" {
    var world = World.new();
    world.print_debug_info();
    var entity = try world.createEntity();
    var component = try world.addComponent(entity, TestComp{});
}
