#pragma description DirectX 10/11 Shader Bytecode
#pragma magic [ 44 58 42 43 ] @ 0x00
#pragma endian little

import hex.core;
import std.ptr;
import type.base;
import type.magic;
import type.size;

struct Header {
    type::Magic<"DXBC"> magic [[name("DXBC magic number")]];
    type::Hex<be u128> digest [[name("Digest"), comment("Calculated using a proprietary variant of MD5.")]];
    u16 major [[name("Major version")]];
    u16 minor [[name("Minor version")]];
    type::Size32 size [[name("File size")]];
    u32 chunkCount [[name("Chunk count")]];
};

enum ShaderVariableClass : u16 {
    Scalar = 0,
    Vector,
    MatrixRows,
    MatrixColumns,
    Object,
    Struct,
    InterfaceClass,
    InterfacePointer,
};

enum ShaderVariableType : u16 {
    Void = 0,
    Bool = 1,
    Int = 2,
    Float = 3,
    String = 4,
    Texture = 5,
    Texture1D = 6,
    Texture2D = 7,
    Texture3D = 8,
    TextureCube = 9,
    Sampler = 10,
    Sampler1D = 11,
    Sampler2D = 12,
    Sampler3D = 13,
    SamplerCube = 14,
    PixelShader = 15,
    VertexShader = 16,
    PixelFragment = 17,
    VertexFragment = 18,
    UInt = 19,
    UInt8 = 20,
    GeometryShader = 21,
    Rasterizer = 22,
    DepthStencil = 23,
    Blend = 24,
    Buffer = 25,
    CBuffer = 26,
    TBuffer = 27,
    Texture1DArray = 28,
    Texture2DArray = 29,
    RenderTargetView = 30,
    DepthStencilView = 31,
    Texture2DMS = 32,
    Texture2DMSArray = 33,
    TextureCubeArray = 34,
    HullShader = 35,
    DomainShader = 36,
    InterfacePointer = 37,
    ComputeShader = 38,
    Double = 39,
    RWTexture1D = 40,
    RWTexture1DArray = 41,
    RWTexture2D = 42,
    RWTexture2DArray = 43,
    RWTexture3D = 44,
    RWBuffer = 45,
    ByteAddressBuffer = 46,
    RWByteAddressBuffer = 47,
    StructuredBuffer = 48,
    RWStructuredBuffer = 49,
    AppendStructuredBuffer = 50,
    ConsumeStructuredBuffer = 51,
    Min8Float = 52,
    Min10Float = 53,
    Min16Float = 54,
    Min12Int = 55,
    Min16Int = 56,
    Min16UInt = 57,
    Int16,
    UInt16,
    Float16,
    Int64,
    UInt64,
};

using RdefVariableMember;
using RdefVariableTypeInterface;

struct RdefVariableType {
    auto __chunkStart = parent.__chunkStart;
    auto __isRd11 = parent.__isRd11;
    ShaderVariableClass class;
    ShaderVariableType type;
    u16 numRows;
    u16 numColumns;
    u16 numElements;
    u16 memberCount;
    u32 memberOffset;
    if (memberCount > 0) {
        RdefVariableMember members[memberCount] @ (__chunkStart + memberOffset);
    }
    if (__isRd11) {
        u32 baseTypeOffset;
        if (baseTypeOffset != 0) {
            RdefVariableType baseType @ (__chunkStart + baseTypeOffset);
        }
        u32 superTypeOffset;
        if (superTypeOffset != 0) {
            RdefVariableType superType @ (__chunkStart + superTypeOffset);
        }
        u32 interfaceCount;
        u32 interfaceOffset;
        RdefVariableTypeInterface interfaceOffsets[interfaceCount] @ (__chunkStart + interfaceOffset);
        u32 nameOffset;
        std::string::NullString name @ (__chunkStart + nameOffset);
    }
};

struct RdefVariableTypeInterface {
    auto __chunkStart = parent.__chunkStart;
    auto __isRd11 = parent.__isRd11;
    u32 typeOffset;
    RdefVariableType type @ (__chunkStart + typeOffset);
};

