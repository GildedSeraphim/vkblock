const std = @import("std");
const c = @import("clibs.zig");

pub const app = struct {
    pub fn run() !void {
        try initVulkan();
        try mainLoop();
        try cleanup();
    }

    fn initVulkan() !void {}

    fn mainLoop() !void {}

    fn cleanup() !void {}
};
