#pragma endian little

import std.core;
import std.mem;
import std.string;

fn vert_decl_offset() {
    return 0x44 + std::mem::read_unsigned(0x04, 4);
};

fn get_string(u32 offset) {
    std::string::NullString str_data @ (vert_decl_offset() + 8 + offset);
    return str_data;
};

enum VertexType : u8 {
    SINGLE1 = 0,
    SINGLE2 = 1,
    SINGLE3 = 2,
    SINGLE4 = 3,
    UNK4    = 4,
    UBYTE4  = 5,
    SHORT2  = 6,
    SHORT4  = 7,
    NBYTE4  = 8,
    NSHORT2 = 9,
    NSHORT4 = 10,
    UNK11   = 11,
    UNK12   = 12,
    HALF2   = 13,
    HALF4   = 14,
    UNK15   = 15,
    USHORT2 = 16,
    USHORT4 = 17
};

enum VertexUsage : u8 {
    POSITION = 0,
    BLEND_WEIGHTS = 1,
    BLEND_INDICES = 2,
    NORMAL = 3,
    UV = 4,
    FLOW = 5,
    TANGENT = 6,
    COLOUR = 7
};

bitfield ModelFlags1 {
    SHADOW_DISABLED : 1;
    LIGHT_SHADOW_DISABLED : 1;
    WAVING_ANIMATION_DISABLED : 1;
    LIGHTING_REFLECTION_ENABLED : 1;
    UNKNOWN1 : 1;
    RAIN_OCCLUSION_ENABLED : 1;
    SNOW_OCCLUSION_ENABLED : 1;
    DUST_OCCLUSION_ENABLED : 1;
};

bitfield ModelFlags2 {
    STATIC_MESH : 1;
    EDGE_GEOMETRY_ENABLED : 1;
    FORCE_LOD_RANGE_ENABLED : 1;
    SHADOW_MASK_ENABLED : 1;
    EXTRA_LOD_ENABLED : 1;
    ENABLE_FORCE_NON_RESIDENT : 1;
    BG_UV_SCROLL_ENABLED : 1;
    UNKNOWN2 : 1;
};

bitfield ModelFlags3 {
    UNKNOWN8 : 1;
    UNKNOWN7 : 1;
    UNKNOWN6 : 1;
    UNKNOWN5 : 1;
    UNKNOWN4 : 1;
    USE_CREST_CHANGE : 1;
    USE_MATERIAL_CHANGE : 1;
    UNKNOWN3 : 1;
};

struct FileHeader {
    u32 version;
    u32 stack_size;
    u32 runtime_size;
    u16 vertex_declaration_count;
    u16 material_count;
    u32 vert_offset[3];
    u32 idx_offset[3];
    u32 vert_buffer_size[3];
    u32 idx_buffer_size[3];
    u8 lod_count;
    u8 enable_idx_buffer_stream;
    u8 enable_edge_geometry;
    u8 padding_byte [[hidden]];
};

struct VertexElement {
    u8 stream;
    u8 offset;
    VertexType type;
    VertexUsage usage;
    u8 usage_idx;
    u8 padding_byte[3] [[hidden]];
};

struct VertexDeclaration {
    VertexElement elements[17];  
}[[single_color]];

struct StringSection {
    u16 string_count;
    u8 padding_byte[2] [[hidden]];
    u32 string_size;
    char string_data[string_size];
};

struct MeshHeader {
    float radius;
    u16 mesh_count;
    u16 attribute_count;
    u16 submesh_count;
    u16 material_count;
    u16 bone_count;
    u16 bone_table_count;
    u16 shape_count;
    u16 shape_mesh_count;
    u16 shape_value_count;
    u8 lod_count;
    ModelFlags1 flags1;
    u16 element_id_count;
    u8 terrain_shadow_mesh_count;
    ModelFlags2 flags2;
    float model_clip_distance;
    float shadow_clip_distance;
    u16 culling_grid_count;
    u16 terrain_shadow_submesh_count;
    ModelFlags3 flags3;
    u8 bg_change_material_idx;
    u8 bg_crest_change_material_idx;
    u8 neck_morph_count;
    u16 bone_table_array_count_total;
    u16 unknown8;
    u32 face_data_count;
    u8 padding_byte[4] [[hidden]];
};

struct ElementID {
    u32 element_id;
    u32 parent_bone;
    float translate[3];
    float rotate[3];
};

struct VertexBuffer {
    u8 vertex[parent.vertex_buffer_size] [[inline]];
};

struct IndexBuffer {
    u16 index[parent.idx_buffer_size / 2] [[inline]];
};

struct Lod {
    u16 mesh_idx;
    u16 mesh_count;
    float model_lod_range;
    float texture_lod_range;
    u16 water_mesh_idx;
    u16 water_mesh_count;
    u16 shadow_mesh_idx;
    u16 shadow_mesh_count;
    u16 terrain_shadow_mesh_idx;
    u16 terrain_shadow_mesh_count;
    u16 vertical_fog_mesh_idx;
    u16 vertical_fog_mesh_count;
    u32 edge_geometry_size;
    u32 edge_geometry_data_offset;
    u32 polygon_count;
    u8 neck_morph_offset;
    u8 neck_morph_count;
    u16 unknown1;
    u32 vertex_buffer_size;
    u32 idx_buffer_size;
    u32 vertex_data_offset;
    u32 idx_data_offset;
    VertexBuffer vertex_buffer @ vertex_data_offset;
    IndexBuffer indices_buffer @ idx_data_offset;
};

