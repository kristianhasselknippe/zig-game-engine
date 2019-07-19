const c = @import("c.zig");
const std = @import("std");
const print = std.debug.warn;

pub fn importSomething() void {

    const objFile = @embedFile("./assets/teapot.obj");
    //print("Obj file len {}", objFile.len);

    const scene = c.aiImportFileFromMemory(
        &objFile[0],
        objFile.len,
        @enumToInt(c.aiProcess_CalcTangentSpace) |
            @enumToInt(c.aiProcess_Triangulate) |
            @enumToInt(c.aiProcess_JoinIdenticalVertices) |
            @enumToInt(c.aiProcess_SortByPType),
        c"obj");

    print("\nScene {} \n", scene);
}
