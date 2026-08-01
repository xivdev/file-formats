#pragma description FFXIV Env Set (.envb), Sound Set (.essb), Object Behavior Set (.obsb)
#pragma endian little

import std.core;
import std.mem;
import std.string;
import type.magic;

#define V700_MARKER 0x56373030

enum EnvsContainerMagic : u32 {
    ENVB = 0x42564E45,
    ESSB = 0x42535345,
    OBSB = 0x4253424F
};


enum EnvSetType : u32 {
    GlobalLighting      = 0,
    FakeSpecular        = 1,
    Cloud               = 2,
    Rain                = 3,
    Snow                = 4,
    Dust                = 5,
    Wind                = 6,
    LightShaft          = 7,
    Wetness             = 8,
    ToneMapping         = 9,
    ColorFilter         = 10,
    Effect              = 11,
    Starfield           = 12,
    VerticalFog         = 13,
    Unknown14           = 14,

    AmbientSoundPaths   = 20,
    AmbientSoundFlags   = 21,

    ObjectVisibility    = 29,
    ObjectTransform     = 30,
    ObjectOscillator    = 31,
    ObjectRotation      = 32,
    ObjectRgbColor      = 33,
    ObjectRgbColorPair  = 34,
    ObjectRgbaColor     = 35
};



struct EnvTimelineKeyframeBase {
    float time_seconds;
} [[static]];


struct PackedColorIntensity {
    u8 red;
    u8 green;
    u8 blue;
    u8 alpha;
    float intensity;
} [[static]];


using CString = std::string::NullString;


enum SerializedBool : u8 {
    False = 0,
    True  = 1
};


struct WeatherVfxPathTable<auto Count> {
    if (Count > 0)
        s32 effect_0_offset;
    if (Count > 1)
        s32 effect_1_offset;

    if (Count > 0)
        CString effect_0 @ addressof(this) + effect_0_offset;
    if (Count > 1)
        CString effect_1 @ addressof(this) + effect_1_offset;
};


struct AmbientSoundPathTable<auto Count> {
    if (Count > 0)
        s32 background_loop_offset;
    if (Count > 1)
        s32 spot_ambience_offset;
    if (Count > 2)
        s32 special_spot_offset;
    if (Count > 3)
        s32 reserved_path_offset;
    if (Count > 4)
        s32 random_grass_wind_offset;

    if (Count > 0)
        CString background_loop   @ addressof(this) + background_loop_offset;
    if (Count > 1)
        CString spot_ambience     @ addressof(this) + spot_ambience_offset;
    if (Count > 2)
        CString special_spot      @ addressof(this) + special_spot_offset;
    if (Count > 3)
        CString reserved_path     @ addressof(this) + reserved_path_offset;
    if (Count > 4)
        CString random_grass_wind @ addressof(this) + random_grass_wind_offset;
};


struct V700_GlobalLighting {
    type::Magic<"007V"> marker;
    float hue_shift;
} [[static]];


struct V700_Wind {
    type::Magic<"007V"> marker;
    float layer_1_azimuth_degrees;
    float layer_0_wavelength;
    float layer_1_max_strength;
    float layer_1_wavelength;
    float layer_0_min_strength;
    float layer_1_min_strength;
} [[static]];


struct V700_ColorFilter<auto KeyframeBase> {
    type::Magic<"007V"> marker;
    float dark_filter_saturation;
    float dark_filter_parameter_x;
    float dark_filter_parameter_y;
    float dark_filter_tint_amount_and_parameter_z;
    s32 dark_filter_tint_color_offset;

    PackedColorIntensity dark_filter_tint_color @ KeyframeBase + dark_filter_tint_color_offset;
};


struct V700_VerticalFog<auto KeyframeBase> {
    type::Magic<"007V"> marker;
    float fog_density_percent;
    float exp_fog_height;
    float fog_height_falloff;
    float start_distance;
    float fog_min_opacity;
    
    float fog_density_2_percent;
    float exp_fog_height_2_delta;
    float fog_height_falloff_2;
    
    float directional_inscattering_start_distance;
    float directional_inscattering_color_intensity;
    float directional_inscattering_exponent;
    s32 directional_inscattering_color_offset;
    
    s8 use_height_fog_update;
    
    u8 _padding[3];

    PackedColorIntensity directional_inscattering_color @ KeyframeBase + directional_inscattering_color_offset;
};


