const std = @import("std");
const c = @import("clibs.zig");

pub const Error = error{
    out_of_host_memory,
    out_of_device_memory,
    initialization_failed,
    layer_not_present,
    extension_not_present,
    incompatible_driver,
    unknown_error,
};

pub fn mapError(result: c_int) !void {
    return switch (result) {
        c.VK_SUCCESS => {},
        c.VK_ERROR_OUT_OF_HOST_MEMORY => Error.out_of_host_memory,
        c.VK_ERROR_OUT_OF_DEVICE_MEMORY => Error.out_of_device_memory,
        c.VK_ERROR_INITIALIZATION_FAILED => Error.initialization_failed,
        c.VK_ERROR_LAYER_NOT_PRESENT => Error.layer_not_present,
        c.VK_ERROR_EXTENSION_NOT_PRESENT => Error.extension_not_present,
        c.VK_ERROR_INCOMPATIBLE_DRIVER => Error.incompatible_driver,
        else => Error.unknown_error,
    };
}

pub fn main() !void {
    // Initialize Vulkan application info
    const app_info: c.VkApplicationInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Vulkan Version Checker",
        .applicationVersion = 1, // Optional, set to version 1 for this example
        .pEngineName = "No Engine", // Optional
        .engineVersion = 1, // Optional
        .apiVersion = c.VK_API_VERSION_1_0, // Vulkan 1.0
    };

    // Initialize Vulkan instance creation info
    const create_info: c.VkInstanceCreateInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
    };

    var instance: c.VkInstance = undefined;

    // Create Vulkan instance
    try mapError(c.vkCreateInstance(&create_info, null, &instance));
    defer c.vkDestroyInstance(instance, null);

    // Retrieve Vulkan API version
    var version: u32 = undefined;
    try mapError(c.vkEnumerateInstanceVersion(&version));

    // Extract major, minor, and patch version numbers
    const major = c.VK_VERSION_MAJOR(version);
    const minor = c.VK_VERSION_MINOR(version);
    const patch = c.VK_VERSION_PATCH(version);

    // Print the Vulkan version
    std.debug.print("Vulkan Version :: {d}.{d}.{d}\n", .{ major, minor, patch });
}
