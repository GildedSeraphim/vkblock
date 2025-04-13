const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");
const vk = @import("vulkan.zig");
const Allocator = std.mem.Allocator;

const Render = @This();

instance: vk.Instance,

pub fn create() !Render {
    _ = c.glfwInit();
    defer c.glfwTerminate();

    const instance = try vk.Instance.create();

    return Render{
        .instance = instance,
    };
}

pub fn destroy(self: Render) void {
    self.instance.destroy();
}
