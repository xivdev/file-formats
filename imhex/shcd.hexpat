#pragma description Final Fantasy XIV Single Shader
#pragma magic [ 53 68 43 64 ] @ 0x00
#pragma endian little

import hex.core;
import std.ptr;
import type.base;
import type.magic;
import type.size;

struct Header {
    type::Magic<"ShCd"> magic [[name("ShCd magic number")]];
    u8 minorVersion;
    u8 majorVersion;
    padding[1];
    u8 programType;
    u32 graphicsPlatform;
    type::Size32 fileSize;
    u32 blobsOffset;
    u32 stringsOffset;
};

struct Resource {
    type::Hex<u32> crc32;
    u32 nameOffset;
    std::string::NullString name @ (header.stringsOffset + nameOffset);
    type::Size16 nameSize;
    u16 unk;
    u16 slot;
    u16 size;
};

struct Shader<auto Version, auto ProgramType> {
    if (Version >= 3) {
        u32 blobOffset;
        type::Size32 blobSize;
        u16 constantCount;
        u16 samplerCount;
    }
    if (Version >= 5) {
        u16 uavCount;
        u16 textureCount;
    }
    if (Version >= 6) {
        u32 unk;
        if (unk != 0) {
            std::warning(std::format("Shader<{}, {}>.unk = {}\n", Version, ProgramType, unk));
        }
    }
    
    if (Version >= 3) {
        Resource constants[constantCount] [[name("Constants")]];
        Resource samplers[samplerCount] [[name("Samplers")]];
    }
    if (Version >= 5) {
        Resource uavs[uavCount] [[name("UAVs")]];
        Resource textures[textureCount] [[name("Textures")]];
    }

    u32 offset = 0;
    u32 size = blobSize;
    if (ProgramType == 0 && size >= 4) {
        u32 declaredInputs @ (header.blobsOffset + blobOffset + offset) [[name("Declared inputs")]];
        offset += 4;
        size -= 4;
    }
    if (ProgramType == 0 && header.graphicsPlatform == 0x31315844 && size >= 4) {
        u32 usedInputs @ (header.blobsOffset + blobOffset + offset) [[name("Used inputs")]];
        offset += 4;
        size -= 4;
    }
    
    u8 shaderBlob[size] @ (header.blobsOffset + blobOffset + offset) [[name("Shader blob")]];
    hex::core::add_virtual_file("shader.dxbc", shaderBlob);
};

Header header @ $ [[name("ShCd header")]];
Shader<header.majorVersion, header.programType> shader @ $ [[name("Shader")]];
