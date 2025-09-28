#pragma description Final Fantasy XIV Texture
#pragma endian little

import std.core;

bitfield MipCountAndFlag {
    mipCount : 7;
    unkFlag : 1;
};

bitfield TextureAttributes {
    discardPerFrame : 1;
    discardPerMap : 1;
    managed : 1;
    userManaged : 1;
    cpuRead : 1;
    locationMain : 1;
    noGpuRead : 1;
    alignedSize : 1;

    edgeCulling : 1;
    locationOnion : 1;
    readWrite : 1;
    immutable : 1;

    padding : 8;

    textureRenderTarget : 1;
    textureDepthStencil : 1;
    textureType1D : 1;
    textureType2D : 1;

    textureType3D : 1;
    textureTypeCube : 1;
    textureSwizzle : 1;
    textureNoTiled : 1;
    textureType2DArray : 1;
    padding : 2;
    textureNoSwizzle : 1;
};

enum TextureFormat : u32 {
    // Integer types
    L8 = 0x1130,
    A8 = 0x1131,
    B4G4R4A4 = 0x1440,
    B5G5R5A1 = 0x1441,
    B8G8R8A8 = 0x1450,
    B8G8R8X8 = 0x1451,

    // Floating point types
    R32F = 0x2150,
    R16G16F = 0x2250,
    R32G32F = 0x2260,
    R16G16B16A16F = 0x2460,
    R32G32B32A32F = 0x2470,

    // Block compression types (DX11 names)
    BC1 = 0x3420,
    BC2 = 0x3430,
    BC3 = 0x3431,
    BC5 = 0x6230,
    BC7 = 0x6432,

    // Depth stencil types
    D16 = 0x4140,
    D24S8 = 0x4250,

    // Special types
    Null = 0x5100,
    Shadow16 = 0x5140,
    Shadow24 = 0x5150,
};

fn calculate_surface_size(TextureFormat format, u32 width, u32 height, u32 depth, auto mip) {
    auto type = (u32(format) & 0xF000) >> 12;
    auto bpp = 1 << ((u32(format) & 0xF0) >> 4);
    width = (width + (1 << mip) - 1) >> mip; // Rounds up, not sure if it's what should be done.
    height = (height + (1 << mip) - 1) >> mip;
    depth = (depth + (1 << mip) - 1) >> mip;
    if (type == 3 || type == 6) {
        width = (width + 3) & ~3;
        height = (height + 3) & ~3;
    }
    auto bits = width * height * bpp;
    auto bytes = (bits + 7) >> 3;
    return bytes * depth;
};

struct Surface {
    u32 offset;
    if (offset != 0) {
        u8 surface[calculate_surface_size(parent.format, parent.width, parent.height, parent.depth, std::core::array_index())] @ offset;
    }
};

struct Header {
    TextureAttributes type;
    TextureFormat format;
    u16 width;
    u16 height;
    u16 depth;
    MipCountAndFlag mipCount;
    u8 arraySize;
    u32 lodOffsets[3];
    Surface surfaces[13];
};

Header header @ $;
