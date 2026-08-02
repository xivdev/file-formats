#pragma description FFXIV Attach Offset (.atch)
#pragma endian little


import std.core;
import std.mem;
import std.string;

using CString = std::string::NullString;


struct Vec3f {
    float x;
    float y;
    float z;
} [[static]];


struct AttachOffsetId {
    char code[4];
} [[static]];


bitfield LrInversionBit {
    bool value : 1;
} [[inline]];


bitfield AttachOffsetLrInversionBits {
    LrInversionBit row[256];
} [[static]];


union AttachOffsetLrInversionMask {
    u32 words[8] [[hidden]];

    AttachOffsetLrInversionBits rows;
} [[static]];


fn get_attach_state_name(u32 index) {
    if (index == 0) return "drawn";
    if (index == 1) return "sheathed";
    if (index == 2) return "drawn_alt";
    if (index == 3) return "secondary_alt";
    if (index == 4) return "throw";
    if (index == 5) return "secondary";

    return std::format("attach_{}", index);
};


struct AttachOffsetTransform {
    u32 state_index = std::core::array_index() [[hidden]];

    u32 target_bone_name_offset;
    CString target_bone_name @ target_bone_name_offset;

    float uniform_scale;

    Vec3f translation;
    Vec3f rotation_radians;

} [[name(get_attach_state_name(this.state_index))]];


struct AttachOffsetRow<auto ids, auto lr_inversion_mask, auto state_count> {
    u32 index = std::core::array_index() [[hidden]];

    bool invert_lr = ((lr_inversion_mask.words[index >> 5] >> (index & 31)) & 1) != 0 [[export]];

    AttachOffsetTransform states[state_count];
} [[name(ids[this.index].code)]];


struct atch_t {
    u16 attach_offset_id_count;
    u16 state_count;

    AttachOffsetId ids[attach_offset_id_count];
    AttachOffsetLrInversionMask lr_inversion_mask;

    AttachOffsetRow<ids, lr_inversion_mask, state_count> rows[attach_offset_id_count];
};


atch_t file @ 0x00;