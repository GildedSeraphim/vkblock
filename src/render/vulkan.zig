const std = @import("std");
const c = @import("../clibs.zig");
const Allocator = std.mem.Allocator;

const builtin = @import("builtin");
const debug = (builtin.mode == .Debug);

const validation_layers: []const [*c]const u8 = if (!debug) &[0][*c]const u8{} else &[_][*c]const u8{
    "VK_LAYER_KHRONOS_validation",
};

pub const Vulk = struct {
    instance: c.VkInstance,
    phys_device: c.VkPhysicalDevice,
    device: c.VkDevice,

    pub fn initVulkan(allocator: Allocator) !Vulk {
        const instance = try createInstance();
        const phys_device = try pickPhysicalDevice(instance, allocator);
        const device = try createLogicalDevice(phys_device, allocator);

        return Vulk{
            .instance = instance,
            .phys_device = phys_device,
            .device = device,
        };
    }

    pub fn cleanup(self: Vulk) void {
        c.vkDestroyDevice(self.device, null);
        c.vkDestroyInstance(self.instance, null);
    }

    fn createInstance() !c.VkInstance {
        const app_info = c.VkApplicationInfo{
            .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .pApplicationName = "Vulkan App",
            .applicationVersion = c.VK_MAKE_VERSION(1, 0, 0),
            .pEngineName = "No Engine",
            .engineVersion = c.VK_MAKE_VERSION(1, 0, 0),
            .apiVersion = c.VK_API_VERSION_1_4,
        };

        var glfw_extension_count: u32 = 0;
        var glfw_extensions: [*c][*c]const u8 = undefined;

        glfw_extensions = c.glfwGetRequiredInstanceExtensions(&glfw_extension_count);

        const create_info = c.VkInstanceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &app_info,
            .enabledExtensionCount = glfw_extension_count,
            .ppEnabledExtensionNames = glfw_extensions,
            .enabledLayerCount = @intCast(validation_layers.len),
            .ppEnabledLayerNames = validation_layers.ptr,
        };

        var instance: c.VkInstance = undefined;

        try mapError(c.vkCreateInstance(&create_info, null, &instance));

        return instance;
    }

    fn pickPhysicalDevice(i: c.VkInstance, allocator: Allocator) !c.VkPhysicalDevice {
        var device_count: u32 = 0;
        try mapError(c.vkEnumeratePhysicalDevices(i, &device_count, null));
        const devices = try allocator.alloc(c.VkPhysicalDevice, device_count);
        defer allocator.free(devices);
        try mapError(c.vkEnumeratePhysicalDevices(i, &device_count, @ptrCast(devices)));

        const phys_device: c.VkPhysicalDevice = devices[0];

        // for (devices) |device| {
        //     if (try isDeviceSuitable(device)) {
        //         phys_device = device;
        //         break;
        //     }
        //
        //     if (phys_device == c.VK_NULL_HANDLE) {
        //         return error.NO_SUITABLE_PHYSICAL_DEVICE_FOUND;
        //     }
        // }

        return phys_device;
    }

    fn isDeviceSuitable(device: c.VkPhysicalDevice) !bool {
        var device_properties: c.VkPhysicalDeviceProperties = undefined;
        var device_features: c.VkPhysicalDeviceFeatures = undefined;
        try mapError(c.vkGetPhysicalDeviceProperties(device, &device_properties));
        try mapError(c.vkGetPhysicalDeviceFeatures(device, &device_features));

        return device_properties.deviceType == c.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU and device_features.geometryShader;
    }

    fn findQueueFamilies(device: c.VkPhysicalDevice, allocator: Allocator) !QueueFamilyIndices {
        var indices: QueueFamilyIndices = undefined;

        var queue_family_count: u32 = 0;
        c.vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_family_count, null);

        const queue_families = try allocator.alloc(c.VkQueueFamilyProperties, queue_family_count);
        defer allocator.free(queue_families);

        c.vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_family_count, @ptrCast(queue_families));
        std.debug.print("Queue families length :: {d}\n", .{queue_families.len});

        var i: u32 = 0;
        for (queue_families) |queue_family| {
            if ((queue_family.queueFlags & c.VK_QUEUE_GRAPHICS_BIT) != 0) {
                indices.graphics_family = i;
            }
            i = i + 1;
        }

        std.debug.print("valid queue families :: {d}", .{i});

        return indices;
    }

    fn createLogicalDevice(phys_device: c.VkPhysicalDevice, allocator: Allocator) !c.VkDevice {
        const indices: QueueFamilyIndices = try findQueueFamilies(phys_device, allocator);

        const queue_priority: f32 = 1.0;

        const queue_create_info = c.VkDeviceQueueCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueFamilyIndex = indices.graphics_family,
            .queueCount = 1,
            .pQueuePriorities = &queue_priority,
        };

        const device_features = c.VkPhysicalDeviceFeatures{};

        const create_info = c.VkDeviceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            .pQueueCreateInfos = &queue_create_info,
            .queueCreateInfoCount = 1,
            .pEnabledFeatures = &device_features,
            .enabledExtensionCount = 0,
        };

        var device: c.VkDevice = undefined;

        try mapError(c.vkCreateDevice(phys_device, &create_info, null, &device));

        var graphics_queue: c.VkQueue = undefined;
        _ = c.vkGetDeviceQueue(device, indices.graphics_family, 0, &graphics_queue);

        return device;
    }

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
};

pub const QueueFamilyIndices = struct {
    graphics_family: u32,
};
