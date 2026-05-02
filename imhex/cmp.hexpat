import std.core;
import std.string;

struct Colour {
    u8 red;
    u8 green;
    u8 blue;
    u8 alpha;
} [[hex::inline_visualize("color", red, green, blue, alpha)]];

struct ColourParams {
    Colour eye[256];
    Colour hairHighlights[256];
    Colour lipDark[128];
    Colour facePaintDark[128];
    Colour feature[256];
    Colour lipLight[128];
    Colour facePaintLight[128];
};

struct CommonParams {
    ColourParams params;
    ColourParams ui;
};

struct HairColour {
    Colour main;
    Colour sheen;
};

struct GenderColourParams {
    Colour skin[256];
    HairColour hair[256];
    Colour skinUI[256];
    Colour hairUI[256];
};

struct MinMax {
    float min;
    float max;
};

struct MinMax3 {
    float min[3];
    float max[3];
};

enum SubRace : u8 {
    Midlander,
    Highlander,
    
    Wildwood,
    Duskwight,
    
    Plainsfolk,
    Dunesfolk,
    
    SeekerOfTheSun,
    KeeperOfTheMoon,
    
    Seawolf,
    Hellsguard,
    
    Raen,
    Xaela,
    
    Helion,
    Lost,
    
    Rava,
    Veena,
    
    COUNT,
};

enum Race : u8 {
    Hyur,
    Elezen,
    Lalafell,
    Miqote,
    Roegadyn,
    AuRa,
    Hrothgar,
    Viera,
    
    COUNT,
};

struct RacialColourParams {
    SubRace _index = std::core::array_index();

    GenderColourParams male;
    GenderColourParams female;
} [[name(std::string::replace(std::format("{}", _index), "SubRace::", ""))]];


u8 currentRaceBase = 0;

struct Scale {
    SubRace _index = currentRaceBase + std::core::array_index();

    MinMax maleHeight;
    MinMax maleTail;
    MinMax femaleHeight;
    MinMax femaleTail;
    MinMax3 breastSize;
} [[name(
    std::core::array_index() < 2
        ? std::string::replace(std::format("{}", _index), "SubRace::", "")
        : std::format("[{}]", std::core::array_index())
)]];

struct RacialScalingParams {
    Race _index = std::core::array_index();

    currentRaceBase = u8(std::core::array_index()) * 2;

    Scale scale[10];
} [[name(std::string::replace(std::format("{}", _index), "Race::", ""))]];

struct cmp_t {
    CommonParams common;
    RacialColourParams colour[SubRace::COUNT];
    RacialScalingParams scaling[Race::COUNT];
};

cmp_t cmp @ 0x00;