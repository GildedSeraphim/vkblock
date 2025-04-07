const std = @import("std");
const c = @import("clibs.zig");
const render = @import("render/render.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    std.debug.print("Hello Vulkan Triangle! \n", .{});

    if (gpa.detectLeaks()) {
        return error.leaked_memory;
    }
}
