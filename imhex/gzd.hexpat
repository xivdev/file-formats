#pragma description FFXIV Grass Zone Data (.gzd)
#pragma endian little

import std.core;
import std.sys;

import type.magic;


enum GZDVersion : u32 {
    V2_0_5_0 = 0x02000500,
    V2_0_6_0 = 0x02000600
};


enum GrassGridTier : u8 {
    High   = 0, // filename suffix 'h'
    Medium = 1, // filename suffix 'm'
    Low    = 2  // filename suffix 'l'
};


struct Float3 {
    float x;
    float y;
    float z;
};


// Fixed-size null-terminated string
// Full path is grass_zone_data.gzd path + value + '.tex' 
struct ColorMapTextureBasename {
    char value[0x20];
};


// Fixed-size null-terminated string
struct ModelPath {
    char value[0x100];
};


// Packed 32-bit ggd resource key
// Constructed as "%03u_%03u_%03u_%c.ggd", grid_x, grid_y, grid_z, tier_suffix
struct GrassGridKeyBytes {
    GrassGridTier tier;
    u8 grid_z;
    u8 grid_y;
    u8 grid_x;
};

union GrassGridKey {
    u32 raw;
    GrassGridKeyBytes components;
};


struct GrassZonePlacement<auto ExpectedTier> {
    // Used for nearest-zone sorting + distance filtering
    Float3 center;
    
    // This + center forms a sphere
    float bounding_sphere_radius;
    GrassGridKey grid_key;

    std::assert_warn(
        grid_key.components.tier == ExpectedTier,
        "Key tier does not match the containing GZD zone array"
    );
};


struct GZDHeader {
    type::Magic<"dzg\0"> magic;

    GZDVersion version;

    u16 high_zone_count;
    u16 medium_zone_count;
    u16 low_zone_count;

    // This isn't actually used, seems to always be 32
    u8 model_slot_capacity;

    u8 model_path_count;

    // Layer tex base names
    // For each non-empty string, it loads <gzd-dir>/<basename>.tex
    // Renderer binds slot N with GGD auto-grass layer N
    // color_map_u_offset selects within this tex
    ColorMapTextureBasename auto_layer_color_map[3];

    if (version >= GZDVersion::V2_0_6_0) {
        float auto_layer_values[3];
    }
};


struct gzd_t {
    GZDHeader header;

    ModelPath model_paths[header.model_path_count];

    GrassZonePlacement<GrassGridTier::High> high_zones[header.high_zone_count];
    GrassZonePlacement<GrassGridTier::Medium> medium_zones[header.medium_zone_count];
    GrassZonePlacement<GrassGridTier::Low> low_zones[header.low_zone_count];
};


gzd_t gzd @ 0x00;