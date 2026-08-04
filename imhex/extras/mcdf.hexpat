#pragma description Mare Character Data File
#pragma endian little
#pragma loop_limit 16384

import hex.core;
import hex.dec;
import hex.type.json;
import std.array;
import std.core;
import std.mem;
import std.sys;
import type.base;
import type.base64;
import type.leb128;
import type.magic;

// Phase 1: Decompress the LZ4 stream
// https://github.com/MiloszKrajewski/K4os.Compression.LZ4/blob/master/src/K4os.Compression.LZ4.Legacy/LZ4Stream.cs

std::mem::Section decompressed_chunk = std::mem::create_section("Decompressed Chunk");
std::mem::Section decompressed = std::mem::create_section("Decompressed Stream");

struct Lz4Chunk {
    type::uLEB128 chunk_flags;
    // & 0x01 = Compressed
    // & 0x02 = High Compression
    // & 0x18 = Passes
    type::uLEB128 original_length;
    if ((chunk_flags & 1) != 0) {
        type::uLEB128 compressed_length;
        u8 compressed_data[compressed_length];
        hex::dec::lz4_decompress(compressed_data, decompressed_chunk, false);
        std::assert(std::mem::get_section_size(decompressed_chunk) == original_length, "Decompressed chunk length mismatch");
        std::mem::copy_section_to_section(decompressed_chunk, 0, decompressed, std::mem::get_section_size(decompressed), original_length);
    } else {
        u8 data[original_length];
        std::mem::copy_value_to_section(data, decompressed, std::mem::get_section_size(decompressed));
    }
};

Lz4Chunk chunk[while($ < std::mem::size())] @ 0x00;

std::mem::delete_section(decompressed_chunk);

// Phase 2: Unpack the MCDF container

struct File<auto files_meta> : std::IIndexed {
    u8 data[files_meta[index].Length];
} [[sealed]];

struct MareCharaFile {
    type::Magic<"MCDF"> magic;
    u8 version;
    if (version == 1) {
        u32 meta_length;
        const u64 pos = $;
        u8 raw_meta[meta_length] [[hidden]];
        hex::type::Json<meta_length> meta @ pos;
    }

    File<meta.Files> files[std::core::member_count(meta.Files)];
};

MareCharaFile mcdf @ 0x00 in decompressed;

for (u32 i = 0, i < std::core::member_count(mcdf.meta.Files), i += 1) {
    for (u32 j = 0, j < std::core::member_count(mcdf.meta.Files[i].GamePaths), j += 1) {
        hex::core::add_virtual_file(mcdf.meta.Files[i].GamePaths[j], mcdf.files[i].data);
    }
}

hex::core::add_virtual_file("meta.json", mcdf.raw_meta);

if (std::core::has_member(mcdf.meta, "Description")) {
    std::mem::Section description = std::mem::create_section("Description");
    std::mem::copy_value_to_section(mcdf.meta.Description, description, 0);
    u8 description_data[std::mem::get_section_size(description)] @ 0x00 in description;
    hex::core::add_virtual_file("description.txt", description_data);
    std::mem::delete_section(description);
}

if (std::core::has_member(mcdf.meta, "ManipulationData")) {
    std::mem::Section manipulation = std::mem::create_section("Meta Manipulations");
    std::mem::copy_value_to_section(type::impl::decode_base64(mcdf.meta.ManipulationData), manipulation, 0);
    u8 manipulation_data[std::mem::get_section_size(manipulation)] @ 0x00 in manipulation;
    hex::core::add_virtual_file("manipulation.gz", manipulation_data);
    std::mem::delete_section(manipulation);
}

if (std::core::has_member(mcdf.meta, "GlamourerData")) {
    std::mem::Section glamourer = std::mem::create_section("Glamourer");
    std::mem::copy_value_to_section(type::impl::decode_base64(mcdf.meta.GlamourerData), glamourer, 0);
    u8 glamourer_data[std::mem::get_section_size(glamourer)] @ 0x00 in glamourer;
    hex::core::add_virtual_file("glamourer.bin", glamourer_data);
    std::mem::delete_section(glamourer);
}

if (std::core::has_member(mcdf.meta, "CustomizePlusData")) {
    std::mem::Section customize_plus = std::mem::create_section("Customize+");
    std::mem::copy_value_to_section(type::impl::decode_base64(mcdf.meta.CustomizePlusData), customize_plus, 0);
    u8 customize_plus_data[std::mem::get_section_size(customize_plus)] @ 0x00 in customize_plus;
    hex::core::add_virtual_file("customize_plus.json", customize_plus_data);
    std::mem::delete_section(customize_plus);
}