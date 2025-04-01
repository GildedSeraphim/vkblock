const std = @import("std");
const c = @import("../clibs.zig");

pub const Window = struct {
    window: ?*c.GLFWwindow,

    pub fn initWindow() !Window {
        _ = c.glfwInit();

        c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
        c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_FALSE);

        const window = c.glfwCreateWindow(800, 600, "vulkan", null, null);

        return Window{
            .window = window,
        };
    }
};
