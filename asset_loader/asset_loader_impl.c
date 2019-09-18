#include "asset_loader.h"
#include <stdlib.h>

extern bool importAssetFile(const char* file_content) {
	printf("Trying to make something happen \n");
	const struct aiScene* scene = aiImportFile(file_content,
											   aiProcess_CalcTangentSpace
											   | aiProcess_Triangulate
											   | aiProcess_JoinIdenticalVertices
											   | aiProcess_SortByPType);
	// If the import failed, report it
	if(!scene) {
		printf("Error importing scene\n");
		return false;
	}

	printf("Number of meshes: %i\n", scene->mNumMeshes);

	Mesh* meshes = (Mesh*)malloc(sizeof(Mesh) * scene->mNumMeshes);

	for (int i = 0; i < scene->mNumMeshes; i++){
		// Now we can access the file's contents
		struct aiMesh* mesh = scene->mMeshes[i];
		Vertex* vertices = malloc(sizeof(Vertex) * mesh->mNumVertices);
		for (int x = 0; x < mesh->mNumVertices; x++) {
			vertices[x].position.x = mesh->mVertices[x].x;
			vertices[x].position.y = mesh->mVertices[x].y;
			vertices[x].position.z = mesh->mVertices[x].z;
			vertices[x].normal.x = mesh->mNormals[x].x;
			vertices[x].normal.y = mesh->mNormals[x].y;
			vertices[x].normal.z = mesh->mNormals[x].z;
			vertices[x].uv.x = mesh->mTextureCoords[0][x].x;
			vertices[x].uv.y = mesh->mTextureCoords[0][x].y;
		}

		unsigned int* elements = malloc(sizeof(unsigned int) * mesh->mNumFaces * 3);
		for (int faceIndex = 0; faceIndex < mesh->mNumFaces; faceIndex++) {
			struct aiFace face = mesh->mFaces[faceIndex];
			for (int elementIndex = 0; elementIndex < face.mNumIndices; elementIndex++) {
				elements[(faceIndex * 3) + elementIndex] = face.mIndices[elementIndex];
			}
		}

		meshes[i].vertices = vertices;
		meshes[i].elements = elements;
	}

	//*out = meshes;

	// We're done. Release all resources associated with this import
	aiReleaseImport( scene);
	return true;
}
