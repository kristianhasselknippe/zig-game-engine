const std = @import("std");
const print = std.debug.warn;
const c = @import("c.zig");

pub const AiLight = @OpaqueType();

pub const AiMaterial = @OpaqueType();

pub const AiReal = c.ai_real;

pub const AiVector3D = extern struct {
    x: AiReal,
    y: AiReal,
    z: AiReal,
};

pub const AiColor4D = extern struct {
    r: AiReal,
    g: AiReal,
    b: AiReal,
    a: AiReal,
};

pub const AiString = []u8;

pub const AiFace = extern struct {
    mNumIndices: c_uint,

    //! Pointer to the indices array. Size of the array is given in numIndices.
    mIndices: [*]c_uint,
};

pub const AiBone = @OpaqueType();

pub const AiAnimation = @OpaqueType();

pub const AiAnimMesh = @OpaqueType();

pub const AiCamera = @OpaqueType();

pub const AiMetadata = @OpaqueType();

pub const AiAABB = extern struct {
    mMin: AiVector3D,
    mMax: AiVector3D,
};

pub const AI_MAX_NUMBER_OF_COLOR_SETS = 0x8;
pub const AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x8;

const PrimitiveTypes = extern enum(c_uint) {
    Point = 0x1,
    Line = 0x2,
    PointLine = 0x3,
    Triangle = 0x4,
    PointTriangle = 0x5,
    LineTriangle = 0x6,
    PointLineTriangle = 0x7,
    Polygon = 0x8
};

pub const AiMesh = extern struct {
    ///Bitwise combination of the members of the #aiPrimitiveType enum.
    ///This specifies which types of primitives are present in the mesh.
    ///The "SortByPrimitiveType"-Step can be used to make sure the
    ///output meshes consist of one primitive type each.
    mPrimitiveTypes: PrimitiveTypes,

    ///The number of vertices in this mesh.
    ///This is also the size of all of the per-vertex data arrays.
    ///The maximum value for this member is #AI_MAX_VERTICES.
    mNumVertices: c_uint,

    ///The number of primitives (triangles, polygons, lines) in this  mesh.
    ///This is also the size of the mFaces array.
    ///The maximum value for this member is #AI_MAX_FACES.
    mNumFaces: c_uint,

    ///Vertex positions.
    ///This array is always present in a mesh. The array is
    ///mNumVertices in size.
    mVertices: [*]AiVector3D,

    ///Vertex normals.
    ///The array contains normalized vectors, NULL if not present.
    ///The array is mNumVertices in size. Normals are undefined for
    ///point and line primitives. A mesh consisting of points and
    ///lines only may not have normal vectors. Meshes with mixed
    ///primitive types (i.e. lines and triangles) may have normals,
    ///but the normals for vertices that are only referenced by
    ///point or line primitives are undefined and set to QNaN (WARN:
    ///qNaN compares to inequal to *everything*, even to qNaN itself.
    ///Using code like this to check whether a field is qnan is:
    ///@code
    ///#define IS_QNAN(f) (f != f)
    ///@endcode
    ///still dangerous because even 1.f == 1.f could evaluate to false! (
    ///remember the subtleties of IEEE754 artithmetics). Use stuff like
    ///@c fpclassify instead.
    ///@note Normal vectors computed by Assimp are always unit-length.
    ///However, this needn't apply for normals that have been taken
    ///  directly from the model file.
    mNormals: ?[*]AiVector3D,

    ///Vertex tangents.
    ///The tangent of a vertex points in the direction of the positive
    ///X texture axis. The array contains normalized vectors, NULL if
    ///not present. The array is mNumVertices in size. A mesh consisting
    ///of points and lines only may not have normal vectors. Meshes with
    ///mixed primitive types (i.e. lines and triangles) may have
    ///normals, but the normals for vertices that are only referenced by
    ///point or line primitives are undefined and set to qNaN.  See
    ///the #mNormals member for a detailed discussion of qNaNs.
    ///@note If the mesh contains tangents, it automatically also
    ///contains bitangents.
    mTangents: ?[*]AiVector3D,

    ///Vertex bitangents.
    ///The bitangent of a vertex points in the direction of the positive
    ///Y texture axis. The array contains normalized vectors, NULL if not
    ///present. The array is mNumVertices in size.
    ///@note If the mesh contains tangents, it automatically also contains
    ///bitangents.
    mBitangents: ?[*]AiVector3D,

    ///Vertex color sets.
    ///A mesh may contain 0 to #AI_MAX_NUMBER_OF_COLOR_SETS vertex
    ///colors per vertex. NULL if not present. Each array is
    ///mNumVertices in size if present.
    mColors: [AI_MAX_NUMBER_OF_COLOR_SETS]*AiColor4D,

    ///Vertex texture coords, also known as UV channels.
    ///A mesh may contain 0 to AI_MAX_NUMBER_OF_TEXTURECOORDS per
    ///vertex. NULL if not present. The array is mNumVertices in size.
    mTextureCoords: [AI_MAX_NUMBER_OF_TEXTURECOORDS][*]AiVector3D,

    ///Specifies the number of components for a given UV channel.
    ///Up to three channels are supported (UVW, for accessing volume
    ///or cube maps). If the value is 2 for a given channel n, the
    ///component p.z of mTextureCoords[n][p] is set to 0.0f.
    ///If the value is 1 for a given channel, p.y is set to 0.0f, too.
    ///@note 4D coords are not supported
    mNumUVComponents: [AI_MAX_NUMBER_OF_TEXTURECOORDS]c_uint,

    ///The faces the mesh is constructed from.
    ///Each face refers to a number of vertices by their indices.
    ///This array is always present in a mesh, its size is given
    ///in mNumFaces. If the #AI_SCENE_FLAGS_NON_VERBOSE_FORMAT
    ///is NOT set each face references an unique set of vertices.
    mFaces: [*]AiFace,

    ///The number of bones this mesh contains.
    ///Can be 0, in which case the mBones array is NULL.
    mNumBones: c_uint,

    ///The bones of this mesh.
    ///A bone consists of a name by which it can be found in the
    ///frame hierarchy and a set of vertex weights.
    mBones: ?**AiBone,

    ///The material used by this mesh.
    ///A mesh uses only a single material. If an imported model uses
    ///multiple materials, the import splits up the mesh. Use this value
    ///as index into the scene's material list.
    mMaterialIndex: c_uint,

    ///Name of the mesh. Meshes can be named, but this is not a
    /// requirement and leaving this field empty is totally fine.
    /// There are mainly three uses for mesh names:
    ///  - some formats name nodes and meshes independently.
    ///  - importers tend to split meshes up to meet the
    ///     one-material-per-mesh requirement. Assigning
    ///     the same (dummy) name to each of the result meshes
    ///     aids the caller at recovering the original mesh
    ///     partitioning.
    ///  - Vertex animations refer to meshes by their names.
    mName: *AiString,

    ///The number of attachment meshes. Note! Currently only works with Collada loader. */
    mNumAnimMeshes: c_uint,

    ///Attachment meshes for this mesh, for vertex-based animation.
    /// Attachment meshes carry replacement data for some of the
    /// mesh'es vertex components (usually positions, normals).
    /// Note! Currently only works with Collada loader.*/
    mAnimMeshes: **AiAnimMesh,

    ///Method of morphing when animeshes are specified.
    mMethod: c_uint,

    mAABB: AiAABB,
};

