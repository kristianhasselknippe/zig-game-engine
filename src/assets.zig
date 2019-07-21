const c = @import("c.zig");
const std = @import("std");
const assimp = @import("assimp.zig");
const print = std.debug.warn;

pub fn importSomething() void {
    const objFile = @embedFile("./assets/teapot.obj");
    //print("Obj file len {}", objFile.len);

    const scene = c.aiImportFileFromMemory(&objFile[0], objFile.len, @enumToInt(c.aiProcess_CalcTangentSpace) |
        @enumToInt(c.aiProcess_Triangulate) |
        @enumToInt(c.aiProcess_JoinIdenticalVertices) |
        @enumToInt(c.aiProcess_SortByPType), c"obj");
    const aiScene = @ptrCast(*const assimp.AiScene, scene);

    print("\nScene has meshes {} \n", aiScene.mNumMeshes);
    print("\nScene has materials {} \n", aiScene.mNumMaterials);
    print("{?}\n", aiScene.*);

    c.aiReleaseImport(scene);
}
