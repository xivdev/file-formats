#pragma description FFXIV Strategy Board
#pragma magic [ 5B 73 74 67 79 3A 61 ] @ 0x00
#pragma endian little

#pragma pattern_limit 1000000

import std.mem;
import std.string;
import std.core;
import std.io;
import hex.dec;
import type.base;



// Decode + Decompress
u8 STGY_ALPHABET[64] = {
    '+', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
};

u8 PERMUTATION[64] = {
    'N', 'P', 'x', 'g', '0', 'K', '8', 'S', 'J', '2', 's', 'Z', 'D', 'F', 't', 'T',
    '6', 'E', 'a', 'V', 'c', 'p', 'L', 'M', 'm', 'e', 'j', '9', 'X', 'B', '4', 'R',
    'Y', '7', '_', 'n', 'O', 'b', 'i', '-', 'v', 'H', 'C', 'A', 'r', 'W', 'o', 'd',
    'I', 'q', 'h', 'U', 'l', 'k', '3', 'f', 'y', '5', 'G', 'w', '1', 'u', 'z', 'Q'
};

u8 URLSAFEB64[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '_'
};

u8 TRANS_LUT[128];

fn init_lut() {
    for (u32 i = 0, i < 128, i = i + 1) {
        TRANS_LUT[i] = 255;
    }
    
    for (u32 i = 0, i < 64, i = i + 1) {
        u8 input_byte = STGY_ALPHABET[i];
        u8 permuted_byte = PERMUTATION[i];
        
        for (u32 pos = 0, pos < 64, pos = pos + 1) {
            if (URLSAFEB64[pos] == permuted_byte) {
                TRANS_LUT[input_byte] = pos;
                break;
            }
        }
    }
};

str PREFIX = "[stgy:a";
str SUFFIX = "]";

fn decompress_stgy() {
    init_lut();

    str input_str = std::mem::read_string(0x00, std::mem::size());

    u32 start_idx = std::string::length(PREFIX);
    u32 end_idx = std::string::length(input_str) - std::string::length(SUFFIX);
    u32 encoded_len = end_idx - start_idx;

    u8 seed_char = std::string::at(input_str, start_idx);
    u8 seed_pos = TRANS_LUT[seed_char];

    u8 decoded_bytes[encoded_len];
    u32 decoded_idx = 0;
    u32 accumulator = 0;
    u32 bits_accumulated = 0;

    for (u32 idx = 1, idx < encoded_len, idx = idx + 1) {
        u8 byte = std::string::at(input_str, start_idx + idx);
        u8 pos = TRANS_LUT[byte];

        u8 decoded_pos = (pos - seed_pos - (idx - 1)) & 0x3F;

        accumulator = (accumulator << 6) | decoded_pos;
        bits_accumulated = bits_accumulated + 6;

        if (bits_accumulated >= 8) {
            bits_accumulated = bits_accumulated - 8;
            decoded_bytes[decoded_idx] = (accumulator >> bits_accumulated);
            decoded_idx = decoded_idx + 1;
            accumulator = accumulator & ((1 << bits_accumulated) - 1);
        }
    }


    auto decoded_section = std::mem::create_section("Decoded Data");
    std::mem::copy_value_to_section(decoded_bytes, decoded_section, 0);


    type::Hex<u32> crc32_value @ 0 in decoded_section;
    u16 board_size @ 4 in decoded_section;

    u32 compressed_size = decoded_idx - 6;
    u8 compressed_data[compressed_size] @ 6 in decoded_section;


    auto decompressed_section = std::mem::create_section("Decompressed Board");
    s128 result = hex::dec::zlib_decompress(compressed_data, decompressed_section, 15);

    return decompressed_section;
};


// Inner structure
enum DataType : u16 {
    Byte = 0,
    WORD = 1,
    DWORD = 2,
    WORDPair = 3
};

