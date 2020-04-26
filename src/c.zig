pub usingnamespace @cImport({
    @cInclude("stdio.h");
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
    @cInclude("asset_loader.h");
    @cDefine("STBI_ONLY_PNG", "");
    @cDefine("STBI_NO_STDIO", "");
    @cInclude("stb_image.h");
});
