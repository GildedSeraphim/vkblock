const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");
const vulkan = @import("vulkan.zig");

pub const App = struct {
    pub fn mainLoop() !void {
        // Vulkan Initialization
        const vk = try vulkan.Vulk.initVulkan();
        defer vk.cleanup();

        // GLFW Initialization
        const w: win.Window = try win.Window.initWindow();
        defer c.glfwDestroyWindow(w.window);
        defer c.glfwTerminate();

        while (c.glfwWindowShouldClose(w.window) == 0) {
            _ = c.glfwPollEvents();
        }
    }
};
