#include <assimp/cimport.h>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>

typedef struct {
	float x;
	float y;
	float z;
} Vec3;

typedef struct {
	float x;
	float y;
} Vec2;

typedef struct {
	Vec3 position;
	Vec3 normal;
	Vec2 uv;
} Vertex;

typedef struct {
	Vertex* vertices;
	unsigned int* elements;
} Mesh;

typedef struct {
	Mesh* meshes;
} Model;

extern bool importAssetFile(const char* file_content, Mesh* out);
