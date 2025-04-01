const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");

pub const App = struct {
    pub fn mainLoop() !void {
        const w: win.Window = try win.Window.initWindow();
        defer c.glfwDestroyWindow(w.window);
        defer c.glfwTerminate();

        while (c.glfwWindowShouldClose(w.window) == 0) {
            _ = c.glfwPollEvents();
        }
    }
};
