#pragma description FFXIV Light ClipAABB (.lcb)
#pragma endian little

import std.core;
import std.mem;

import type.magic;


struct Vec3f {
    float x;
    float y;
    float z;
} [[static]];


// member_ids are packed as (member_ids[0] << 24) | (member_ids[1] << 16) | (member_ids[2] <<  8) | member_ids[3]
// Then combined with instance_id to make a lookup key
struct LightClipEntry {
    u32 instance_id;
    u8 member_ids[4];
    
    Vec3f local_min;
    Vec3f local_max;
} [[static]];


struct LightClipData {
    s32 version;
    s32 entries_offset;
    u32 entries_count;

    if (entries_count > 0) {
        LightClipEntry light_clips[entries_count] @ addressof(this) + entries_offset;
    }
};

struct LightClipChunk {
    type::Magic<"LCC1"> magic;
    u32 chunk_size;
} [[static]];


struct LightClipHeader {
    type::Magic<"LCB1"> magic;
    u32 file_size;
    u32 chunk_count;
} [[static]];


struct lcb_t {
    LightClipHeader header;

    LightClipChunk chunk;
    
    LightClipData data;
};


lcb_t file @ 0x00;