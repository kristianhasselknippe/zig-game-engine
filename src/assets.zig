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

    var i: usize = 0;
    while (i < aiScene.mNumMeshes) : (i += 1) {
        const mesh = aiScene.mMeshes[i];

        var vertIndex: usize = 0;
        while (vertIndex < mesh.mNumVertices) : (vertIndex += 1) {
            const vertex = mesh.mVertices[vertIndex];
        }
    }

    c.aiReleaseImport(scene);
}
