#pragma description Final Fantasy XIV Material
#pragma endian little

import std.string;
import type.base;

struct Header {
    u32 version;
    u16 fileSize;
    u16 dataSetSize;
    u16 stringTableSize;
    u16 shaderPackageNameOffset;
    u8 textureCount;
    u8 uvSetCount;
    u8 colorSetCount;
    u8 additionalDataSize;
};

bitfield TextureFlags {
    padding : 15;
    isDx11 : 1;
};

struct Texture<auto stringTableOffset> {
    u16 pathOffset;
    TextureFlags flags;
    
    if (stringTableOffset != 0) {
        std::string::NullString path @ (stringTableOffset + pathOffset);
    }
};

struct AttributeSet<auto stringTableOffset> {
    u16 nameOffset;
    u16 index;
    
    if (stringTableOffset != 0) {
        std::string::NullString name @ (stringTableOffset + nameOffset);
    }
};

bitfield UnkFlags {
    padding : 2;
    hasColorTable : 1;
    hasStainTable : 1;
    colorTableWidth : 4;
    colorTableHeight : 4;
    padding : 20;
};

struct AdditionalData<auto size> {
    if (size >= 4) {
        UnkFlags unkFlags;
    }
    float floats[(size - 4) >> 2];
    u8 bytes[size & 3];
};

struct DataSet<auto size> {
    u8 data[size];
};;

bitfield ShaderFlags {
    hideBackfaces : 1;
    padding : 3;
    enableTransparency : 1;
    padding : 27;
};

struct ShaderHeader {
    u16 shaderValueListSize;
    u16 shaderKeyCount;
    u16 constantCount;
    u16 samplerCount;
    ShaderFlags flags;
};

struct ShaderKey {
    type::Hex<u32> keyCrc;
    type::Hex<u32> valueCrc;
};

struct Constant<auto shaderValueListOffset> {
    type::Hex<u32> nameCrc;
    u16 byteOffset;
    u16 byteSize;
    
    if (shaderValueListOffset != 0) {
        float value[byteSize >> 2] @ (shaderValueListOffset + byteOffset);
        u8 valueBytes[byteSize & 3] @ (shaderValueListOffset + byteOffset + (byteSize & ~3));
    }
};

fn format_lod_bias(auto lodBias) {
    return std::format("{}", lodBias / 64.0f);
};

enum AddressMode : u8 {
    Wrap = 0,
    Mirror = 1,
    Clamp = 2,
    Border = 3,
};

bitfield SamplerFlags {
    AddressMode uAddressMode : 2;
    AddressMode vAddressMode : 2;
    padding : 6;
    signed lodBias : 10 [[format("format_lod_bias")]];
    minLod : 4;
    padding : 8;
};

struct Sampler {
    type::Hex<u32> nameCrc;
    SamplerFlags flags;
    u8 textureIndex;
    padding[3];
};

Header header @ $;

auto stringTableOffset = $ + header.textureCount * sizeof(Texture<0>) + (header.uvSetCount + header.colorSetCount) * sizeof(AttributeSet<0>);
Texture<stringTableOffset> texture[header.textureCount] @ $;
AttributeSet<stringTableOffset> uvSets[header.uvSetCount] @ $;
AttributeSet<stringTableOffset> colorSets[header.colorSetCount] @ $;
std::string::NullString shaderPackageName @ (stringTableOffset + header.shaderPackageNameOffset);
$ = stringTableOffset + header.stringTableSize;

AdditionalData<header.additionalDataSize> additionalData @ $;
DataSet<header.dataSetSize> dataSet @ $;

ShaderHeader shaderHeader @ $;
auto shaderValueListOffset = $ + shaderHeader.shaderKeyCount * sizeof(ShaderKey) + shaderHeader.constantCount * sizeof(Constant<0>) + shaderHeader.samplerCount * sizeof(Sampler);
ShaderKey shaderKeys[shaderHeader.shaderKeyCount] @ $;
Constant<shaderValueListOffset> constants[shaderHeader.constantCount] @ $;
Sampler samplers[shaderHeader.samplerCount] @ $;