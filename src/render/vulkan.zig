const std = @import("std");
const c = @import("../clibs.zig");
const window = @import("window.zig");

const Allocator = std.mem.Allocator;

const builtin = @import("builtin");
const debug = (builtin.mode == .Debug);

const validation_layers: []const [*c]const u8 = if (!debug) &[0][*c]const u8{} else &[_][*c]const u8{
    "VK_LAYER_KHRONOS_validation",
};

const device_extensions: []const [*c]const u8 = &[_][*c]const u8{
    //c.VK_KHR_SWAPCHAIN_EXTENSION_NAME,
};

pub fn callVersion() !void {
    var api_version: u32 = 0;
    try mapError(c.vkEnumerateInstanceVersion(&api_version));

    const major = api_version >> 22;
    const minor = (api_version >> 12) & 0x3FF;
    const patch = (api_version >> 0) & 0xFFF;

    std.debug.print("Vulkan API Version: {}.{}.{}\n", .{ major, minor, patch });
}

// ### Instance Creation ###
//----------------------------------------------------------------------------//
pub const Instance = struct {
    handle: c.VkInstance = null,
    debug_messenger: c.VkDebugUtilsMessengerEXT = null,
};

pub fn createInstance() !Instance {
    //  const extensions = window.getExtensions();
    const app_info: c.VkApplicationInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pNext = null,
        .pApplicationName = "VkBlock",
        .applicationVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .pEngineName = "Doa",
        .engineVersion = c.VK_MAKE_VERSION(1, 0, 0),
        .apiVersion = c.VK_API_VERSION_1_4,
    };

    const create_info: c.VkInstanceCreateInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
        .enabledExtensionCount = 0,
        .ppEnabledExtensionNames = null,
        .enabledLayerCount = @intCast(validation_layers.len),
        .ppEnabledLayerNames = validation_layers.ptr,
    };

    var instance: c.VkInstance = undefined;

    try mapError(c.vkCreateInstance(&create_info, null, &instance));

    return Instance{
        .handle = instance,
    };
}

pub fn destroyInstance(i: Instance) void {
    c.vkDestroyInstance(i.handle, null);
}
//----------------------------------------------------------------------------//

// ### Physical Device ###
//----------------------------------------------------------------------------//
pub const PhysicalDevice = struct {
    handle: c.VkPhysicalDevice,
};

pub fn pickPhysicalDevice(allocator: Allocator, instance: Instance) !PhysicalDevice {
    var device_count: u32 = 0;
    try mapError(c.vkEnumeratePhysicalDevices(instance.handle, &device_count, null));
    if (device_count == 0) {
        return error.no_physical_devices_found;
    }
    const devices = try allocator.alloc(c.VkPhysicalDevice, device_count);
    defer allocator.free(devices);
    try mapError(c.vkEnumeratePhysicalDevices(instance.handle, &device_count, @ptrCast(devices)));

    return PhysicalDevice{
        .handle = devices[0],
    };
}

pub fn isDeviceSuitable() bool {
    return true;
}

pub fn getDeviceName(pd: PhysicalDevice) void {
    var device_properties: c.VkPhysicalDeviceProperties = undefined;
    c.vkGetPhysicalDeviceProperties(pd.handle, &device_properties);

    const device_name = device_properties.deviceName;
    std.debug.print("Chosen Physical Device: {s}\n", .{device_name});
}
//----------------------------------------------------------------------------//

// ### Logical Device ###
//----------------------------------------------------------------------------//
pub const Device = struct {
    handle: c.VkDevice,
};

// Device Usage
//    Creation of queues. See the Queues section below for further details.
//    Creation and tracking of various synchronization constructs. See Synchronization and Cache Control for further details.
//    Allocating, freeing, and managing memory. See Memory Allocation and Resource Creation for further details.
//    Creation and destruction of command buffers and command buffer pools. See Command Buffers for further details.
//    Creation, destruction, and management of graphics state. See Pipelines and Resource Descriptors, among others, for further details.

pub fn createLogicalDevice(pd: PhysicalDevice) !Device {
    const priority: f32 = 1.0;
    const device_queue: c.VkDeviceQueueCreateInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .pNext = null,
        .queueFamilyIndex = 0,
        .queueCount = 1,
        .pQueuePriorities = &priority,
    };

    const device_features: c.VkPhysicalDeviceFeatures2 = .{
        .sType = c.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2,
    };

    const create_info: c.VkDeviceCreateInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .pNext = &device_features,
        .queueCreateInfoCount = 1,
        .pQueueCreateInfos = &device_queue,
        .enabledExtensionCount = @as(u32, @intCast(device_extensions.len)),
        .ppEnabledExtensionNames = device_extensions.ptr,
    };

    var device: c.VkDevice = undefined;

    try mapError(c.vkCreateDevice(pd.handle, &create_info, null, &device));

    return Device{
        .handle = device,
    };
}