struct RdefVariableMember {
    auto __chunkStart = parent.__chunkStart;
    auto __isRd11 = parent.__isRd11;
    u32 nameOffset;
    std::string::NullString name @ (__chunkStart + nameOffset);
    u32 typeOffset;
    RdefVariableType type @ (__chunkStart + typeOffset);
    u32 start;
};

bitfield ShaderVariableFlags {
    UserPacked : 1;
    Used : 1;
    InterfacePointer : 1;
    InterfaceParameter : 1;
    padding : 28;
};

struct RdefVariable {
    auto __chunkStart = parent.__chunkStart;
    auto __isRd11 = parent.__isRd11;
    u32 nameOffset;
    std::string::NullString name @ (__chunkStart + nameOffset);
    u32 start;
    u32 size;
    ShaderVariableFlags flags;
    u32 typeOffset;
    RdefVariableType type @ (__chunkStart + typeOffset);
    u32 defaultOffset;
    if (defaultOffset > 0) {
        u8 defaultValue[size] @ (__chunkStart + defaultOffset);
    }
    if (__isRd11) {
        s32 textureStart;
        s32 textureSize;
        s32 samplerStart;
        s32 samplerSize;
    }
};

enum CbufferType : u32 {
    CBuffer = 0,
    TBuffer,
    InterfacePointers,
    ResourceBindInfo,
};

bitfield CbufferFlags {
    UserPacked : 1;
    padding : 31;
};

struct RdefCbuffer {
    auto __chunkStart = parent.__chunkStart;
    auto __isRd11 = parent.__isRd11;
    u32 nameOffset;
    std::string::NullString name @ (__chunkStart + nameOffset);
    u32 variableCount;
    u32 variableOffset;
    RdefVariable variables[variableCount] @ (__chunkStart + variableOffset);
    u32 size;
    CbufferFlags flags;
    CbufferType cbufferType;
};

enum ShaderInputType : u32 {
    CBuffer = 0,
    TBuffer,
    Texture,
    Sampler,
    UavRWTyped,
    Structured,
    UavRWStructured,
    ByteAddress,
    UavRWByteAddress,
    UavAppendStructured,
    UavConsumeStructured,
    UavRWStructuredWithCounter,
    RtAccelerationStructure,
    UavFeedbackTexture,
};

enum ResourceReturnType : u32 {
    Undefined = 0,
    UNorm = 1,
    SNorm = 2,
    SInt = 3,
    UInt = 4,
    Float = 5,
    Mixed = 6,
    Double = 7,
    Continued = 8,
};

enum SrvDimension : u32 {
    Unknown = 0,
    Buffer = 1,
    Texture1D = 2,
    Texture1DArray = 3,
    Texture2D = 4,
    Texture2DArray = 5,
    Texture2DMS = 6,
    Texture2DMSArray = 7,
    Texture3D = 8,
    TextureCube = 9,
    TextureCubeArray = 10,
    BufferEx = 11,
};

bitfield ShaderInputFlags {
    UserPacked : 1;
    ComparisonSampler : 1;
    TextureComponent0 : 1;
    TextureComponent1 : 1;
    Unused : 1;
    padding : 27;
};

struct RdefBind {
    u32 nameOffset;
    std::string::NullString name @ (parent.__chunkStart + nameOffset);
    ShaderInputType inputType;
    ResourceReturnType returnType;
    SrvDimension viewDimension;
    u32 numSamples;
    u32 bindPoint;
    u32 bindCount;
    ShaderInputFlags inputFlags;
};

bitfield CompileFlags {
    Debug : 1;
    SkipValidation : 1;
    SkipOptimization : 1;
    PackMatrixRowMajor : 1;
    PackMatrixColumnMajor : 1;
    PartialPrecision : 1;
    ForceVsSoftwareNoOpt : 1;
    ForcePsSoftwareNoOpt : 1;
    NoPreshader : 1;
    AvoidFlowControl : 1;
    PreferFlowControl : 1;
    EnableStrictness : 1;
    EnableBackwardsCompatibility : 1;
    IeeeStrictness : 1;
    OptimizationLevel0 : 1;
    OptimizationLevel3 : 1;
    padding : 2;
    WarningsAreError : 1;
    ResourcesMayAlias : 1;
    EnableUnboundedDescriptorTables : 1;
    AllResourcesBound : 1;
    DebugNameForSource : 1;
    DebugNameForBinary : 1;
    padding : 8;
};

