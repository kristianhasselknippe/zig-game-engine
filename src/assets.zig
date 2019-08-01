const c = @import("c.zig");
const std = @import("std");
const assimp = @import("assimp.zig");
const print = std.debug.warn;

pub fn importSomething() void {
    const objFile = @embedFile("./assets/models/teapot.fbx");
    print("Obj file len {}", objFile.len);

    const scene = c.aiImportFileFromMemory(&objFile[0], objFile.len, @enumToInt(c.aiProcess_CalcTangentSpace) |
                                               @enumToInt(c.aiProcess_Triangulate) |
                                               @enumToInt(c.aiProcess_JoinIdenticalVertices) |
                                               @enumToInt(c.aiProcess_SortByPType), c"fbx");
    const aiScene = @ptrCast(*const assimp.AiScene, scene);

    print("Size of u16: {}\n", @intCast(usize, @sizeOf(u16)));
    print("Size of c_uint: {}\n", @intCast(usize, @sizeOf(c_uint)));

    print("Num meshes: {} \n", aiScene.mNumMeshes);
    var i: usize = 0;
    while (i < aiScene.mNumMeshes) : (i += 1) {
        const mesh = aiScene.mMeshes[i];

        print("Primitive type: {}\n", mesh.mPrimitiveTypes);

        print("Mesh mVertices: {}\n", @ptrToInt(mesh.mVertices));
        print("Mesh mNormals: {}\n", @ptrToInt(mesh.mNormals));
        print("Mesh mTangents: {}\n", @ptrToInt(mesh.mTangents));
        print("Mesh mBitangents: {}\n", @ptrToInt(mesh.mBitangents));
        print("Mesh mColors: {}\n", @ptrToInt(mesh.mColors));
        print("Mesh mTextureCoords: {}\n", @ptrToInt(mesh.mTextureCoords));
        print("Mesh mNumUVComponents: {}\n", @ptrToInt(mesh.mNumUVComponents));
        print("Mesh mFaces: {}\n", @ptrToInt(mesh.mFaces));

        var vertIndex: usize = 0;
        while (vertIndex < mesh.mNumVertices) : (vertIndex += 1) {
            const vertex = mesh.mVertices[vertIndex];
            print("Vertex: {}\n", vertex);
            
        }

        if (mesh.mNormals) | normals | {
            print("Num normals {}\n", mesh.mNumVertices);
            var normIndex: usize = 0;
            while (normIndex < mesh.mNumVertices) : (normIndex += 1) {
                const norm = normals[normIndex];
                print("Norm {}\n", norm);
            }
        }

        print("Faces: {}\n", &mesh.mFaces);
        print("Num faces {}\n", mesh.mNumFaces);
        var faceIndex: usize = 0;
        while (faceIndex < mesh.mNumFaces) : (faceIndex+=1) {
            const face = mesh.mFaces[faceIndex];
            print("Face {}\n", face.mNumIndices);
        }
    }

    c.aiReleaseImport(scene);
}