pub fn destroyLogicalDevice(self: Device) void {
    c.vkDestroyDevice(self.handle, null);
}
//----------------------------------------------------------------------------//

// Helper Functions and Notes Below
//
// TODO: Add criteria for choosing physical_device
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

// Mapping error from Vulkan's format to zig format
//----------------------------------------------------------------------------//
pub fn mapError(result: c_int) !void {
    return switch (result) {
        c.VK_SUCCESS => {},
        c.VK_NOT_READY => error.vk_not_ready,
        c.VK_TIMEOUT => error.vk_timeout,
        c.VK_EVENT_SET => error.vk_event_set,
        c.VK_EVENT_RESET => error.vk_event_reset,
        c.VK_INCOMPLETE => error.vk_incomplete,
        c.VK_ERROR_OUT_OF_HOST_MEMORY => error.vk_error_out_of_host_memory,
        c.VK_ERROR_OUT_OF_DEVICE_MEMORY => error.vk_error_out_of_device_memory,
        c.VK_ERROR_INITIALIZATION_FAILED => error.vk_error_initialization_failed,
        c.VK_ERROR_DEVICE_LOST => error.vk_error_device_lost,
        c.VK_ERROR_MEMORY_MAP_FAILED => error.vk_error_memory_map_failed,
        c.VK_ERROR_LAYER_NOT_PRESENT => error.vk_error_layer_not_present,
        c.VK_ERROR_EXTENSION_NOT_PRESENT => error.vk_error_extension_not_present,
        c.VK_ERROR_FEATURE_NOT_PRESENT => error.vk_error_feature_not_present,
        c.VK_ERROR_INCOMPATIBLE_DRIVER => error.vk_error_incompatible_driver,
        c.VK_ERROR_TOO_MANY_OBJECTS => error.vk_error_too_many_objects,
        c.VK_ERROR_FORMAT_NOT_SUPPORTED => error.vk_error_format_not_supported,
        c.VK_ERROR_FRAGMENTED_POOL => error.vk_error_fragmented_pool,
        c.VK_ERROR_UNKNOWN => error.vk_error_unknown,
        c.VK_ERROR_OUT_OF_POOL_MEMORY => error.vk_error_out_of_pool_memory,
        c.VK_ERROR_INVALID_EXTERNAL_HANDLE => error.vk_error_invalid_external_handle,
        c.VK_ERROR_FRAGMENTATION => error.vk_error_fragmentation,
        c.VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS => error.vk_error_invalid_opaque_capture_address,
        c.VK_PIPELINE_COMPILE_REQUIRED => error.vk_pipeline_compile_required,
        c.VK_ERROR_SURFACE_LOST_KHR => error.vk_error_surface_lost_khr,
        c.VK_ERROR_NATIVE_WINDOW_IN_USE_KHR => error.vk_error_native_window_in_use_khr,
        c.VK_SUBOPTIMAL_KHR => error.vk_suboptimal_khr,
        c.VK_ERROR_OUT_OF_DATE_KHR => error.vk_error_out_of_date_khr,
        c.VK_ERROR_INCOMPATIBLE_DISPLAY_KHR => error.vk_error_incompatible_display_khr,
        c.VK_ERROR_VALIDATION_FAILED_EXT => error.vk_error_validation_failed_ext,
        c.VK_ERROR_INVALID_SHADER_NV => error.vk_error_invalid_shader_nv,
        c.VK_ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR => error.vk_error_image_usage_not_supported_khr,
        c.VK_ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR => error.vk_error_video_picture_layout_not_supported_khr,
        c.VK_ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR => error.vk_error_video_profile_operation_not_supported_khr,
        c.VK_ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR => error.vk_error_video_profile_format_not_supported_khr,
        c.VK_ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR => error.vk_error_video_profile_codec_not_supported_khr,
        c.VK_ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR => error.vk_error_video_std_version_not_supported_khr,
        c.VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT => error.vk_error_invalid_drm_format_modifier_plane_layout_ext,
        c.VK_ERROR_NOT_PERMITTED_KHR => error.vk_error_not_permitted_khr,
        c.VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT => error.vk_error_full_screen_exclusive_mode_lost_ext,
        c.VK_THREAD_IDLE_KHR => error.vk_thread_idle_khr,
        c.VK_THREAD_DONE_KHR => error.vk_thread_done_khr,
        c.VK_OPERATION_DEFERRED_KHR => error.vk_operation_deferred_khr,
        c.VK_OPERATION_NOT_DEFERRED_KHR => error.vk_operation_not_deferred_khr,
        c.VK_ERROR_COMPRESSION_EXHAUSTED_EXT => error.vk_error_compression_exhausted_ext,
        c.VK_ERROR_INCOMPATIBLE_SHADER_BINARY_EXT => error.vk_error_incompatible_shader_binary_ext,
        else => error.vk_errror_unknown,
    };
}
//----------------------------------------------------------------------------//
