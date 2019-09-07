pub use @cImport({
    @cInclude("stdio.h");
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
    @cInclude("assimp/cimport.h");
    @cInclude("assimp/scene.h");
    @cInclude("assimp/postprocess.h");
    @cDefine("STBI_ONLY_PNG", "");
    @cDefine("STBI_NO_STDIO", "");
    @cInclude("stb_image.h");
    @cInclude("asset_loader.h");
});
