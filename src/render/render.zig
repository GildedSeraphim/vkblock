const std = @import("std");
const vk = @import("vulkan.zig");
const c = @import("../clibs.zig");
const Allocator = std.mem.Allocator;

pub fn create() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const instance = try vk.createInstance();
    defer vk.destroyInstance(instance);

    try vk.callVersion();

    const physical_device = try vk.pickPhysicalDevice(allocator, instance);
    vk.getDeviceName(physical_device);

    const logical_device = try vk.createLogicalDevice(physical_device);
    defer vk.destroyLogicalDevice(logical_device);
}