enum ObjectType : u16 {
    WhiteCirclePlain = 1,
    WhiteCircleTiled = 2,
    GreyCirclePlain = 3,
    CheckeredCircle = 4,
    WhiteSquarePlain = 5,
    WhiteSquareTiled = 6,
    GreySquarePlain = 7,
    CheckeredSquare = 8,
    CircleAoE = 9,
    FanAoE = 10,
    LineAoE = 11,
    Line = 12,
    Gaze = 13,
    Stack = 14,
    LineStack = 15,
    Proximity = 16,
    Donut = 17,
    Gladiator = 18,
    Pugilist = 19,
    Marauder = 20,
    Lancer = 21,
    Archer = 22,
    Conjurer = 23,
    Thaumaturge = 24,
    Arcanist = 25,
    Rogue = 26,
    Paladin = 27,
    Monk = 28,
    Warrior = 29,
    Dragoon = 30,
    Bard = 31,
    WhiteMage = 32,
    BlackMage = 33,
    Summoner = 34,
    Scholar = 35,
    Ninja = 36,
    Machinist = 37,
    DarkKnight = 38,
    Astrologian = 39,
    Samurai = 40,
    RedMage = 41,
    BlueMage = 42,
    Gunbreaker = 43,
    Dancer = 44,
    Reaper = 45,
    Sage = 46,
    Tank = 47,
    Tank1 = 48,
    Tank2 = 49,
    Healer = 50,
    Healer1 = 51,
    Healer2 = 52,
    DPS = 53,
    DPS1 = 54,
    DPS2 = 55,
    DPS3 = 56,
    DPS4 = 57,
    DPS5 = 58,
    DPS6 = 59,
    SmallEnemy = 60,
    SmallEnemy2 = 61,
    MediumEnemy = 62,
    MediumEnemy2 = 63,
    LargeEnemy = 64,
    TargetToAttack1 = 65,
    TargetToAttack2 = 66,
    TargetToAttack3 = 67,
    TargetToAttack4 = 68,
    TargetToAttack5 = 69,
    TargetToBind1 = 70,
    TargetToBind2 = 71,
    TargetToBind3 = 72,
    TargetToIgnore1 = 73,
    TargetToIgnore2 = 74,
    SquareMarker = 75,
    CircleMarker = 76,
    PlusMarker = 77,
    TriangleMarker = 78,
    WaymarkA = 79,
    WaymarkB = 80,
    WaymarkC = 81,
    WaymarkD = 82,
    Waymark1 = 83,
    Waymark2 = 84,
    Waymark3 = 85,
    Waymark4 = 86,
    CircleSymbol = 87,
    XSymbol = 88,
    TriangleSymbol = 89,
    SquareSymbol = 90,
    UnusedShape1 = 91,
    UnusedShape2 = 92,
    UnusedShape3 = 93,
    UpArrow = 94,
    UnusedShape4 = 95,
    UnusedShape5 = 96,
    UnusedShape6 = 97,
    UnusedShape7 = 98,
    UnusedShape8 = 99,
    Text = 100,
    Viper = 101,
    Pictomancer = 102,
    Rotate = 103,
    UnusedArrowClockwise = 104,
    Group = 105,
    StackMultiHit = 106,
    ProximityPlayerTargeted = 107,
    TankbusterSingleTarget = 108,
    RadialKnockback = 109,
    LinearKnockback = 110,
    Tower = 111,
    TargetingIndicator = 112,
    EnhancementEffect = 113,
    EnfeeblementEffect = 114,
    TargetToAttack6 = 115,
    TargetToAttack7 = 116,
    TargetToAttack8 = 117,
    MeleeDPS = 118,
    RangedDPS = 119,
    PhysicalRangedDPS = 120,
    MagicalRangedDPS = 121,
    PureHealer = 122,
    BarrierHealer = 123,
    GreyCircle = 124,
    GreySquare = 125,
    MovingCircleAoE = 126,
    OnePersonAoE = 127,
    TwoPersonAoE = 128,
    ThreePersonAoE = 129,
    FourPersonAoE = 130,
    RedLockOnMarker = 131,
    BlueLockOnMarker = 132,
    PurpleLockOnMarker = 133,
    GreenLockOnMarker = 134,
    HighlightedCircle = 135,
    HighlightedX = 136,
    HighlightedSquare = 137,
    HighlightedTriangle = 138,
    RotateClockwise = 139,
    RotateCounterclockwise = 140
};

struct WORDPair {
    u16 first;
    u16 second;
};

struct RGBA {
    u8 r;
    u8 g;
    u8 b;
    u8 a;
};

struct SizeString {
    u16 length;
    char string[length];
};

bitfield ObjectFlags {
    is_visible              : 1;
    is_flipped_horizontally : 1;
    is_flipped_vertically   : 1;
    is_locked               : 1;
    reserved                : 12;
};

struct TypedArray<T> {
    DataType data_type;
    u16 length;
    T data[length];
};

struct Pair<T> {
    T a;
    T b;
};

enum FieldType : u16 {
    Empty           = 0x00,
    BoardTitle      = 0x01,
    AllocateObject  = 0x02,
    ObjectLabel     = 0x03,
    ObjectFlags     = 0x04,
    ObjectPosition  = 0x05,
    ObjectAngle     = 0x06,
    ObjectScale     = 0x07,
    ObjectColours   = 0x08,
    ObjectArgsAB    = 0x09,
    ObjectArgsA     = 0x0A,
    ObjectArgsB     = 0x0B,
    ObjectArgsC     = 0x0C

};

struct TypeContainer {
    FieldType tag;

    match (tag) {
        (FieldType::Empty): u16 empty;
        (FieldType::BoardTitle): SizeString board_title;
        (FieldType::AllocateObject): ObjectType object_id;
        (FieldType::ObjectLabel): SizeString object_label;
        (FieldType::ObjectFlags): TypedArray<ObjectFlags> object_flags;
        (FieldType::ObjectPosition): TypedArray<Pair<u16>> object_positions;
        (FieldType::ObjectAngle): TypedArray<s16> object_angles;
        (FieldType::ObjectScale): TypedArray<u8> object_scales;
        (FieldType::ObjectColours): TypedArray<RGBA> object_colours;
        (FieldType::ObjectArgsAB): TypedArray<Pair<u16>> args_ab;
        (FieldType::ObjectArgsA): TypedArray<u16> args_a;
        (FieldType::ObjectArgsB): TypedArray<u16> args_b;
        (FieldType::ObjectArgsC): TypedArray<u16> args_c;
    }
};

struct SectionContent {
    u16 length;
    TypeContainer content[while($ - addressof(this) - 2 < length)];
};

enum SectionType : u16 {
    Content    = 0x00,
    Background = 0x03
};

struct Section {
    SectionType section_type;

    match (section_type) {
        (SectionType::Content): SectionContent content_section;
        (SectionType::Background): TypedArray<u16> background;
    }
};

struct StrategyBoard {
    u32 tag;
    u32 length;
    padding[8];
    Section sections[while($ - addressof(this) - 16 < length)];
};

char magic[7] @ 0x00 [[hidden]];

std::mem::Section target_section;
if (std::string::starts_with(magic, PREFIX)) {
    target_section = decompress_stgy();
}

StrategyBoard board @ 0x00 in target_section [[hex::visualize("hex_viewer", this)]];