struct Keyframe_GlobalLighting : EnvTimelineKeyframeBase {
    s32 sunlight_color_offset;
    float ambient_light_scale;
    float ambient_light_saturation;
    float ambient_attenuation;
    s32 extra_ambient_color_offset;
    s32 moonlight_color_offset;
    float extra_ambient_color_weight;
    float extra_param;
    float parameter_0;
    float parameter_1;

    PackedColorIntensity sunlight_color      @ addressof(this) + sunlight_color_offset;
    PackedColorIntensity extra_ambient_color @ addressof(this) + extra_ambient_color_offset;
    PackedColorIntensity moonlight_color     @ addressof(this) + moonlight_color_offset;

    u32 v700_probe [[hidden]];
    if (v700_probe == V700_MARKER)
        V700_GlobalLighting v700 @ addressof(v700_probe) [[inline]];
};


struct Keyframe_FakeSpecular : EnvTimelineKeyframeBase {
    s32 color_0_offset;
    s32 color_1_offset;
    s32 color_2_offset;
    float elevation_0_degrees;
    float elevation_1_degrees;
    float elevation_2_degrees;
    float rotation_degrees;

    PackedColorIntensity color_0 @ addressof(this) + color_0_offset;
    PackedColorIntensity color_1 @ addressof(this) + color_1_offset;
    PackedColorIntensity color_2 @ addressof(this) + color_2_offset;
};


struct Keyframe_Cloud : EnvTimelineKeyframeBase {
    u32 main_cloud;
    u32 alt_cloud;
    float main_intensity;
    float alt_intensity;
    s32 diffuse_color_offset;
    s32 ambient_color_offset;

    PackedColorIntensity diffuse_color @ addressof(this) + diffuse_color_offset;
    PackedColorIntensity ambient_color @ addressof(this) + ambient_color_offset;
};


struct Keyframe_WeatherParticles : EnvTimelineKeyframeBase {
    float density;
    float weight;
    float oscillation_spread;
    float oscillation_frequency;
    float distance_response_profile;
    float extra_param;
    float modulation_rate;
    
    s32 color_offset;
    u32 flags;

    PackedColorIntensity color @ addressof(this) + color_offset;
};


struct Keyframe_Wind : EnvTimelineKeyframeBase {
    float layer_0_azimuth_degrees;
    float unknown;
    float layer_0_max_strength;

    u32 v700_probe [[hidden]];
    if (v700_probe == V700_MARKER)
        V700_Wind v700 @ addressof(v700_probe) [[inline]];
};


struct Keyframe_LightShaft : EnvTimelineKeyframeBase {
    u32 unknown;
    s32 color_0_offset;
    s32 radiance_color_offset;
    float scale;
    float some_param;
    
    PackedColorIntensity color_0        @ addressof(this) + color_0_offset;
    PackedColorIntensity radiance_color @ addressof(this) + radiance_color_offset;
};


struct Keyframe_Wetness : EnvTimelineKeyframeBase {
    float unknown;
    float world_wetness_parameter_1;
    float world_wetness_parameter_0;
    float character_wetness;
};


struct Keyframe_ToneMapping : EnvTimelineKeyframeBase {
    float adaptation_rate;
    float adapted_luminance_parameter_w;
    float adapted_luminance_parameter_x;
    float adapted_luminance_parameter_y;
    float tone_map_parameter_y;
    float tone_map_parameter_x;
};


struct Keyframe_ColorFilter : EnvTimelineKeyframeBase {
    float hue;
    float saturation;
    float brightness;
    float contrast;
    s32 filter_color_offset;
    float filter_intensity;
    float sepia;
    float grayscale;
    float negative;
    float lut_input_black_point;
    float lut_input_white_point;
    SerializedBool alternate_curve_layout;
    u8 _padding[3];

    PackedColorIntensity filter_color @ addressof(this) + filter_color_offset;

    u32 v700_probe [[hidden]];
    if (v700_probe == V700_MARKER)
        V700_ColorFilter<addressof(this)> v700 @ addressof(v700_probe) [[inline]];
};


struct Keyframe_Effect : EnvTimelineKeyframeBase {
    s32 path_offset_table_offset;
    u32 path_count;
    
    s32 background_tint_color_offset;
    s32 foreground_tint_color_offset;
    
    u8 foreground_effect_type;
    u8 _padding[3];
    
    float effect_transition_seconds;
    s32 unknown_rgba_color_offset;
    s32 thunder_color_offset;
    float thunder_interval;
    float background_intensity;
    float foreground_intensity;

