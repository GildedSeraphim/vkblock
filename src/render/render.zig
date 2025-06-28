const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");
const vk = @import("vulkan.zig");
const Allocator = std.mem.Allocator;

const Render = @This();

instance: vk.Instance,
window: win.Window,
surface: vk.Surface,
phys_device: vk.PhysDevice,
device: vk.Device,
swapchain: vk.Swapchain,

pub fn create(arena: Allocator) !Render {
    _ = c.glfwInit();
    defer c.glfwTerminate();

    const instance = try vk.Instance.create();

    const window = try win.Window.create(800, 600, "Vulkan");
    const surface = try vk.Surface.create(instance, window);

    const phys_device = try vk.PhysDevice.enumerate(instance, arena);
    const device = try vk.Device.create(phys_device, arena, surface);

    const swapch = try vk.Swapchain.create(device, surface);

    return Render{
        .instance = instance,
        .window = window,
        .surface = surface,
        .phys_device = phys_device,
        .device = device,
        .swapchain = swapch,
    };
}

pub fn destroy(self: Render) void {
    self.device.destroy();
    self.surface.destroy(self.instance);
    self.window.destroy();
    self.instance.destroy();
}
