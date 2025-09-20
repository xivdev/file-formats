#pragma description Final Fantasy XIV Shader Package
#pragma magic [ 53 68 50 6B ] @ 0x00
#pragma endian little
#pragma pattern_limit 2097152

import hex.core;
import std.core;
import std.ptr;
import type.base;
import type.magic;
import type.size;

struct Header {
    type::Magic<"ShPk"> magic [[name("ShPk magic number")]];
    u8 minorVersion;
    u8 majorVersion;
    padding[2];
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

struct ShaderPackageHeader13 {
};

struct ShaderPackageHeader<auto Version> {
    if (Version >= 11) {
        u32 vertexShaderCount;
        u32 pixelShaderCount;
        type::Size32 materialParamsSize;
        u16 materialParamCount;
        u16 hasMaterialParamDefaults;
        u16 constantCount;
        u16 unk1;
        u16 samplerCount;
        u16 textureCount;
        u16 uavCount;
        u16 unk2;
        u32 systemKeyCount;
        u32 sceneKeyCount;
        u32 materialKeyCount;
        u32 nodeCount;
        u32 nodeAliasCount;
    }
    if (Version >= 13) {
        u32 hullShaderCount;
        u32 domainShaderCount;
        u32 geometryShaderCount;
    }
};

struct Shader<auto Version, auto ProgramType> {
    u32 blobOffset;
    type::Size32 blobSize;
    u16 constantCount;
    u16 samplerCount;
    u16 uavCount;
    u16 textureCount;
    if (Version >= 13) {
        u32 unk131d;
        if (ProgramType == "vs" && unk131d != 1 || ProgramType == "ps" && unk131d != 4 || ProgramType == "gs" && unk131d != 8) {
            std::warning(std::format("Shader<{}>.unk131d = {}\n", ProgramType, unk131d));
        }
    }

    Resource constants[constantCount];
    Resource samplers[samplerCount];
    Resource uavs[uavCount];
    Resource textures[textureCount];

    u32 offset = 0;
    u32 size = blobSize;
    if (ProgramType == "vs" && size >= 4) {
        u32 declaredInputs @ (header.blobsOffset + blobOffset + offset);
        offset += 4;
        size -= 4;
    }
    if (ProgramType == "vs" && header.graphicsPlatform == 0x31315844 && size >= 4) {
        u32 usedInputs @ (header.blobsOffset + blobOffset + offset);
        offset += 4;
        size -= 4;
    }
    
    u8 shaderBlob[size] @ (header.blobsOffset + blobOffset + offset);
    hex::core::add_virtual_file(std::format("{}{}.dxbc", ProgramType, std::core::array_index()), shaderBlob);
};

struct MaterialParam
{
    type::Hex<u32> crc32;
    u16 byteOffset;
    type::Size16 byteSize;
    if (packageHeader.hasMaterialParamDefaults != 0) {
        float default[byteSize / 4] @ ($ + (packageHeader.materialParamCount - std::core::array_index() - 1) * 8 + byteOffset);
    }
};

struct ShaderKey
{
    type::Hex<u32> key;
    type::Hex<u32> defaultValue;
};

struct Pass<auto Version>
{
    type::Hex<u32> id;
    u32 vertexShader;
    u32 pixelShader;
    if (Version >= 13) {
        u32 hullShader;
        u32 domainShader;
        u32 geometryShader;
    }
};

struct Node<auto Version, auto SystemKeyCount, auto SceneKeyCount, auto MaterialKeyCount>
{
    type::Hex<u32> selector;
    u32 passCount;
    u8 passIndices[16];
    if (Version >= 13) {
        type::Hex<u32> unk131e;
        type::Hex<u32> unk131f;
    }
    type::Hex<u32> systemKeys[SystemKeyCount];
    type::Hex<u32> sceneKeys[SceneKeyCount];
    type::Hex<u32> materialKeys[MaterialKeyCount];
    type::Hex<u32> subViewKeys[2];
    if (Version >= 13) {
        if (unk131e != subViewKeys[0]) {
            std::warning(std::format("Node.unk131e = {}, Node.subViewKeys[0] = {}", unk131e, subViewKeys[0]));
        }
        if (unk131f != subViewKeys[1]) {
            std::warning(std::format("Node.unk131f = {}, Node.subViewKeys[1] = {}", unk131f, subViewKeys[1]));
        }
    }
    Pass<Version> passes[passCount];
};

struct NodeAlias
{
    type::Hex<u32> selector;
    u32 node;
};

Header header @ $ [[name("ShPk header")]];
ShaderPackageHeader<header.majorVersion> packageHeader @ $ [[name("Package header")]];

Shader<header.majorVersion, "vs"> vertexShaders[packageHeader.vertexShaderCount] @ $ [[name("Vertex shaders")]];
Shader<header.majorVersion, "ps"> pixelShaders[packageHeader.pixelShaderCount] @ $ [[name("Pixel shaders")]];
Shader<header.majorVersion, "hs"> hullShaders[packageHeader.hullShaderCount] @ $ [[name("Hull shaders")]];
Shader<header.majorVersion, "ds"> domainShaders[packageHeader.domainShaderCount] @ $ [[name("Domain shaders")]];
Shader<header.majorVersion, "gs"> geometryShaders[packageHeader.geometryShaderCount] @ $ [[name("Geometry shaders")]];

MaterialParam materialParams[packageHeader.materialParamCount] @ $ [[name("Material parameters")]];
float materialParamDefaults[packageHeader.hasMaterialParamDefaults != 0 ? packageHeader.materialParamsSize / 4 : 0] @ $ [[name("Mat. param. defaults")]];

Resource constants[packageHeader.constantCount] @ $;
Resource samplers[packageHeader.samplerCount] @ $;
Resource textures[packageHeader.textureCount] @ $;
Resource uavs[packageHeader.uavCount] @ $;

ShaderKey systemKeys[packageHeader.systemKeyCount] @ $;
ShaderKey sceneKeys[packageHeader.sceneKeyCount] @ $;
ShaderKey materialKeys[packageHeader.materialKeyCount] @ $;
type::Hex<u32> subViewKeyDefaults[2] @ $;

Node<header.majorVersion, packageHeader.systemKeyCount, packageHeader.sceneKeyCount, packageHeader.materialKeyCount> nodes[packageHeader.nodeCount] @ $;
NodeAlias nodealiases[packageHeader.nodeAliasCount] @ $;