#pragma description Final Fantasy XIV Shader Parameter Map
#pragma endian little

import std.array;
import std.core;
import std.mem;
import std.string;
import type.base;

enum ColumnType : u32 {
    Float = 0,
    UInt = 1,
    Name = 2,
};

enum ColumnName : u32 {
    Null = 0,

    LightingType = 0xE8001A59,
    SubSurfaceProfileID = 0x8FB53404,
    SubSurfaceWidth = 0xF30D1232,
    BackScatterPower = 0x41338E94,
    SheenRate = 0xB1FEBD21,
    SheenTintRate = 0xB7867D05,
    SheenAperture = 0x5C30C2FC,
    UseSubSurfaceRate = 0x947205D5,
    HairScatterColorShift = 0x671C995B,
    HairSpecularShift = 0x6CD877F3,
    FurLength = 0x85DC1E5C,
    HairRoughnessOffsetRate = 0x8F6BA743,
    SubSurfacePower = 0xD49D56BD,
    Reserve = 0x4D310CC0,

    HairSpecularPrimaryShift = 0xF33FF064,
    HairSpecularSecondaryShift = 0xE0D24CB4,
    HairSpecularBackScatterShift = 0xA46A47BB,
    HairBackScatterRoughnessOffsetRate = 0x773AD7FB,
    HairSecondaryRoughnessOffsetRate = 0xA8C99005,
};

enum TableName : u32 {
    Null = 0,

    BG = 0x2AF7F9B4,
    CHARA = 0xB9FDFB6C,
    COMMON = 0xA4D61674,
};

enum ValueName : u32 {
    Null = 0,

    DEFAULT = 0x417721BB,
    LEGACY = 0x56F16FCB,
    HAIR = 0x8B2653B1,
    HALF = 0xEC8B7389,
};

struct ColumnDefinition {
    ColumnName Name;
    ColumnType Type;
};

struct RowDefinition {
    TableName Table;
    u32 Index;
};

struct Header {
    u32 Version;
    u8 ColumnCount;
    u8 RowCount;
    u16 ColumnsOffset;
    u16 RowsOffset;
    u16 ValuesOffset;
};

struct Value : std::IIndexed {
    str name = std::string::replace(std::format("{}", Columns[this.index].Name), "ColumnName::", "");
    match (Columns[this.index].Type) {
        (ColumnType::UInt): u32 Value [[name(name)]];
        (ColumnType::Name): ValueName Value [[name(name)]];
        (_): float Value [[name(name)]];
    }
};

struct Row {
    Value Values[sizeof(Columns) / sizeof(Columns[0])];
} [[static]];

Header Header @ 0x0;
ColumnDefinition Columns[Header.ColumnCount] @ (Header.ColumnsOffset << 2);
RowDefinition Rows[Header.RowCount] @ (Header.RowsOffset << 2);
Row Values[Header.RowCount] @ (Header.ValuesOffset << 2);