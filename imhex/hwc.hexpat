#pragma description FFXIV Hardware Cursor (.hwc)
#pragma endian little

import std.core;
import std.string;
import std.mem;


fn hwc_pixel_offset(u32 x, u32 y) {
    return y * 0x100 + x * 4;
};


fn hwc_row_offset(u32 y) {
    return y * 0x100;
};


struct HardwareCursorPixelChannels {
    u8 alpha;
    u8 red;
    u8 green;
    u8 blue;
} [[static]];


union HardwareCursorPixelData {
    u32 raw_le [[hidden]];

    HardwareCursorPixelChannels channels;
};


struct HardwareCursorPixel {
    u32 x = std::core::array_index() [[hidden]];
    u32 row_byte_offset = x * 4 [[hidden]];

    HardwareCursorPixelData value;
} [[name(std::format("x{:02}", this.x))]];


struct HardwareCursorRow {
    u32 y = std::core::array_index() [[export]];
    u32 file_offset = hwc_row_offset(y) [[hidden]];

    HardwareCursorPixel pixels[64];
} [[name(std::format("y{:02}", this.y))]];


struct hwc_t {
    // Just derived constants
    u32 width            = 64     [[export]];
    u32 height           = 64     [[export]];
    u32 channel_count    = 4      [[export]];
    u32 bits_per_channel = 8      [[export]];

    // Physical file order: y=0 first, y=63 last
    HardwareCursorRow rows[64];
};


hwc_t file @ 0x00;