const c = @import("c.zig");
const std = @import("std");
const assimp = @import("assimp.zig");
const print = std.debug.warn;

pub fn importSomething() void {
    const objFile = @embedFile("./assets/models/teapot.obj");
    print("Obj file len {}", objFile.len);

    const scene = c.aiImportFileFromMemory(&objFile[0], objFile.len, @enumToInt(c.aiProcess_CalcTangentSpace) |
                                               @enumToInt(c.aiProcess_Triangulate) |
                                               @enumToInt(c.aiProcess_JoinIdenticalVertices) |
                                               @enumToInt(c.aiProcess_SortByPType), c"obj");
    const aiScene = @ptrCast(*const assimp.AiScene, scene);

    print("Size of u16: {}\n", @intCast(usize, @sizeOf(u16)));
    print("Size of c_uint: {}\n", @intCast(usize, @sizeOf(c_uint)));

    print("Scene: {} \n", aiScene);
    var i: usize = 0;
    while (i < aiScene.mNumMeshes) : (i += 1) {
        const mesh = aiScene.mMeshes[i];

        print("Mesh: {}\n", mesh);
        print("Primitive type: {}\n", mesh.mPrimitiveTypes);

        print("Mesh mVertices: {}\n", @ptrToInt(mesh.mVertices));
        print("Mesh mNormals: {}\n", @ptrToInt(mesh.mNormals));
        print("Mesh mTangents: {}\n", @ptrToInt(mesh.mTangents));
        print("Mesh mBitangents: {}\n", @ptrToInt(mesh.mBitangents));
        print("Mesh mColors: {}\n", mesh.mColors);
        print("Mesh mTextureCoords: {}\n", mesh.mTextureCoords);
        print("Mesh mNumUVComponents: {}\n", mesh.mNumUVComponents);
        print("Mesh mFaces: {}\n", @ptrToInt(mesh.mFaces));

        print("Mesh name {}\n", mesh.mName);

        var vertIndex: usize = 0;
        while (vertIndex < mesh.mNumVertices) : (vertIndex += 1) {
            const vertex = mesh.mVertices[vertIndex];
            //print("Vertex: {}\n", vertex);
            
        }

        if (mesh.mNormals) | normals | {
            //print("Num normals {}\n", mesh.mNumVertices);
            var normIndex: usize = 0;
            while (normIndex < mesh.mNumVertices) : (normIndex += 1) {
                const norm = normals[normIndex];
                //print("Norm {}\n", norm);
            }
        }

        print("Size of mesh: {}\n", @intCast(usize, @sizeOf(assimp.AiMesh)));
        print("Size of AiColor4D: {}\n", @intCast(usize, @sizeOf(assimp.AiColor4D)));
        print("Size of Vec3: {}\n", @intCast(usize, @sizeOf(assimp.AiVector3D)));
        print("Size of [*]AiFace: {}\n", @intCast(usize, @sizeOf([*]assimp.AiFace)));
        print("Offset of mNormals: {}:\n", @intCast(usize, @byteOffsetOf(assimp.AiMesh, "mNormals")));
        print("Offset of mColors: {}:\n", @intCast(usize, @byteOffsetOf(assimp.AiMesh, "mColors")));
        print("Offset of mtexturecoords: {}:\n", @intCast(usize, @byteOffsetOf(assimp.AiMesh, "mTextureCoords")));
        print("Offset of mFaces: {}:\n", @intCast(usize, @byteOffsetOf(assimp.AiMesh, "mFaces")));
        print("AI_MAX_NUMBER_OF_COLOR_SETS: {}:\n", @intCast(usize, assimp.AI_MAX_NUMBER_OF_COLOR_SETS));
        print("Size of AiColor4D: {}\n", @intCast(usize, @sizeOf(assimp.AiColor4D)));
        
        print("Faces: {}\n", &mesh.mFaces[0]);
        print("Num faces {}\n", mesh.mNumFaces);

        var faceIndex: usize = 0;
        while (faceIndex < mesh.mNumFaces) : (faceIndex+=1) {
            print("Foo\n");
            const face = mesh.mFaces[faceIndex];
            print("Bar\n");
            print("About to read a face: {}\n", face);
            print("Face {}\n", face.mNumIndices);
        }
    }

    c.aiReleaseImport(scene);
}
