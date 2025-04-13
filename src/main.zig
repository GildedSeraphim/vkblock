const std = @import("std");
const c = @import("clibs.zig");
const render = @import("render/render.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    std.debug.print("Hello Vulkan Triangle! \n", .{});

    const r = try render.create(allocator);
    defer render.destroy(r);

    if (gpa.detectLeaks()) {
        return error.leaked_memory;
    }
}
