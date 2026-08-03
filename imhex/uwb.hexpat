#pragma description FFXIV Underwater (.uwb)
#pragma endian little

import std.core;
import std.mem;

import type.magic;


struct UnderwaterFogAttenuation {
    float vertical_fade_upper;
    float vertical_fade_lower;
    float vertical_attenuation_strength;
} [[static]];

struct UnderwaterParameters {
    // This is a guess
    s32 version;
    
    float water_surface_y;
    
    float depth_transition_start;
    float depth_transition_range;
    
    UnderwaterFogAttenuation fog_shallow;
    UnderwaterFogAttenuation fog_deep;
    
    float caustics_distance_fade_start;
    float caustics_distance_fade_range;
    
    float caustics_uv_size_0;
    float caustics_uv_size_1;
    
    float caustics_scroll_speed;
    float caustics_intensity;
    
    float sun_size;
    float sun_fade_start;
    
    float underwater_lighting_multiplier;
    
    // Don't know what this is for, but it IS checked for zero
    // Just never copied anywhere
    u32 unknown_zero;
    
};

struct UnderwaterChunk {
    type::Magic<"UWC1"> magic;
    u32 chunk_size;
} [[static]];


struct UnderwaterHeader {
    type::Magic<"UWB1"> magic;
    u32 file_size;
    u32 chunk_count;
} [[static]];


struct uwb_t {
    UnderwaterHeader header;

    UnderwaterChunk chunk;
    
    UnderwaterParameters params;
};


uwb_t file @ 0x00;