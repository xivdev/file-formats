#pragma description Final Fantasy XIV Cloud Asset
#pragma endian little

enum CLDBVersion : u32 {
    V1_0 = 0x01000000
};

struct CloudAssetBinaryHeader {
    CLDBVersion version;

    u8 positiveParamIndex;
    padding[3];

    u16 sphereCount;
    u16 sphereOffsetDwords;

    u8 reserved0C[0x14];

    float unknown20;
    float unknown24;
} [[fixed_size(0x28)]];

struct CloudAssetSphere {
    float x;
    float y;
    float z;
    float radius;

    float unknown10;
    float unknown14;
    float unknown18;
    float unknown1C;
} [[fixed_size(0x20)]];

struct CloudAssetBinary {
    CloudAssetBinaryHeader header;

    // Unknown structure; but the fact positiveParamIndex is used to index into it
    // -and- that it's full of mixed data (floats, u16?) invites further exploration
    u32 paramDwords[
        header.sphereOffsetDwords - (sizeof(CloudAssetBinaryHeader) / 4)
    ];

    $ = header.sphereOffsetDwords * 4;
    CloudAssetSphere spheres[header.sphereCount];
};

CloudAssetBinary cldb @ $;