struct RdefChunk<auto Size> {
    auto __chunkStart = $;
    u32 cbufferCount [[name("Constant buffer count")]];
    u32 cbufferOffset [[name("Constant buffer offset")]];
    u32 bindCount [[name("Bind count")]];
    u32 bindOffset [[name("Bind offset")]];
    u8 minor [[name("Minor version")]];
    u8 major [[name("Major version")]];
    u16 programType [[name("Program type")]];
    CompileFlags compileFlags [[name("Compile flags")]];
    u32 creatorOffset [[name("Creator offset")]];
    std::string::NullString creator @ (__chunkStart + creatorOffset) [[name("Creator")]];
    char extMagic[4] [[name("Extension magic")]];
    auto __isRd11 = extMagic == "RD11";
    if (__isRd11) {
        u32 rd11A [[name("??? (RD11 A)")]];
        if (rd11A != 60) {
            std::warning(std::format("rd11A = {}\n", rd11A));
        }
        u32 rd11B [[name("??? (RD11 B)")]];
        if (rd11B != 24) {
            std::warning(std::format("rd11B = {}\n", rd11B));
        }
        u32 rd11C [[name("??? (RD11 C)")]];
        if (rd11C != 32) {
            std::warning(std::format("rd11C = {}\n", rd11C));
        }
        u32 rd11D [[name("??? (RD11 D)")]];
        if (rd11D != 40) {
            std::warning(std::format("rd11D = {}\n", rd11D));
        }
        u32 rd11E [[name("??? (RD11 E)")]];
        if (rd11E != 36) {
            std::warning(std::format("rd11E = {}\n", rd11E));
        }
        u32 rd11F [[name("??? (RD11 F)")]];
        if (rd11F != 12) {
            std::warning(std::format("rd11F = {}\n", rd11F));
        }
        u32 interfaceSlots [[name("Interface slots")]];
    }
    RdefCbuffer cbuffers[cbufferCount] @ (__chunkStart + cbufferOffset);
    RdefBind binds[bindCount] @ (__chunkStart + bindOffset);
} [[fixed_size(Size)]];

enum SystemValueType : u32 {
    Undefined = 0,
    Position = 1,
    ClipDistance = 2,
    CullDistance = 3,
    RenderTargetArrayIndex = 4,
    ViewportArrayIndex = 5,
    VertexID = 6,
    PrimitiveID = 7,
    InstanceID = 8,
    IsFrontFace = 9,
    SampleIndex = 10,
    FinalQuadEdgeTessFactor = 11,
    FinalQuadInsideTessFactor = 12,
    FinalTriEdgeTessFactor = 13,
    FinalTriInsideTessFactor = 14,
    FinalLineDetailTessFactor = 15,
    FinalLineDensityTessFactor = 16,
    Barycentrics = 23,
    ShadingRate,
    CullPrimitive,
    Target = 64,
    Depth = 65,
    Coverage = 66,
    DepthGreaterEqual = 67,
    DepthLessEqual = 68,
    StencilRef = 69,
    InnerCoverage = 70,
};

enum RegisterComponentType : u32 {
    Unknown = 0,
    UInt32 = 1,
    SInt32 = 2,
    Float32 = 3,
    UInt16,
    SInt16,
    Float16,
    UInt64,
    SInt64,
    Float64,
};

bitfield VectorMask {
    x : 1;
    y : 1;
    z : 1;
    w : 1;
    padding : 4;
};

