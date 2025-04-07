const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("window.zig");
const vulkan = @import("vulkan.zig");
const Allocator = std.mem.Allocator;

const Render = @This();

instance: c.VkInstance,

pub fn create() !Render {
    const instance = vk.instance.create();
}

pub fn destroy() !Render {}
