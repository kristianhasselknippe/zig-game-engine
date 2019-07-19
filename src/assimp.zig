const std = @import("std");
const print = std.debug.warn;

pub const AiLight = @OpaqueType();

pub const AiMaterial = @OpaqueType();

pub const AiMesh = @OpaqueType();

pub const AiNode = @OpaqueType();

pub const AiTexture = @OpaqueType();

pub const AiScene = extern struct {
    mFlags: c_uint,

    mRootNode: *c_void,

    mNumMeshes: c_uint,
    mMeshes: *AiMesh,

    mNumMaterials: c_uint,
    mMaterials: *AiMaterial,

    mNumAnimations: c_uint,
    mAnimations: *c_void,

    mNumTextures: c_uint,
    mTextures: *AiTexture,

    mNumLights: c_uint,
    mLights: *AiLight,

    mNumCameras: c_uint,
    mCameras: **c_void,

    mPrivate: *c_void,
};
