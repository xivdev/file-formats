#pragma description FFXIV Ambient Set (.amb)
#pragma endian little

import std.core;
import std.mem;

import type.magic;


enum AmbSubtype : u8 {
    AmbientWeather = 0,
    SkylightSkySetDatabase  = 1
};


// This is second-order (L2) sphere-harmonics (SH)
// basis/order is:
// L0: constant
// L1: y, z, x
// L2: x*y, y*z, 3 * z^2 - 1, x * z, x^2 - y^2
struct SH9 {
    float l0_constant;
    float l1_y;
    float l1_z;
    float l1_x;
    float l2_xy;
    float l2_yz;
    float l2_3z2_minus_1;
    float l2_xz;
    float l2_x2_minus_y2;
} [[static]];


struct AmbientLightSH {
    SH9 red;
    SH9 green;
    SH9 blue;
} [[static]];


struct AmbWeatherKeyframe {
    AmbientLightSH ambient_light_sh;
    float time_of_day_seconds;
} [[static]];


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


struct AmbAmbientWeatherDatabase {
    SH9 sky_visibility_sh;

    u32 weather_slot_key_count[32];

    PlacementSet<AmbWeatherKeyframe, weather_slot_key_count> weather_slots;
};


struct SkylightSkySetDescriptor {
    u16 sky_set_id;
    u16 sample_count;
    u32 first_sample_index;
} [[static]];


struct SkylightSHSample {
    AmbientLightSH ambient_light_sh;
} [[static]];


struct AmbSkylightSkySetDatabase {
    // This seems unused?
    u16 reserved_08;

    u16 sky_set_count;
    u32 total_sample_count;

    SkylightSkySetDescriptor sky_sets[sky_set_count];
    SkylightSHSample samples[total_sample_count];
};


struct amb_t {
    type::Magic<"AMB\0"> magic;
    u16 format_version;
    u8 endian;
    AmbSubtype subtype;

    if (subtype == AmbSubtype::AmbientWeather) {
        AmbAmbientWeatherDatabase ambient;
    } else if (subtype == AmbSubtype::SkylightSkySetDatabase) {
        AmbSkylightSkySetDatabase skylight;
    } else {
        u8 unknown_payload[std::mem::size() - $];
    }
};


amb_t file @ 0x00;