pub const AiNode = @OpaqueType();

pub const AiTexture = @OpaqueType();

pub const AiScene = extern struct {
    ///Any combination of the AI_SCENE_FLAGS_XXX flags. By default
    ///this value is 0, no flags are set. Most applications will
    ///want to reject all scenes with the AI_SCENE_FLAGS_INCOMPLETE
    ///bit set.
    mFlags: c_uint,

    ///The root node of the hierarchy.
    ///
    ///There will always be at least the root node if the import
    ///was successful (and no special flags have been set).
    ///Presence of further nodes depends on the format and content
    ///of the imported file.
    mRootNode: *AiNode,

    ///The number of meshes in the scene.
    mNumMeshes: c_uint,

    ///The array of meshes.
    ///
    ///Use the indices given in the aiNode structure to access
    ///this array. The array is mNumMeshes in size. If the
    ///AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
    ///be at least ONE material.
    mMeshes: [*]*AiMesh,

    ///The number of materials in the scene.
    mNumMaterials: c_uint,

    ///The array of materials.
    ///
    ///Use the index given in each aiMesh structure to access this
    ///array. The array is mNumMaterials in size. If the
    ///AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
    ///be at least ONE material.
    mMaterials: **AiMaterial,

    ///The number of animations in the scene.
    mNumAnimations: c_uint,

    ///The array of animations.
    ///
    ///All animations imported from the given file are listed here.
    ///The array is mNumAnimations in size.
    mAnimations: **AiAnimation,

    ///The number of textures embedded into the file
    mNumTextures: c_uint,

    ///The array of embedded textures.
    ///
    ///Not many file formats embed their textures into the file.
    ///An example is Quake's MDL format (which is also used by
    ///some GameStudio versions)
    mTextures: **AiTexture,

    ///The number of light sources in the scene. Light sources
    ///are fully optional, in most cases this attribute will be 0
    mNumLights: c_uint,

    ///The array of light sources.
    ///
    ///All light sources imported from the given file are
    ///listed here. The array is mNumLights in size.
    mLights: **AiLight,

    ///The number of cameras in the scene. Cameras
    ///are fully optional, in most cases this attribute will be 0
    mNumCameras: c_uint,

    ///The array of cameras.
    ///
    ///All cameras imported from the given file are listed here.
    ///The Givenarray is mNumCameras in size. The first camera in the
    ///array (if existing) is the default camera view into
    ///the scene.
    mCameras: **AiCamera,

    ///@brief  The global metadata assigned to the scene itself.
    ///
    ///This data contains global metadata which belongs to the scene like
    ///unit-conversions, versions, vendors or other model-specific data. This
    ///can be used to store format-specific metadata as well.
    mMetaData: *AiMetadata,
};
