#pragma description FFXIV Grass Grid Data (.ggd)
#pragma endian little

import std.core;
import std.sys;

import type.float16;
import type.magic;

using half = type::float16;


enum GGDVersion : u32 {
    V2_0_4_1 = 0x02000401,
    V2_0_4_2 = 0x02000402,
    V2_0_5_0 = 0x02000500,
    V2_0_6_0 = 0x02000600,
    V2_0_7_0 = 0x02000700,
    V2_0_8_0 = 0x02000800
};

struct Float3 {
    float x;
    float y;
    float z;
};


struct Half3 {
    half x;
    half y;
    half z;
};


struct HalfQuaternion {
    half x;
    half y;
    half z;
    half w;
};


// Each nibble indexes to:
//  0 -> 0.0
//  1 -> 0.2
//  ...
//  5 -> 1.0
//  ...
//  10 -> 2.0
bitfield AutoLayerSsaoControlIndices {
    layer_0 : 4;
    layer_1 : 4;
    layer_2 : 4;
    reserved : 4;
};

struct AutoGrassPlacement {
    Half3 position;
    HalfQuaternion rotation;
    
    half scale_y;
    half scale_xz;

    half wind_phase_offset;

    //  1.0 = neutral
    // <1.0 = soggy
    half wetness_response;

    // Selector for:
    //   - one of eight CPU alignment profiles
    //   - one of eight broad regions in g_SamplerColorMap
    u8 variation_profile_index;

    // value / 255
    u8 wind_displacement_weight_u8;

    // value / 255
    u8 shape_variation;

    u8 color_map_u_offset;
};


struct ModelGrassPlacement {
    Half3 position;
    HalfQuaternion rotation;

    half scale_y;
    half scale_xz;

    half wind_phase_offset;
    
    half wetness_response;

    u8 variation_profile_index;

    // GBuffer3.z = modelVertex.POSITION.w * wetness_response_scale / 255.0
    u8 wetness_response_scale;

    u8 shape_variation;

    u8 color_map_u_offset;
};


struct CellCountsV100 {
    u16 auto_placement[3];
    u16 model_group[32];
    u16 reserved_0x62;
    
    std::assert_warn(
        reserved_0x62 == 0,
        "Cell trailing reserved field is nonzero"
    );
};


struct CellCountsV68 {
    u16 auto_placement[3];
    u16 model_group[16];
    u16 reserved_0x42;
    
    std::assert_warn(
        reserved_0x42 == 0,
        "Cell trailing reserved field is nonzero"
    );
};


struct CellCountsV64 {
    u16 auto_placement[2];
    u16 model_group[16];
};


struct GGDHeader {
    type::Magic<" dgg"> magic;
    
    GGDVersion version;

    // cell_offsets[0 .. cell_count-1]
    u16 cell_count;

    // Three per-auto-layer SSAO-mask controls
    AutoLayerSsaoControlIndices
        auto_layer_ssao_control_indices;

    u32 cell_offsets[8];

    // Per-auto-layer random lateral offset ranges
    // The result is multiplied by placement.shape_variation / 255
    half lateral_offset_min[3];
    half lateral_offset_max[3];

    // Per-auto-layer random yaw range
    // Values in radians
    half yaw_min[3];
    half yaw_max[3];

    // Added to every placement position
    Float3 world_origin;

    if (version >= GGDVersion::V2_0_5_0) {
        // Indexed by placement.variation_profile_index
        // bendWeight = value / 255.0
        u8 alignment_bend_weight[8];

        // Indexed by placement.variation_profile_index
        // targetLengthGain = 1.0 + value / 510.0
        u8 alignment_length_gain[8];
    }
};



struct PlacementGroup<T, auto Count> {
    if (Count == 0)
        continue;
        
    T p[Count] [[inline]];
};

struct PlacementSet<T, auto Counts> {
    PlacementGroup<
        T,
        Counts[std::core::array_index()]
    > groups[std::core::member_count(Counts)] [[inline]];
};

struct CellPayload<Counts> {
    Counts counts;

    PlacementSet<
        AutoGrassPlacement,
        counts.auto_placement
    > auto_layers;

    PlacementSet<
        ModelGrassPlacement,
        counts.model_group
    > model_groups;
};

struct GGDCell<auto Version> {
    type::Magic<"dgs\0"> magic;

    Float3 world_bounds_min;
    Float3 world_bounds_max;

    if (
        Version == GGDVersion::V2_0_4_2 ||
        Version >= GGDVersion::V2_0_7_0
    ) {
        CellPayload<CellCountsV100> payload [[inline]];
    }
    else if (
        Version == GGDVersion::V2_0_4_1 ||
        Version == GGDVersion::V2_0_6_0
    ) {
        CellPayload<CellCountsV68> payload [[inline]];
    }
    else {
        CellPayload<CellCountsV64> payload [[inline]];
    }
};




struct GGDCellEntry<auto Header> {
    u32 index = std::core::array_index();
    u32 offset = Header.cell_offsets[index];

    if (offset != 0) {
        GGDCell<Header.version> cell @ offset [[name(std::format("cells[{}]", index))]];
    }
} [[inline]];


struct GGDFile {
    GGDHeader header;
    
    GGDCellEntry<header> cells[header.cell_count];
};


GGDFile ggd @ 0x00;