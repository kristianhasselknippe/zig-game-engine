#include "asset_loader.h"

extern bool importAssetFile(const char* file_content, Mesh* out) {
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
	// Now we can access the file's contents
	Mesh mesh = {
				 .vertices = NULL,
				 .elements = NULL
	};
	// We're done. Release all resources associated with this import
	aiReleaseImport( scene);
	return true;
}
