#pragma description FFXIV Terrain (.tera)
#pragma endian little

import std.core;
import std.sys;



enum TerrainVersion : u32 {
    V1_0_0_1 = 0x01000001,
    V1_0_0_2 = 0x01000002,
    V1_0_0_3 = 0x01000003
};


// I think this doesn't do shit because minlod = maxlod = 1?
// Clear bit:
// Uses packed state 0x001C0000 -> point/wrap, mip LOD bias -8, fixed LOD 1
// Set bit:
// Uses packed state 0x00130000 -> point/wrap, mip LOD bias +6, fixed LOD 1
bitfield TerrainSamplerBiasFlags {
    color_slot_0    : 1;
    normal_slot_1   : 1;
    specular_slot_2 : 1;
    reserved        : 29;
};


// Each index N corresponds to model filename "%04d.mdl" (with value N)
// center_x = plate_size * (x + 0.5)
// center_y = plate_size * (y + 0.5)
struct TerrainPlate {
    s16 x;
    s16 y;
};


struct TerrainFile {
    TerrainVersion version;

    // Also the number of .mdl resources loaded from this directory
    u32 plate_count;


    if (version < TerrainVersion::V1_0_0_2) {
        u32 effective_plate_size = 128;
        float effective_clip_distance = 0.0;
        float effective_edge_bias = 1.0;
        u32 effective_sampler_variant_flags = 0;

        TerrainPlate plates[plate_count];
    }
    else if (version == TerrainVersion::V1_0_0_2) {
        float effective_clip_distance = 0.0;
        float effective_edge_bias = 1.0;
        u32 effective_sampler_variant_flags = 0;

        TerrainPlate plates[plate_count];

        u32 plate_size;
    }
    else {
        
        // Side length of each square terrain plate
        u32 plate_size;

        float clip_distance;

        float edge_bias;

        TerrainSamplerBiasFlags sampler_variant_flags;

        u8 reserved_0x18[0x1C];

        TerrainPlate plates[plate_count];
    }
};


TerrainFile terrain @ 0x00;