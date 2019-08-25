const c = @import("c.zig");
const std = @import("std");
const assert = std.debug.assert;
const assimp = @import("assimp.zig");
const print = std.debug.warn;
const allocator = @import("std").heap.c_allocator;
const ArrayList = @import("std").ArrayList;
use @import("math.zig");
use @import("mesh.zig");

pub fn importSomething() !ArrayList(Mesh) {
    const objFile = @embedFile("./assets/models/lambo/Lamborghini_Aventador.fbx");
    const scene = c.aiImportFileFromMemory(&objFile[0], objFile.len, @enumToInt(c.aiProcess_CalcTangentSpace) |
                                               @enumToInt(c.aiProcess_Triangulate) |
                                               @enumToInt(c.aiProcess_GenUVCoords) |
                                               @enumToInt(c.aiProcess_JoinIdenticalVertices) |
                                               @enumToInt(c.aiProcess_SortByPType), c"fbx");
    const aiScene = @ptrCast(*const assimp.AiScene, scene);
    //defer c.aiReleaseImport(scene); // TODO: Why does this segfault

    print("Size of u16: {}\n", @intCast(usize, @sizeOf(u16)));
    print("Size of c_uint: {}\n", @intCast(usize, @sizeOf(c_uint)));

    var meshes = ArrayList(Mesh).init(allocator);

    var i: usize = 0;
    while (i < aiScene.mNumMeshes) : (i += 1) {
        const mesh = aiScene.mMeshes[i];

        print("Primitive type: {}\n", mesh.mPrimitiveTypes);

        print("Mesh mVertices: {}\n", @ptrToInt(mesh.mVertices));
        print("Mesh mNormals: {}\n", @ptrToInt(mesh.mNormals));
        print("Mesh mTangents: {}\n", @ptrToInt(mesh.mTangents));
        print("Mesh mBitangents: {}\n", @ptrToInt(mesh.mBitangents));
        print("Mesh mColors: {}\n", mesh.mColors);
        print("Mesh mTextureCoords: {}\n", mesh.mTextureCoords[0]);
        print("Mesh mNumUVComponents: {}\n", mesh.mNumUVComponents[0]);
        print("Mesh mFaces: {}\n", @ptrToInt(mesh.mFaces));

        print("Mesh name {}\n", mesh.mName);

        var vertices = try allocator.alloc(Vertex, mesh.mNumVertices);
        var vertIndex: usize = 0;

        while (vertIndex < mesh.mNumVertices) : (vertIndex += 1) {
            const position = Vec3;
            vertices[vertIndex] = Vertex {
                .position = Vec3 { .data = [3]f32{
                    mesh.mVertices[vertIndex].x,
                    mesh.mVertices[vertIndex].y,
                    mesh.mVertices[vertIndex].z,
                }},
                .normal = Vec3 { .data = [3]f32{
                    mesh.mNormals.?[vertIndex].x,
                    mesh.mNormals.?[vertIndex].y,
                    mesh.mNormals.?[vertIndex].z,
                }},
                .uvCoord = Vec2 { .data = [2]f32{
                    mesh.mTextureCoords[0][vertIndex].x,
                    mesh.mTextureCoords[0][vertIndex].y
                }}
            };
        }

        var elements = try allocator.alloc(Element, mesh.mNumFaces * 3);
        var faceIndex: usize = 0;
        while (faceIndex < mesh.mNumFaces) : (faceIndex+=1) {
            const face = mesh.mFaces[faceIndex];
            var elementIndex: usize = 0;
            while (elementIndex < face.mNumIndices) : (elementIndex += 1) {
                elements[(faceIndex * 3) + elementIndex] = face.mIndices[elementIndex];
            }
        }

        try meshes.append(Mesh {
            .vertices = vertices,
            .indices = elements
        });
    }

    c.aiReleaseImport(scene);
    return meshes;
}
