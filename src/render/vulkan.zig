const std = @import("std");
const c = @import("../clibs.zig");
const win = @import("./window.zig");
const Allocator = std.mem.Allocator;
const window = @import("window.zig");

const builtin = @import("builtin");
const debug = (builtin.mode == .Debug);

const validation_layers: []const [*c]const u8 = if (!debug) &[0][*c]const u8{} else &[_][*c]const u8{
    "VK_LAYER_KHRONOS_validation",
};

const device_extensions: []const [*c]const u8 = &[_][*c]const u8{
    c.VK_KHR_SWAPCHAIN_EXTENSION_NAME,
};

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

pub const Instance = struct {
    handle: c.VkInstance,

    pub fn create() !Instance {
        const extensions = win.getExtensions();

        const app_info: c.VkApplicationInfo = .{
            .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .apiVersion = c.VK_API_VERSION_1_4,
            .engineVersion = c.VK_MAKE_VERSION(1, 0, 0),
            .pEngineName = "Idk man its an engine",
            .applicationVersion = c.VK_MAKE_VERSION(1, 0, 0),
            .pApplicationName = "Vulkan app",
        };

        const create_info: c.VkInstanceCreateInfo = .{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &app_info,
            .enabledLayerCount = @intCast(validation_layers.len),
            .ppEnabledLayerNames = validation_layers.ptr,
            .enabledExtensionCount = @intCast(extensions.len),
            .ppEnabledExtensionNames = extensions.ptr,
        };

        var instance: c.VkInstance = undefined;

        try mapError(c.vkCreateInstance(&create_info, null, &instance));

        return Instance{
            .handle = instance,
        };
    }

    pub fn destroy(self: Instance) void {
        c.vkDestroyInstance(self.handle, null);
    }
};

pub const PhysDevice = struct {
    handle: c.VkPhysicalDevice,

    pub fn enumerate(i: Instance, alloc: Allocator) !PhysDevice {
        var device_count: u32 = undefined;
        try mapError(c.vkEnumeratePhysicalDevices(i.handle, &device_count, null));

        const device_list = try alloc.alloc(c.VkPhysicalDevice, device_count);
        defer alloc.free(device_list);
        try mapError(c.vkEnumeratePhysicalDevices(i.handle, &device_count, @ptrCast(device_list)));

        var j: u32 = 0;
        while (j <= device_count) {
            if (isSuitable(device_list[j])) {
                return PhysDevice{ .handle = device_list[j] };
            }
            j = j + 1;
        }
        return error.NO_VALID_GPU;
    }

    pub fn isSuitable(device: c.VkPhysicalDevice) bool {
        var device_properties: c.VkPhysicalDeviceProperties = undefined;
        var device_features: c.VkPhysicalDeviceFeatures = undefined;
        _ = c.vkGetPhysicalDeviceProperties(device, &device_properties);
        _ = c.vkGetPhysicalDeviceFeatures(device, &device_features);

        var is_suitable: bool = undefined;
        if (device_properties.deviceType == c.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU and device_features.geometryShader == 1) {
            is_suitable = true;
            std.debug.print("Chosen GPU :: {s}\n", .{device_properties.deviceName});
        } else {
            is_suitable = false;
        }

        return is_suitable;
    }
};

pub const Surface = struct {
    handle: c.VkSurfaceKHR,
    pub fn create(i: Instance, w: window.Window) !Surface {
        var surface: c.VkSurfaceKHR = undefined;
        try mapError(c.glfwCreateWindowSurface(i.handle, w.raw, null, &surface));
        return Surface{
            .handle = surface,
        };
    }

    pub fn destroy(self: Surface, instance: Instance) void {
        c.vkDestroySurfaceKHR(instance.handle, self.handle, null);
    }
};

pub const Device = struct {
    handle: c.VkDevice,

    pub fn create(phys_dev: PhysDevice, alloc: Allocator, surface: Surface) !Device {
        const present_queue_index = try presentQueue(phys_dev, alloc, surface);
        const graphics_queue_index = try graphicsQueue(phys_dev, alloc);

        const priorities: f32 = 1.0;

        const graphics_queue_create_info = c.VkDeviceQueueCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueCount = 1,
            .pQueuePriorities = &priorities,
            .queueFamilyIndex = graphics_queue_index,
        };

        const present_queue_create_info = c.VkDeviceQueueCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueCount = 1,
            .pQueuePriorities = &priorities,
            .queueFamilyIndex = present_queue_index,
        };

        const queues: []const c.VkDeviceQueueCreateInfo = &.{ graphics_queue_create_info, present_queue_create_info };

        var device_features: c.VkPhysicalDeviceFeatures2 = .{
            .sType = c.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2,
        };

        _ = c.vkGetPhysicalDeviceFeatures2(phys_dev.handle, &device_features);

        const create_info = c.VkDeviceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            .pNext = &device_features,
            .queueCreateInfoCount = @intCast(queues.len),
            .pQueueCreateInfos = queues.ptr,
            .enabledExtensionCount = @intCast(device_extensions.len),
            .ppEnabledExtensionNames = device_extensions.ptr,
        };

        var device: c.VkDevice = undefined;

        try mapError(c.vkCreateDevice(phys_dev.handle, &create_info, null, &device));

        return Device{
            .handle = device,
        };
    }

    pub fn destroy(self: Device) void {
        c.vkDestroyDevice(self.handle, null);
    }

    fn getQueueFamilyProperties(phys_dev: PhysDevice, alloc: Allocator) ![]const c.VkQueueFamilyProperties {
        var count: u32 = undefined;
        _ = c.vkGetPhysicalDeviceQueueFamilyProperties(phys_dev.handle, &count, null);

        const queue_list = try alloc.alloc(c.VkQueueFamilyProperties, count);

        _ = c.vkGetPhysicalDeviceQueueFamilyProperties(phys_dev.handle, &count, @ptrCast(queue_list));

        std.debug.print("Queue count:: {d}\n", .{count});
        return queue_list;
    }

    fn graphicsQueue(phys_dev: PhysDevice, alloc: Allocator) !u32 {
        const queue_families = try getQueueFamilyProperties(phys_dev, alloc);
        defer alloc.free(queue_families);

        var graphics_queue: ?u32 = null;

        for (queue_families, 1..) |family, index| {
            if (graphics_queue) |_| {
                break;
            }

            if ((family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT) != 0x0) {
                graphics_queue = @intCast(index);
            }
        }

        std.debug.print("Graphics Queue Index:: {d}\n", .{graphics_queue.?});

        return graphics_queue.?;
    }

    fn presentQueue(phys_dev: PhysDevice, alloc: Allocator, surface: Surface) !u32 {
        const queue_families = try getQueueFamilyProperties(phys_dev, alloc);
        defer alloc.free(queue_families);

        var present_queue: ?u32 = null;

        for (queue_families, 0..) |_, index| {
            if (present_queue) |_| {
                break;
            }

            var support: u32 = undefined;
            try mapError(c.vkGetPhysicalDeviceSurfaceSupportKHR(phys_dev.handle, @intCast(index), surface.handle, &support));

            if (support == c.VK_TRUE) {
                present_queue = @intCast(index);
            }
        }

        std.debug.print("Present Queue Index:: {d}\n", .{present_queue.?});

        return present_queue.?;
    }
};
