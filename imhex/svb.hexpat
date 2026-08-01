#pragma description FFXIV Sky Visibility (.svb)
#pragma endian little

import std.core;
import std.mem;

import type.magic;


// member_ids are packed as (member_ids[0] << 24) | (member_ids[1] << 16) | (member_ids[2] <<  8) | member_ids[3]
// Then combined with instance_id to make a lookup key
struct SkyVisibilityEntry {
    u32 instance_id;
    u8 member_ids[4];
    float sky_visibility;
} [[static]];


struct SkyVisibilityData {
    s32 version;
    s32 entries_offset;
    u32 entries_count;

    if (entries_count > 0) {
        SkyVisibilityEntry sky_visibilities[entries_count] @ addressof(this) + entries_offset;
    }
};

struct SkyVisibilityChunk {
    type::Magic<"SVC1"> magic;
    u32 chunk_size;
} [[static]];


struct SkyVisibilityHeader {
    type::Magic<"SVB1"> magic;
    u32 file_size;
    u32 chunk_count;
} [[static]];


struct svb_t {
    SkyVisibilityHeader file_header;
    
    SkyVisibilityChunk chunk;

    SkyVisibilityData data;
};


svb_t file @ 0x00;