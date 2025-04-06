const std = @import("std");
const c = @import("clibs.zig");
const render = @import("render/render.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    if (gpa.detectLeaks()) {
        return error.leaked_memory;
    }
}
