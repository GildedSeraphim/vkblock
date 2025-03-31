const std = @import("std");
const c = @import("clibs.zig");
//a line
pub fn main() !void {
    if (c.glfwInit() == 0) {
        return error.GLFWInitializationFailed;
    }
    defer c.glfwTerminate();
    _ = c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
    _ = c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 1);
    _ = c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 0);

    const window: ?*c.GLFWwindow = c.glfwCreateWindow(800, 600, "Vulkan Window", null, null);

    if (window == null) {
        return error.GLFWWindowCreationFailed;
    }

    _ = c.glfwMakeContextCurrent(window);

    var extension_count: u32 = 0;
    const extensions: [*c][*c]const u8 = c.glfwGetRequiredInstanceExtensions(&extension_count);

    const appInfo = c.VkApplicationInfo{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Vulkan Window",
        .applicationVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .pEngineName = "No Engine",
        .engineVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_4,
    };

    const createInfo = c.VkInstanceCreateInfo{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &appInfo,
        .enabledExtensionCount = extension_count,
        .ppEnabledExtensionNames = extensions,
    };

    var instance: c.VkInstance = undefined;
    if (c.vkCreateInstance(&createInfo, null, &instance) != c.VK_SUCCESS) {
        return error.failedToCreateVulkanInstance;
    }

    var surface: c.VkSurfaceKHR = undefined;
    if (c.glfwCreateWindowSurface(instance, window, null, &surface) != c.VK_SUCCESS) {
        return error.failedToCreateWindowSurface;
    }
    defer c.vkDestroySurfaceKHR(instance, surface, null);
    defer c.vkDestroyInstance(instance, null);

    while (c.glfwWindowShouldClose(window) == 0) {
        _ = c.glfwPollEvents();
    }
}
