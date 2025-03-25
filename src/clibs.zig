pub usingnamespace @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("vulkan/vulkan.h");
    @cInclude("cglm/mat4.h");
    @cInclude("cglm/vec4.h");
    @cInclude("GLFW/glfw3.h");
});
