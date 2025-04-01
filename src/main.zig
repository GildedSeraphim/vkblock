const std = @import("std");
const c = @import("clibs.zig");
const render = @import("render/render.zig");

pub fn main() !void {
    try render.App.mainLoop();
}
