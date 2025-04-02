const std = @import("std");
const c = @import("clibs.zig");
const render = @import("render/render.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();
    {
        try render.App.mainLoop(allocator);
    }

    if (gpa.detectLeaks()) {
        return error.leaked_memory;
    }
}