    WeatherVfxPathTable<path_count> paths      @ addressof(this) + path_offset_table_offset;
    PackedColorIntensity background_tint_color @ addressof(this) + background_tint_color_offset;
    PackedColorIntensity foreground_tint_color @ addressof(this) + foreground_tint_color_offset;
    PackedColorIntensity unknown_rgba_color    @ addressof(this) + unknown_rgba_color_offset;
    PackedColorIntensity thunder_color         @ addressof(this) + thunder_color_offset;
};


struct Keyframe_Starfield : EnvTimelineKeyframeBase {
    float a_intensity; // don't know what these are, I assume different aspects of the night sky like stars etc
    float b_intensity;
    float c_intensity;
    float unknown;
    s32 moon_color_offset;
    float unknown2;
    float procedural_star_intensity;

    PackedColorIntensity moon_color @ addressof(this) + moon_color_offset;
};


struct Keyframe_VerticalFog : EnvTimelineKeyframeBase {
    s32 fog_color_offset; // extremely unsure about any of these
    float fog_start_distance;
    float fog_intensity_0;
    float fog_fade_distance;
    float fog_intensity_1;
    float fog_parameter;
    float fog_blend;

    PackedColorIntensity fog_color @ addressof(this) + fog_color_offset;

    u32 v700_probe [[hidden]];
    if (v700_probe == V700_MARKER)
        V700_VerticalFog<addressof(this)> v700 @ addressof(v700_probe) [[inline]];
};


struct Keyframe_Unknown14 : EnvTimelineKeyframeBase {
    float scalar_0;
    float scalar_1;
    float scalar_2;
    float scalar_3;
    float scalar_4;
    float scalar_5;
    float scalar_6;
    float scalar_7;
};


struct Keyframe_AmbientSoundPaths : EnvTimelineKeyframeBase {
    s32 path_offset_table_offset;
    u32 path_count;

    AmbientSoundPathTable<path_count> paths @ addressof(this) + path_offset_table_offset;
};


struct Keyframe_AmbientSoundFlags : EnvTimelineKeyframeBase {
    SerializedBool ambient_setting_0_enabled;
    SerializedBool ambient_setting_1_enabled;
    u16 padding_06;
};


struct Keyframe_ObjectVisibility : EnvTimelineKeyframeBase {
    u16 transition_duration_centiseconds;
    SerializedBool visible;
    u8 padding_07;
};


struct Keyframe_ObjectTransform : EnvTimelineKeyframeBase {
    float value;
};


struct Keyframe_ObjectOscillator : EnvTimelineKeyframeBase {
    float phase_rate;
    float amplitude;
};


struct Keyframe_ObjectRotation : EnvTimelineKeyframeBase {
    float value;
};


struct Keyframe_ObjectRgbColor : EnvTimelineKeyframeBase {
    s32 color_offset;
    PackedColorIntensity color @ addressof(this) + color_offset;
};


struct Keyframe_ObjectRgbColorPair : EnvTimelineKeyframeBase {
    s32 color_0_offset;
    s32 color_1_offset;

    PackedColorIntensity color_0 @ addressof(this) + color_0_offset;
    PackedColorIntensity color_1 @ addressof(this) + color_1_offset;
};


struct Keyframe_ObjectRgbaColor : EnvTimelineKeyframeBase {
    s32 color_offset;
    PackedColorIntensity color @ addressof(this) + color_offset;
};


struct Keyframe_Unknown : EnvTimelineKeyframeBase {};


struct EnvKeyframeReference<auto Channel, auto OffsetTableBase> {
    s32 relative_offset;
    if (Channel == EnvSetType::GlobalLighting) {
        Keyframe_GlobalLighting keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::FakeSpecular) {
        Keyframe_FakeSpecular keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Cloud) {
        Keyframe_Cloud keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Rain || Channel == EnvSetType::Snow || Channel == EnvSetType::Dust) {
        Keyframe_WeatherParticles keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Wind) {
        Keyframe_Wind keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::LightShaft) {
        Keyframe_LightShaft keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Wetness) {
        Keyframe_Wetness keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ToneMapping) {
        Keyframe_ToneMapping keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ColorFilter) {
        Keyframe_ColorFilter keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Effect) {
        Keyframe_Effect keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Starfield) {
        Keyframe_Starfield keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::VerticalFog) {
        Keyframe_VerticalFog keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::Unknown14) {
        Keyframe_Unknown14 keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::AmbientSoundPaths) {
        Keyframe_AmbientSoundPaths keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::AmbientSoundFlags) {
        Keyframe_AmbientSoundFlags keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectVisibility) {
        Keyframe_ObjectVisibility keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectTransform) {
        Keyframe_ObjectTransform keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectOscillator) {
        Keyframe_ObjectOscillator keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectRotation) {
        Keyframe_ObjectRotation keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectRgbColor) {
        Keyframe_ObjectRgbColor keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectRgbColorPair) {
        Keyframe_ObjectRgbColorPair keyframe @ OffsetTableBase + relative_offset;
    }
    else if (Channel == EnvSetType::ObjectRgbaColor) {
        Keyframe_ObjectRgbaColor keyframe @ OffsetTableBase + relative_offset;
    }
    else {
        Keyframe_Unknown keyframe @ OffsetTableBase + relative_offset;
    }
};


