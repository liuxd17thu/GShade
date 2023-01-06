// Made by Marot Satil, seri14, & Uchu Suzume for the GShade ReShade package!
// You can follow me via @MarotSatil on Twitter, but I don't use it all that much.
// Follow @GPOSERS_FFXIV on Twitter and join us on Discord (https://discord.gg/39WpvU2)
// for the latest GShade package updates!
//
// This shader was designed in the same vein as GreenScreenDepth.fx, but instead of applying a
// green screen with adjustable distance, it applies a PNG texture with adjustable opacity.
//
// PNG transparency is fully supported, so you could for example add another moon to the sky
// just as readily as create a "green screen" stage like in real life.
//
// Copyright (c) 2023, Marot Satil
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, the header above it, this list of conditions, and the following disclaimer
//    in this position and unchanged.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, the header above it, this list of conditions, and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#define STAGEDEPTH_SUMMONING(StageDepth_Texture, StageDepthTex, StageDepth_Size_X, StageDepth_Size_Y, StageDepth_Texformat, StageDepth_Sampler, StageDepth_BlendMode, StageDepth_Category, StageDepth_Opacity, StageDepth_Depth, STAGEDEPTH_SCALE, StageDepth_ScaleX, StageDepth_ScaleY, StageDepth_PosX, StageDepth_PosY, StageDepth_SnapRotate, StageDepth_Rotate, StageDepth_InvertDepth, PS_StageDepth, STAGEDEPTH_NAME) \
texture StageDepth_Texture <source=StageDepthTex;> { Width = StageDepth_Size_X; Height = StageDepth_Size_Y; Format=StageDepth_Texformat; }; \
\
sampler StageDepth_Sampler { Texture = StageDepth_Texture; }; \
\
BLENDING_COMBO(StageDepth_BlendMode, "Blending Mode", "Select the blending mode applied to the layer.", StageDepth_Category, true, 0, 0) \
\
uniform float StageDepth_Opacity < \
	ui_category = StageDepth_Category; \
    ui_label = "Blending"; \
    ui_tooltip = "The amount of blending applied to the image."; \
    ui_type = "slider"; \
    ui_min = 0.0; \
    ui_max = 1.0; \
    ui_step = 0.002; \
> = 1.0; \
\
uniform float StageDepth_Depth < \
	ui_category = StageDepth_Category; \
    ui_type = "slider"; \
    ui_min = 0.0; \
    ui_max = 1.0; \
    ui_label = "Depth"; \
> = 0.97; \
\
uniform float STAGEDEPTH_SCALE < \
	ui_category = StageDepth_Category; \
    ui_type = "slider"; \
    ui_label = "Scale X & Y"; \
    ui_min = 0.001; ui_max = 5.0; \
    ui_step = 0.001; \
> = 1.001; \
\
uniform float StageDepth_ScaleX < \
	ui_category = StageDepth_Category; \
    ui_type = "slider"; \
    ui_label = "Scale X"; \
    ui_min = 0.001; ui_max = 5.0; \
    ui_step = 0.001; \
> = 1.0; \
\
uniform float StageDepth_ScaleY < \
	ui_category = StageDepth_Category; \
    ui_type = "slider"; \
    ui_label = "Scale Y"; \
    ui_min = 0.001; ui_max = 5.0; \
    ui_step = 0.001; \
> = 1.0; \
\
uniform float StageDepth_PosX < \
	ui_category = StageDepth_Category; \
    ui_type = "slider"; \
    ui_label = "Position X"; \
    ui_min = -2.0; ui_max = 2.0; \
    ui_step = 0.001; \
> = 0.5; \
\
uniform float StageDepth_PosY < \
	ui_category = StageDepth_Category; \
    ui_type = "slider"; \
    ui_label = "Position Y"; \
    ui_min = -2.0; ui_max = 2.0; \
    ui_step = 0.001; \