struct ExtraLod {
    u16 light_shaft_mesh_index;
    u16 light_shaft_mesh_count;
    u16 glass_mesh_index;
    u16 glass_mesh_count;
    u16 material_change_mesh_index;
    u16 material_change_mesh_count;
    u16 crest_change_mesh_index;
    u16 crest_change_mesh_count;
    u16 unknown1;
    u16 unknown2;
    u16 unknown3;
    u16 unknown4;
    u16 unknown5;
    u16 unknown6;
    u16 unknown7;
    u16 unknown8;
    u16 unknown9;
    u16 unknown10;
    u16 unknown11;
    u16 unknown12;
};

struct Mesh {
    u16 vertex_count;
    u8 padding_byte[2] [[hidden]];
    u32 index_count;
    u16 material_index;
    u16 submesh_index;
    u16 submesh_count;
    u16 bone_table_index;
    u32 start_index;
    u32 vertex_buffer_offset[3];
    u8 vertex_buffer_stride[3];
    u8 vertex_stream_count;
};

struct AttributeOffset {
    u32 string_offset;
} [[name(get_string(this.string_offset))]];

struct TerrainShadowMesh {
    u32 idx_count;
    u32 start_idx;
    u32 vert_buffer_offset;
    u16 vert_count;
    u16 sub_mesh_idx;
    u16 sub_mesh_count;
    u8 vert_buffer_stride;
    u8 padding_byte [[hidden]];
};

struct Submesh {
    u32 idx_offset;
    u32 idx_count;
    u32 attribute_idx_mask;
    u16 bone_start_idx;
    u16 bone_count;
};

struct TerrainShadowSubMesh {
    u32 idx_offset;
    u32 idx_count;
    u16 unknown1;
    u16 unknown2;
};

struct MaterialOffset {
    u32 string_offset;
} [[name(get_string(this.string_offset))]];

struct BoneOffset {
    u32 string_offset;
} [[name(get_string(this.string_offset))]];

struct BoneTable {
    u16 offset;  
    u16 size;    
};

struct Shape {
    u32 name_offset; 
    u16 mesh_start_idx[3];
    u16 mesh_count[3];
} [[name(get_string(this.name_offset))]];

struct ShapeMesh {
    u32 mesh_idx_offset;
    u32 shape_value_count;
    u32 shape_value_offset;
};

struct ShapeValue {
    u16 base_indices_idx;
    u16 replace_vert_idx;
} [[single_colour]];

struct NeckMorph {
    float positions[3];
    u32 UNKNOWN1;
    float normals[3];
    u8 bone_idx[4];
}[[single_colour]];

struct FaceData {
    float positions[3] [[inline]];
    u32 sign;
}[[single_colour]];

struct BoundingBox {
    float min[4];  
    float max[4];  
};

struct PaddingSection {
    u8 padding_size [[hidden]];
    if (padding_size > 0) {
        u8 padding_data[padding_size] [[hidden]];
    }
};


struct XIVModel {

    FileHeader header[[name("File Header")]];
    VertexDeclaration vertex_declarations[header.vertex_declaration_count][[name("Vertex Declarations")]];
    StringSection string_section[[name("Strings")]];
    MeshHeader mesh_header[[name("Mesh Header")]];
    ElementID element_ids[mesh_header.element_id_count][[name("Element ID")]];
    Lod lods[3][[name("LODs")]];
    
    if (mesh_header.flags2.EXTRA_LOD_ENABLED == 1) {  
        ExtraLod extra_lods[3][[name("Extra LODs")]];
    }
    
    Mesh meshes[mesh_header.mesh_count][[name("Meshes")]];
    AttributeOffset attribute_offsets[mesh_header.attribute_count][[name("Attributes")]];
    
    TerrainShadowMesh terrain_shadow_meshes[mesh_header.terrain_shadow_mesh_count][[name("Terrain Shadow Meshes")]];
    Submesh submeshes[mesh_header.submesh_count][[name("Submeshes")]];
    TerrainShadowSubMesh terrain_shadow_submeshes[mesh_header.terrain_shadow_submesh_count][[name("Terrain Shadow Subeshes")]];
    
    MaterialOffset material_offsets[mesh_header.material_count][[name("Materials")]];
     
    BoneOffset bone_offsets[mesh_header.bone_count][[name("Bones")]];
    BoneTable bone_tables[mesh_header.bone_table_count][[name("Bone Table")]];
    
    u16 bone_table_data[mesh_header.bone_table_array_count_total][[name("Bone Table Data")]];
    
    Shape shapes[mesh_header.shape_count][[name("Shapes")]];
    ShapeMesh shape_meshes[mesh_header.shape_mesh_count][[name("Shape Meshes")]];
    ShapeValue shape_values[mesh_header.shape_value_count][[name("Shape Values")]];
    
    u32 bonemap_size [[name("Bonemap Size")]];  
    u16 bone_indices[bonemap_size / 2] [[name("Bonemap Indices")]];
    
    NeckMorph neck_morphs[mesh_header.neck_morph_count] [[name("Neck Morphs")]];
    
    FaceData face_data[mesh_header.face_data_count] [[name("Face Data Table")]];
    
    PaddingSection padding_section [[name("Padding"), hidden]];
   
    BoundingBox bounding_box [[name("Bounding Box")]];
    BoundingBox mdl_bounding_box [[name("Model Bounding Box")]];
    BoundingBox water_bounding_box [[name("Water Bounding Box")]];
    BoundingBox vertical_fog_bounding_box [[name("Fog Bounding Box")]];
    BoundingBox bone_bounding_boxes[mesh_header.bone_count] [[name("Bone Bounding Boxes")]];
   
    u32 expected_data_offset = 0x44 + header.runtime_size + header.stack_size;
    u32 current_position = $;
    
    if (current_position < expected_data_offset) {
        u8 runtime_padding_data[expected_data_offset - current_position];
    }
    
};

XIVModel Model @ 0x00;