struct EnvsReservedTrailer12 {
    // ENVB and ESSB don't use this
    u32 reserved[3];
};

enum OscillatorType : u8 {
    Sine   = 0,
    Random = 1
};

struct ObsbBehaviorOptions {
    // 'oscillator' refers to an oscillator that gets params defined by type 31 (phase_rate, amplitude)
    // 'modulate' bits define a multiplication of the oscillator's calculated attenuation envelope
    // with the specific RGB values from the type
    
    // Use an alternate 256-sample smoothed-random-noise waveform (generated on startup via rand()), instead of sin for the oscillator
    OscillatorType oscillator_type;             // byte 0 -> bit 0
    
    // Pulses/fades visibility and can hide the object during the oscillator's negative half-cycle
    SerializedBool visibility_oscillation;      // byte 1 -> bit 2
    
    // For type 32 
    SerializedBool rotation_oscillation;        // byte 2 -> bit 3
    
    // This is for type 30, makes that value be multiplied with symmetric gain of the oscillator
    SerializedBool transform_rate;              // byte 3 -> bit 4
    
    // This one is for type 33's color
    SerializedBool modulate_rgb_color;          // byte 4 -> bit 5
    
    // Modulate type 34's first color
    SerializedBool modulate_first;              // byte 5 -> bit 6
    
    // Modulate type 35's RGB components (A untouched)
    SerializedBool modulate_rgba_rgb;           // byte 6 -> bit 8
    
    
    SerializedBool oscillator_sync;             // byte 7 -> bit 1
    
    // Turns type 33's color into a multiplicative tint
    SerializedBool multiply_tint;               // byte 8 -> bit 9
    
    // Makes type 34's first color use white as base for lerping
    SerializedBool first_use_white_base;        // byte 9 -> bit 10
    
    // Modulate type 34's second color
    SerializedBool modulate_color_light;        // byte 10 -> bit 7
    
    // Makes type 34's second color use white as base for lerping
    SerializedBool second_use_white_base;       // byte 11 -> bit 11
};


struct EnvSet<auto Container> {
    s32 keyframe_offset_table_offset;
    u32 keyframe_count;
    EnvSetType type;

    EnvKeyframeReference<
        type,
        addressof(this) + keyframe_offset_table_offset
    > keyframes[keyframe_count] @ addressof(this) + keyframe_offset_table_offset;
};


struct EnvSectionFooter {
    float cycle_length_seconds;
    u32 section_parameter;
    float section_weight;
    s32 resource_path_0_offset;
    s32 resource_path_1_offset;
    
    CString auxiliary_resource_path_0 @ addressof(this) + resource_path_0_offset;
    CString auxiliary_resource_path_1 @ addressof(this) + resource_path_1_offset;
};


struct EnvSection<auto Container> {
    s32 envset_table_offset;
    u32 envset_count;
    u32 owner_id;
    s32 footer_offset;

    EnvSet<Container> envsets[envset_count] @ addressof(this) + envset_table_offset;
    EnvSectionFooter footer @ addressof(this) + footer_offset;
};


struct EnvsGraph<auto Container> {
    type::Magic<"ENVS"> magic;
    u32 header_size;
    u32 version;
    
    s32 sections_offset;
    u32 section_count;
    s32 auxiliary_offset;

    EnvSection<Container> sections[section_count] @ addressof(version) + sections_offset;

    if (Container == EnvsContainerMagic::OBSB) {
        ObsbBehaviorOptions behavior_options   @ addressof(version) + auxiliary_offset;
    } else {
        EnvsReservedTrailer12 reserved_trailer @ addressof(version) + auxiliary_offset;
    }
};


struct EnvsContainer {
    EnvsContainerMagic container_magic;
    u32 file_size;
    u32 envs_count;
    EnvsGraph<container_magic> root;
};


EnvsContainer file @ 0x00;