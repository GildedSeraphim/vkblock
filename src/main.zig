const std = @import("std");
const c = @import("clibs.zig");

pub fn main() !void {
    if (c.glfwInit() == 0) {
        std.debug.print("Failed to initialize GLFW\n", .{});
        return error.GLFWInitializationFailed;
    }
    defer c.glfwTerminate();

    const window: ?*c.GLFWwindow = c.glfwCreateWindow(800, 600, "Vulkan Window", null, null);

    if (window == null) {
        std.debug.print("Failed to create GLFW window\n", .{});
        return error.GLFWWindowCreationFailed;
    }

    var extension_count: u32 = 0;
    _ = c.vkEnumerateInstanceExtensionProperties(null, &extension_count, null);

    std.debug.print("{d} extensions supported\n", .{extension_count});

    while (c.glfwWindowShouldClose(window) == 0) {
        _ = c.glfwPollEvents();
    }

    c.glfwDestroyWindow(window);
    std.debug.print("Window destroyed.\n", .{});
}
