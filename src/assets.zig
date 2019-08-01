const c = @import("c.zig");
const std = @import("std");
const assimp = @import("assimp.zig");
const print = std.debug.warn;

pub fn importSomething() void {
    const objFile = @embedFile("./assets/models/teapot.obj");
    //print("Obj file len {}", objFile.len);

    const scene = c.aiImportFileFromMemory(&objFile[0], objFile.len, @enumToInt(c.aiProcess_CalcTangentSpace) |
        @enumToInt(c.aiProcess_Triangulate) |
        @enumToInt(c.aiProcess_JoinIdenticalVertices) |
        @enumToInt(c.aiProcess_SortByPType), c"obj");
    const aiScene = @ptrCast(*const assimp.AiScene, scene);

    var i: usize = 0;
    while (i < aiScene.mNumMeshes) : (i += 1) {
        const mesh = aiScene.mMeshes[i];

        print("Primitive type: {}\n", mesh.mPrimitiveTypes);

        var vertIndex: usize = 0;
        while (vertIndex < mesh.mNumVertices) : (vertIndex += 1) {
            const vertex = mesh.mVertices[vertIndex];
            print("Vertex: {}\n", vertex);
        }
        var elemIndex: usize = 0;
//        while (elemIndex < mesh.n
      }

    c.aiReleaseImport(scene);
}
