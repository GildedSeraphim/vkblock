pub usingnamespace @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cDefine("VK_NO_PROTOTYPES", {});
    @cInclude("vulkan/vulkan.h");
    @cInclude("cglm/mat4.h");
    @cInclude("cglm/vec4.h");
    @cInclude("GLFW/glfw3.h");
    // @cInclude("SDL2/SDL.h");
    // @cInclude("SDL2/SDL_vulkan.h");
});