struct SignatureElement {
    u32 nameOffset [[name("Name offset")]];
    std::string::NullString name @ (parent.__chunkStart + nameOffset) [[name("Name")]];
    u32 semanticIndex [[name("Semantic index")]];
    SystemValueType systemValueType [[name("System value type")]];
    RegisterComponentType componentType [[name("Component type")]];
    u32 registerNum [[name("Register #")]];
    VectorMask mask [[name("Mask")]];
    VectorMask readWriteMask [[name("R/W mask")]];
    u8 stream [[name("Stream")]];
    padding[1];
};

struct SgnChunk<auto Size> {
    auto __chunkStart = $;
    u32 count [[name("Element count")]];
    u32 sgnUnk1 [[name("???")]];
    SignatureElement elements[count] [[name("Elements")]];
} [[fixed_size(Size)]];

struct ClassType {
    u32 nameOffset;
    std::string::NullString name @ (parent.__chunkStart + nameOffset) [[name("Name")]];
    u16 id;
    u16 constantBufferStride;
    u16 texture;
    u16 sampler;
};

struct ClassInstance {
    u32 nameOffset;
    std::string::NullString name @ (parent.__chunkStart + nameOffset) [[name("Name")]];
    u16 type;
    u16 unknown;
    u16 constantBuffer;
    u16 constantBufferOffset;
    u16 texture;
    u16 sampler;
};

struct InterfaceSlot {
    u32 slotSpan;
    u32 count;
    u32 typeIdsOffset;
    u32 tableIdsOffset;
    u16 typeIds[count] @ (parent.__chunkStart + typeIdsOffset);
    u32 tableIds[count] @ (parent.__chunkStart + tableIdsOffset);
};

struct IfceChunk<auto Size> {
    auto __chunkStart = $;
    u32 classInstanceCount;
    u32 classTypeCount;
    u32 interfaceSlotRecordCount;
    u32 interfaceSlotCount;
    u32 classInstanceOffset;
    u32 classTypeOffset;
    u32 interfaceSlotOffset;
    u32 unk1;
    type::Hex<u32> unk2;
    ClassType classTypes[classTypeCount] @ (__chunkStart + classTypeOffset);
    ClassInstance classInstances[classInstanceCount] @ (__chunkStart + classInstanceOffset);
    InterfaceSlot interfaceSlots[interfaceSlotRecordCount] @ (__chunkStart + interfaceSlotOffset);
} [[fixed_size(Size)]];

