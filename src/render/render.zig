const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");
const vk = @import("vulkan.zig");
const Allocator = std.mem.Allocator;

const Render = @This();

instance: vk.Instance,
phys_device: vk.PhysDevice,

pub fn create(arena: Allocator) !Render {
    _ = c.glfwInit();
    defer c.glfwTerminate();

    const instance = try vk.Instance.create();

    const phys_device = try vk.PhysDevice.enumerate(instance, arena);

    return Render{
        .instance = instance,
        .phys_device = phys_device,
    };
}

pub fn destroy(self: Render) void {
    self.instance.destroy();
}
