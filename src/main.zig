const std = @import("std");
const c = @import("clibs.zig");
const render = @import("render/render.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    std.debug.print("Hello Vulkan Triangle! \n", .{});

    const r = try render.create();
    defer render.destroy(r);

    if (gpa.detectLeaks()) {
        return error.leaked_memory;
    }
}