enum OpCodeType : u16 {
// ---------- DX 10 op codes---------------------
    Add,
    And,
    Break,
    BreakC,
    Call,
    CallC,
    Case,
    Continue,
    ContinueC,
    Cut,
    Default,
    DerivRtx,
    DerivRty,
    Discard,
    Div,
    Dp2,
    Dp3,
    Dp4,
    Else,
    Emit,
    EmitThenCut,
    EndIf,
    EndLoop,
    EndSwitch,
    Eq,
    Exp,
    Frc,
    FToI,
    FToU,
    Ge,
    IAdd,
    If,
    IEq,
    IGe,
    ILt,
    IMad,
    IMax,
    IMin,
    IMul,
    INe,
    INeg,
    IShl,
    IShr,
    IToF,
    Label,
    Ld,
    LdMS,
    Log,
    Loop,
    Lt,
    Mad,
    Min,
    Max,
    CustomData,
    Mov,
    MovC,
    Mul,
    Ne,
    Nop,
    Not,
    Or,
    ResInfo,
    Ret,
    RetC,
    RoundNe,
    RoundNi,
    RoundPi,
    RoundZ,
    Rsq,
    Sample,
    SampleC,
    SampleCLz,
    SampleL,
    SampleD,
    SampleB,
    Sqrt,
    Switch,
    SinCos,
    UDiv,
    ULt,
    UGe,
    UMul,
    UMad,
    UMax,
    UMin,
    UShr,
    UToF,
    Xor,
    DclResource, // DCL* opcodes have
    DclConstantBuffer, // custom operand formats.
    DclSampler,
    DclIndexRange,
    DclGsOutputPrimitiveTopology,
    DclGsInputPrimitive,
    DclMaxOutputVertexCount,
    DclInput,
    DclInputSgv,
    DclInputSiv,
    DclInputPs,
    DclInputPsSgv,
    DclInputPsSiv,
    DclOutput,
    DclOutputSgv,
    DclOutputSiv,
    DclTemps,
    DclIndexableTemp,
    DclGlobalFlags,
// ----------------------------------------------
    Reserved0,
// ---------- DX 10.1 op codes-------------------
    Lod,
    Gather4,
    SamplePos,
    SampleInfo,
// ----------------------------------------------
    Reserved1,
// ---------- DX 11 op codes---------------------
    HsDecls, // token marks beginning of HS sub-shader
    HsControlPointPhase, // token marks beginning of HS sub-shader
    HsForkPhase, // token marks beginning of HS sub-shader
    HsJoinPhase, // token marks beginning of HS sub-shader
    EmitStream,
    CutStream,
    EmitThenCutStream,
    InterfaceCall,
    BufInfo,
    DerivRtxCoarse,
    DerivRtxFine,
    DerivRtyCoarse,
    DerivRtyFine,
    Gather4C,
    Gather4Po,
    Gather4PoC,
    Rcp,
    F32ToF16,
    F16ToF32,
    UAddC,
    USubB,
    CountBits,
    FirstBitHi,
    FirstBitLo,
    FirstBitShi,
    UBfe,
    IBfe,
    Bfi,
    Bfrev,
    SwapC,
    DclStream,
    DclFunctionBody,
    DclFunctionTable,
    DclInterface,
    DclInputControlPointCount,
    DclOutputControlPointCount,
    DclTessDomain,
    DclTessPartitioning,
    DclTessOutputPrimitive,
    DclHsMaxTessfactor,
    DclHsForkPhaseInstanceCount,
    DclHsJoinPhaseInstanceCount,
    DclThreadGroup,
    DclUnorderedAccessViewTyped,
    DclUnorderedAccessViewRaw,
    DclUnorderedAccessViewStructured,
    DclThreadGroupSharedMemoryRaw,
    DclThreadGroupSharedMemoryStructured,
    DclResourceRaw,
    DclResourceStructured,
    LdUavTyped,
    StoreUavTyped,
    LdRaw,
    StoreRaw,
    LdStructured,
    StoreStructured,
    AtomicAdd,
    AtomicOr,
    AtomicXor,
    AtomicCmpStore,
    AtomicIAdd,
    AtomicIMax,
    AtomicIMin,
    AtomicUMax,
    AtomicUMin,
    ImmAtomicAlloc,
    ImmAtomicConsume,
    ImmAtomicIAdd,
    ImmAtomicAnd,
    ImmAtomicOr,
    ImmAtomicXor,
    ImmAtomicExch,
    ImmAtomicCmpExch,
    ImmAtomicIMax,
    ImmAtomicIMin,
    ImmAtomicUMax,
    ImmAtomicUMin,   
    Sync,
    DAdd,
    DMax,
    DMin,
    DMul,
    DEq,
    DGe,
    DLt,
    DNe,
    DMov,
    DMovC,
    DToF,
    FToD,
    EvalSnapped,
    EvalSampleIndex,
    EvalCentroid,
    DclGsInstanceCount,
    Abort,
    DebugBreak,
// ----------------------------------------------
    Reserved2,
// ---------- DX 11.1 op codes-------------------
    DDiv,
    DFma,
    DRcp,
    MSAD,
    DToI,
    DToU,
    IToD,
    UToD,
// ----------------------------------------------
    Reserved3,
// ---------- WDDM 1.3 op codes------------------
    Gather4Feedback,
    Gather4CFeedback,
    Gather4PoFeedback,
    Gather4PoCFeedback,
    LdFeedback,
    LdMsFeedback,
    LdUavTypedFeedback,
    LdRawFeedback,
    LdStructuredFeedback,
    SampleLFeedback,
    SampleCLzFeedback,
    SampleClampFeedback,
    SampleBClampFeedback,
    SampleDClampFeedback,
    SampleCClampFeedback,
    CheckAccessFullyMapped,
// ----------------------------------------------
    Reserved4,
};

