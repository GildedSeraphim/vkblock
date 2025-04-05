const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");
const vulkan = @import("vulkan.zig");
const Allocator = std.mem.Allocator;

pub const App = struct {
    pub fn mainLoop(allocator: Allocator) !void {
        // GLFW Initialization
        const w: win.Window = try win.Window.initWindow();
        defer c.glfwDestroyWindow(w.window);
        defer c.glfwTerminate();

        // Vulkan Initialization
        const vk = try vulkan.Vulk.initVulkan(allocator, w);
        defer vk.cleanup();

        while (c.glfwWindowShouldClose(w.window) == 0) {
            _ = c.glfwPollEvents();
        }
    }
};
