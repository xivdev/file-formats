#pragma description Final Fantasy XIV Pre Bone Deformer
#pragma endian little

import std.core;
import std.string;

struct BoneDeform<auto boneCount>
{
    u16 namePosition;
    std::string::NullString name @ (parent.__start + namePosition);
    float deformMatrix[12] @ (parent.__start + 4 + (boneCount + (boneCount % 2)) * 2 + std::core::array_index() * 48);
};

struct Links
{
    u16 parentId;
    u16 firstChildId;
    u16 nextSiblingId;
    u16 headerId;
};

struct Deformer
{
    auto __start = $;
    u32 boneCount;
    BoneDeform<boneCount> bones[boneCount];
};

struct Header<auto entryCount>
{
    u16 raceSexId;
    u16 linksId;
    s32 offset;
    float unkScale;
    if (offset > 0) {
        Deformer deformer @ offset;
    }
};

u32 entryCount @ $;
Header<entryCount> headers[entryCount] @ $;
Links links[entryCount] @ $;