> = 0.5; \
\
uniform int StageDepth_SnapRotate < \
	ui_category = StageDepth_Category; \
    ui_type = "combo"; \
	ui_label = "Snap Rotation"; \
    ui_items = "None\0" \
               "90 Degrees\0" \
               "-90 Degrees\0" \
               "180 Degrees\0" \
               "-180 Degrees\0"; \
	ui_tooltip = "Snap rotation to a specific angle."; \
> = false; \
\
uniform float StageDepth_Rotate < \
	ui_category = StageDepth_Category; \
    ui_label = "Rotate"; \
    ui_type = "slider"; \
    ui_min = -180.0; \
    ui_max = 180.0; \
    ui_step = 0.01; \
> = 0; \
\
uniform bool StageDepth_InvertDepth < \
	ui_category = StageDepth_Category; \
	ui_label = "Invert Depth"; \
	ui_tooltip = "Inverts the depth buffer so that the texture is applied to the foreground instead."; \
> = false; \
\
void PS_StageDepth(in float4 position : SV_Position, in float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) \
{ \
    passColor = tex2D(ReShade::BackBuffer, texCoord); \
    const float depth = Stage_InvertDepth ? ReShade::GetLinearizedDepth(texCoord).r : 1 - ReShade::GetLinearizedDepth(texCoord).r; \
\
    if (depth < StageDepth_Depth) \
    { \
        const float3 backColor = tex2D(ReShade::BackBuffer, texCoord).rgb; \
        const float3 pivot = float3(0.5, 0.5, 0.0); \
        const float AspectX = (1.0 - BUFFER_WIDTH * (1.0 / BUFFER_HEIGHT)); \
        const float AspectY = (1.0 - BUFFER_HEIGHT * (1.0 / BUFFER_WIDTH)); \
        const float3 mulUV = float3(texCoord.x, texCoord.y, 1); \
        const float2 ScaleSize = (float2(STAGE_SIZE_X, STAGE_SIZE_Y) * STAGEDEPTH_SCALE / BUFFER_SCREEN_SIZE); \
        const float ScaleX =  ScaleSize.x * AspectX * StageDepth_ScaleX; \
        const float ScaleY =  ScaleSize.y * AspectY * StageDepth_ScaleY; \
        float Rotate = StageDepth_Rotate * (3.1415926 / 180.0); \
\
        switch(StageDepth_SnapRotate) \
        { \
            default: \
                break; \
            case 1: \
                Rotate = -90.0 * (3.1415926 / 180.0); \
                break; \
            case 2: \
                Rotate = 90.0 * (3.1415926 / 180.0); \
                break; \
            case 3: \
                Rotate = 0.0; \
                break; \
            case 4: \
                Rotate = 180.0 * (3.1415926 / 180.0); \
                break; \
        } \
\
        const float3x3 positionMatrix = float3x3 ( \
            1, 0, 0, \
            0, 1, 0, \
            -StageDepth_PosX, -StageDepth_PosY, 1 \
        ); \
        const float3x3 scaleMatrix = float3x3 ( \
            1/ScaleX, 0, 0, \
            0,  1/ScaleY, 0, \
            0, 0, 1 \
        ); \
        const float3x3 rotateMatrix = float3x3 ( \
            (cos (Rotate) * AspectX), (sin(Rotate) * AspectX), 0, \
            (-sin(Rotate) * AspectY), (cos(Rotate) * AspectY), 0, \
            0, 0, 1 \
        ); \
\
        const float3 SumUV = mul (mul (mul (mulUV, positionMatrix), rotateMatrix), scaleMatrix); \
        passColor = tex2D(StageDepth_Sampler, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot)); \
\
        passColor.rgb = ComHeaders::Blending::Blend(Stage_BlendMode, backColor, passColor.rgb, passColor.a * StageDepth_Opacity); \
    } \
} \
\
technique STAGEDEPTH_NAME \
{ \
    pass \
    { \
        VertexShader = PostProcessVS; \
        PixelShader = PS_StageDepth; \
    } \
} \