bitfield ShdrOpCodeToken {
    OpCodeType opCode : 11;
    controls : 13;
    length : 7;
    extended : 1;
};

struct ShdrInstruction {
    ShdrOpCodeToken opCode;
    type::Hex<u32> body[opCode.length - 1];
} [[format("format_shdr_instruction")]];

fn format_shdr_instruction(ShdrInstruction instr) {
    return std::string::replace(std::format("{}", instr.opCode.opCode), "OpCodeType::", "");
};

struct ShdrChunk<auto Size> {
    auto __chunkStart = $;
    type::Hex<u32> programVersion [[name("Program version")]];
    u32 tokenCount [[name("Token count")]];
    ShdrInstruction instructions[while(!std::mem::reached(__chunkStart + Size))] [[name("Tokens")]];
} [[fixed_size(Size)]];

struct StatChunk<auto Size> {
    auto __chunkStart = $;
    u32 instructionCount;
    u32 tempRegisterCount;
    u32 defineCount;
    u32 declarationCount;
    u32 floatInstructionCount;
    u32 intInstructionCount;
    u32 uintInstructionCount;
    u32 staticFlowControlCount;
    u32 dynamicFlowControlCount;
    u32 macroInstructionCount;
    u32 tempArrayCount;
    u32 arrayInstructionCount;
    u32 cutInstructionCount;
    u32 emitInstructionCount;
    u32 textureNormalInstructions;
    u32 textureLoadInstructions;
    u32 textureComparisonInstructions;
    u32 textureBiasInstructions;
    u32 textureGradientInstructions;
    u32 movInstructionCount;
    u32 movcInstructionCount;
    u32 conversionInstructionCount;
    u32 statUnk1;
    if (statUnk1 != 0) {
        std::warning(std::format("statUnk1 = {}\n", statUnk1));
    }
    u32 inputPrimitiveForGeometryShaders;
    u32 geometryShaderPrimitiveTopology;
    u32 geometryShaderMaxOutputVertexCount;
    u32 statUnk2;
    if (statUnk2 != 0) {
        std::warning(std::format("statUnk2 = {}\n", statUnk2));
    }
    u32 statUnk3;
    if (statUnk3 != 0) {
        std::warning(std::format("statUnk3 = {}\n", statUnk3));
    }
    u32 isSampleFrequencyShader;
    if (Size > $ - __chunkStart) {
        u32 statUnk4;
        if (statUnk4 != 0) {
            std::warning(std::format("statUnk4 = {}\n", statUnk4));
        }
        u32 controlPoints;
        u32 hullShaderOutputPrimitive;
        u32 hullShaderPartitioning;
        u32 tessellatorDomain;
        u32 barrierInstructions;
        u32 interlockedInstructions;
        u32 textureStoreInstructions;
    }
} [[fixed_size(Size)]];

struct Chunk {
    u32 offset [[name("Offset")]];
    char type[4] @ offset [[name("Type")]];
    type::Size32 size @ (offset + 4) [[name("Size")]];
    match (type) {
        ("RDEF"): RdefChunk<size> rdef @ (offset + 8) [[name("RDEF data")]];
        ("ISGN"): SgnChunk<size> isgn @ (offset + 8) [[name("ISGN data")]];
        ("PCSG"): SgnChunk<size> pcsg @ (offset + 8) [[name("PCSG data")]];
        ("OSGN"): SgnChunk<size> osgn @ (offset + 8) [[name("OSGN data")]];
        ("IFCE"): IfceChunk<size> ifce @ (offset + 8) [[name("IFCE data")]];
        ("SHDR"): ShdrChunk<size> shdr @ (offset + 8) [[name("SHDR data")]];
        ("SHEX"): ShdrChunk<size> shex @ (offset + 8) [[name("SHEX data")]];
        ("STAT"): StatChunk<size> stat @ (offset + 8) [[name("STAT data")]];
    }
};

Header header @ $ [[name("DXBC header")]];
Chunk chunks[header.chunkCount] @ $ [[name("Chunks")]];
