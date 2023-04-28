/*
* ScreenFX Shader v0.4 (SHADER)
* Shader Written by David Ryan
* Last Updated 11/29/2022
*
* Changelog:
* ----------------------
*   v0.1 (08/11/2022)
* ----------------------
* [+] Shader Base Created
* [+] Zoom
* [+] Screen Shake
* [+] Rotation
* [+] Blur (Radial, Lens & Rotational)
* [+] Edge Glow (+ Rays)
* [+] Distortion (Simplex3D Noise)
* [+] Grayscale
* [+] Film Grain (Hash21 Noise)
* [+] Vignette
* [+] Scanlines
* [+] Motion Blur (Experimental)
* ----------------------
*   v0.2 (09/07/2022)
* ----------------------
* [+] Fisheye Zoom
* [+] Girlscam
* [+] Glitch (Uncolored & RGB)
* [+] Letterbox
* [+] Mirrored Screens (Experimental, Doesn't work in VR)
* [+] Texture Overlay (Up to 5 Textures) (Only Overrendering, Working on a non-overrendering one currently)
* [+] Depth of Field
* [~] Cleaned up the code quite a bit
* [~] Various Bug Fixes
* ----------------------
*   v0.3 (10/16/2022)
* ----------------------
* [+] Vignette Color
* [+] Move
* [+] Color Grading (WIP, Only Exposure Currently)
* [+] Color to Mask
* [+] Ghost Zoom
* ----------------------
*   v0.4 (11/29/2022)
* ----------------------
* [+] Pixelation
* [~] Minor Tweaks
*/

Shader "David Ryan/ScreenFX"
{
    Properties
    {
        [HideInInspector] shader_is_using_thry_editor("", Float) = 0
        [HideInInspector] shader_master_label("<b><color=#ffffff> ֍ David Ryan's <color=#fff457>ScreenFX</color> Shader <color=#b31542>v0.4</color> ֍ </color></b>", Float) = 0


        [HideInInspector] m_start_MainSettings("Main Settings", float) = 0
        [Toggle(_)] _ParticleSystemToggle("Particle System Renderer", int) = 1
        [Vector2] _Fade("Fade (Start, End)", vector) = (4, 5, 0, 0)
        [HideInInspector] m_start_GrabPassColorSettings("Grab Pass Settings", float) = 0
        [Toggle(_)] _UVClampToggle("Clamp UV", int) = 1
        _UVBorderColor("UV Background Color", color) = (0, 0, 0, 1)
        _GrabPassColor("Grab Pass Color", color) = (1, 1, 1)
        [HideInInspector] m_end_GrabPassColorSettings("", float) = 0
        [HideInInspector] m_end_MainSettings("", float) = 0


        [HideInInspector] m_start_ZoomSettings("Zoom", float) = 0
        [Toggle(_)] _ZoomToggle("Enable Zoom", int) = 0
        [Enum(Simple, 0, Fisheye, 1, Warp, 2)] _ZoomEnum("Zoom Mode", int) = 0
        _ZoomAmount("Zoom Amount", Range(-1, 1)) = 0

        [HideInInspector] m_start_MirroredScreensSettings("Mirrored Screens", float) = 0
        [Toggle(_)] _MirroredScreensToggle("Enable Mirrored Screens", int) = 0
        _MirroredScreensScale("Scale", Range(0, 1)) = 0.25
        _MirroredScreensAlpha("Intensity", Range(0, 1)) = 1
        [HideInInspector] m_end_ShakeSettings("", float) = 0

        [HideInInspector] m_end_ZoomSettings("", float) = 0


        [HideInInspector] m_start_MoveSettings("Move", float) = 0
        [Toggle(_)] _MoveToggle("Enable Move", int) = 0
        [Vector2] _MoveVector("Screen Translation (X, Y)", vector) =  (0, 0, 0, 0)
        [HideInInspector] m_end_MoveSettings("", float) = 0


        [HideInInspector] m_start_ShakeSettings("Screen Shake", float) = 0
        [Toggle(_)] _ScreenShakeToggle("Enable Screen Shake", int) = 0
        _ScreenShakeSpeedX("Shake Speed (X)", Range(0, 50)) = 3
        _ScreenShakeSpeedY("Shake Speed (Y)", Range(0, 50)) = 2
        _ScreenShakeRange("Intensity", Range(0, 3)) = 0.5
        [HideInInspector] m_end_ShakeSettings("", float) = 0


        [HideInInspector] m_start_RotationSettings("Rotation", float) = 0
        [Toggle(_)] _RotationToggle("Enable Rotation", int) = 0
        _RotationSpeed("Speed", Range(0, 10)) = 0
        _RotationAmount("Rotation Amount", Range(-360, 360)) = 0
        _RotationOffset("Manual Offset", Range(-360, 360)) = 0
        [HideInInspector] m_end_RotationSettings("", float) = 0


        [HideInInspector] m_start_GirlscamSettings("Girlscam", float) = 0
        [Toggle(_)] _GirlscamToggle("Enable Girlscam", int) = 0
        _GirlscamIntensity("Intensity", Range(0, 1)) = 0
        [HideInInspector] _GirlscamScale("Scale", Range(0.05, 2)) = 1
        [HideInInspector] m_end_GirlscamSettings("", float) = 0


        [HideInInspector] m_start_GlitchSettings("Glitch", float) = 0
        [Toggle(_)] _GlitchToggle("Enable Glitch", int) = 0
        [Enum(No Color Shift, 0, RGB, 1)] _GlitchModeEnum("Glitch Mode", int) = 0
        _GlitchIntensity("Intensity", Range(0, 1)) = 0.15
        _GlitchSpeed("Speed", Range(0, 1)) = 0.3
        [HideInInspector] m_end_GlitchSettings("", float) = 0


        [HideInInspector] m_start_BlurSettings("Blur", float) = 0
        [Toggle(_)] _BlurToggle("Enable Blur", int) = 0
        [Enum(Radial Blur, 0, Lens Blur, 1, Rotation Blur, 2)]
        _BlurEnum("Blur Type", int) = 0
        [IntRange] _BlurSamples("Blur Samples", Range(1, 256)) = 32
        _BlurAmount("Blur Amount", Range(0, 100)) = 0
        [Vector2] _BlurMask("Blur Mask (Min, Max)", vector) = (-1, 1, 0, 0)
        [HideInInspector] m_end_BlurSettings("", float) = 0


        [HideInInspector] m_start_EdgeGlowSettings("Edge Glow", float) = 0
        [Toggle(_)] _EdgeGlowToggle("Enable Edge Glow", int) = 0
        _EdgeGlowColor("Glow Color", color) = (1, 0, 0, 1)
        _EdgeGlowBackgroundColor("Background Color", color) = (1, 1, 1, 1)
        _EdgeGlowOffset("Offset", Range(0, 10)) = 3
        _EdgeGlowPower("Power", Range(0, 10)) = 5

        [HideInInspector] m_start_EdgeGlowRaySettings("Rays", float) = 0
        [Toggle(_)] _EdgeGlowRaysToggle("Enable Rays", int) = 0
        [IntRange] _RaySamples("Ray Samples", Range(1, 256)) = 32
        _RayDistance("Ray Distance", Range(0, 10)) = 0.5
        [HideInInspector] m_end_EdgeGlowRaySettings("", float) = 0

        [HideInInspector] m_end_EdgeGlowSettings("", float) = 0


        [HideInInspector] m_start_DistortionSettings("Distortion", float) = 0
        [Toggle(_)] _DistortionToggle("Enable Distortion", int) = 0
        _TotalDistortion("Total Distortion", Range(0, 1)) = 1
        _DistortionPower("Size", Range(0, 3)) = 0.5
        [Vector2] _DistortionSpeed("Speed", vector) = (5, 3, 0, 0)
        [Vector2] _DistortionTiling("Tiling", vector) = (2, 1, 0, 0)
        _DistortionMin("Minimum", Range(0, 1)) = 0
        _DistortionMax("Maximum", Range(0, 10)) = 3
        [HideInInspector] m_end_DistortionSettings("", float) = 0


        [HideInInspector] m_start_ColorGradingSettings("Color Grading", float) = 0
        [Toggle(_)] _ColorGradingToggle("Enable Color Grading", int) = 0
        [Enum(None, 0, ACES, 1)] _ColorGradingEnum("Mode", int) = 0
        _ExposureIntensity("Exposure", Range(1, 5)) = 1
        [HideInInspector] m_end_ColorGradingSettings("", float) = 0


        [HideInInspector] m_start_GrayscaleSettings("Grayscale", float) = 0
        [Toggle(_)] _GrayscaleToggle("Enable Grayscale", int) = 0
        _GrayscaleAlpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_GrayscaleSettings("", float) = 0


        [HideInInspector] m_start_GrainSettings("Grain", float) = 0
        [Toggle(_)] _GrainToggle("Enable Grain", int) = 0
        _GrainColor("Color", color) = (0, 0, 0)
        _GrainAlpha("Transparency", Range(0, 2)) = 0.4
        [HideInInspector] m_end_GrainSettings("", float) = 0


        [HideInInspector] m_start_TextureOverlay1Settings("Texture Overlay", float) = 0
        [Toggle(_)] _TextureOverlay1Toggle("Enable Texture Overlay", int) = 0
        [Toggle(_)] _TextureOverlay1Clamp("Clamp Texture", int) = 0
        [Enum(No Overrendering, 0, Overrendering, 1)] _TextureOverlay1Enum("Texture Mode", int) = 0

        // Image 1
        [BigTexture] _Image1("Texture", 2D) = "White" {}
        [Vector2] _Image1Scale("Scale", vector) = (1, 1, 0, 0)
        [Vector2] _Image1Offset("Offset (X, Y)", vector) = (0, 0, 0, 0)
        _Image1Rotation("Rotation", Range(-360, 360)) = 0
        _Image1Alpha("Transparency", Range(0, 1)) = 1

        // Image 2
        [HideInInspector] m_start_TextureOverlay2Settings("Texture 2", float) = 0
        [Toggle(_)] _TextureOverlay2Toggle("Enable Texture Overlay", int) = 0
        [Toggle(_)] _TextureOverlay2Clamp("Clamp Texture", int) = 0
        [Enum(No Overrendering, 0, Overrendering, 1)] _TextureOverlay2Enum("Texture Mode", int) = 0
        [BigTexture] _Image2("Texture", 2D) = "White" {}
        [Vector2] _Image2Scale("Scale", vector) = (1, 1, 0, 0)
        [Vector2] _Image2Offset("Offset (X, Y)", vector) = (0, 0, 0, 0)
        _Image2Rotation("Rotation", Range(-360, 360)) = 0
        _Image2Alpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_TextureOverlay2Settings("", float) = 0

        // Image 3
        [HideInInspector] m_start_TextureOverlay3Settings("Texture 3", float) = 0
        [Toggle(_)] _TextureOverlay3Toggle("Enable Texture Overlay", int) = 0
        [Toggle(_)] _TextureOverlay3Clamp("Clamp Texture", int) = 0
        [Enum(No Overrendering, 0, Overrendering, 1)] _TextureOverlay3Enum("Texture Mode", int) = 0
        [BigTexture] _Image3("Texture", 2D) = "White" {}
        [Vector2] _Image3Scale("Scale", vector) = (1, 1, 0, 0)
        [Vector2] _Image3Offset("Offset (X, Y)", vector) = (0, 0, 0, 0)
        _Image3Rotation("Rotation", Range(-360, 360)) = 0
        _Image3Alpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_TextureOverlay3Settings("", float) = 0

        // Image 4
        [HideInInspector] m_start_TextureOverlay4Settings("Texture 4", float) = 0
        [Toggle(_)] _TextureOverlay4Toggle("Enable Texture Overlay", int) = 0
        [Toggle(_)] _TextureOverlay4Clamp("Clamp Texture", int) = 0
        [Enum(No Overrendering, 0, Overrendering, 1)] _TextureOverlay4Enum("Texture Mode", int) = 0
        [BigTexture] _Image4("Texture", 2D) = "White" {}
        [Vector2] _Image4Scale("Scale", vector) = (1, 1, 0, 0)
        [Vector2] _Image4Offset("Offset (X, Y)", vector) = (0, 0, 0, 0)
        _Image4Rotation("Rotation", Range(-360, 360)) = 0
        _Image4Alpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_TextureOverlay4Settings("", float) = 0

        // Image 5
        [HideInInspector] m_start_TextureOverlay5Settings("Texture 5", float) = 0
        [Toggle(_)] _TextureOverlay5Toggle("Enable Texture Overlay", int) = 0
        [Toggle(_)] _TextureOverlay5Clamp("Clamp Texture", int) = 0
        [Enum(No Overrendering, 0, Overrendering, 1)] _TextureOverlay5Enum("Texture Mode", int) = 0
        [BigTexture] _Image5("Texture", 2D) = "White" {}
        [Vector2] _Image5Scale("Scale", vector) = (1, 1, 0, 0)
        [Vector2] _Image5Offset("Offset (X, Y)", vector) = (0, 0, 0, 0)
        _Image5Rotation("Rotation", Range(-360, 360)) = 0
        _Image5Alpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_TextureOverlay5Settings("", float) = 0

        [HideInInspector] m_end_TextureOverlay1Settings("", float) = 0


        [HideInInspector] m_start_ColorToMaskSettings("Color To Mask", float) = 0
        [Toggle(_)] _ColorToMaskToggle("Enable Color to Mask", int) = 0
        _ColorToMaskForgiveness("Forgiveness", Range(0, 1)) = 0
        
        [HDR] _ColorOne("First Color", color) = (0, 0, 0, 1)
        [HDR] _ColorTwo("Second Color", color) = (1, 1, 1, 1)
        _ColorToMaskMin("Minimum", Range(0, 1)) = 1
        _ColorToMaskMax("Maximum", Range(0, 1)) = 0
        _ColorToMaskAlpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_ColorToMaskSettings("", float) = 0


        [HideInInspector] m_start_VignetteSettings("Vignette", float) = 0
        [Toggle(_)] _VignetteToggle("Enable Vignette", int) = 0
        _VignetteColor("Color", color) = (0, 0, 0)
        _VignetteSize("Amount", Range(0, 1)) = 0.3
        _VignetteAlpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_VignetteSettings("", float) = 0


        [HideInInspector] m_start_ScanlineSettings("Scanlines", float) = 0
        [Toggle(_)] _ScanlineToggle("Enable Scanlines", int) = 0
        _ScanlineColor("Color", color) = (0, 0, 0)
        _ScanlineCount("Line Count", Range(32, 1200)) = 800
        _ScanlineSpeed("Speed", Range(0.25, 1)) = 0.4
        _ScanlineAlpha("Transparency", Range(0, 1)) = 0.5
        [HideInInspector] m_end_VignetteSettings("", float) = 0


        [HideInInspector] m_start_LetterboxSettings("Letterbox", float) = 0
        [Toggle(_)] _LetterboxToggle("Enable Letterbox", int) = 0
        _LetterboxColor("Color", color) = (0, 0, 0)
        _LetterboxTBDistance("Vertical Distance", Range(1, 0)) = 0.75
        _LetterboxLRDistance("Horizontal Distance", Range(1, 0)) = 1
        _LetterboxAlpha("Transparency", Range(0, 1)) = 1
        [HideInInspector] m_end_LetterboxSettings("", float) = 0


        [HideInInspector] m_start_PixelateSettings("Pixelate", float) = 0
        [Toggle(_)] _PixelationToggle("Enable Pixelation", int) = 0
        _PixelationIntensity("Intensity", Range(0.1, 15)) = 3
        [Vector2] _PixelSize("Pixel Size", vector) = (500.0, 275.0, 0, 0)
        [HideInInspector] m_end_PixelateSettings("", float) = 0


        [HideInInspector] m_start_AdvancedSettings("Advanced Settings", float) = 0

        [HideInInspector] m_start_DepthLightSettings("Depth Texture Effects", float) = 0
        [Helpbox] _WarnBox("NOTE: For these effects to work in VRChat you will need a 'Depth Light'.", Float) = 0

        [HideInInspector] m_start_DoFSettings("Depth of Field", float) = 0
        [Toggle(_)] _DoFToggle("Enable Depth of Field", int) = 0
        _DoFSamples("Samples", Range(1, 256)) = 32
        _DoFFocalDistance("Focal Distance", Range(0, 10)) = 5
        _DoFAlpha("Aperature Width", Range(0, 1)) = 1
        [HideInInspector] m_end_DoFSettings("", float) = 0

        [HideInInspector] m_start_GhostZoomSettings("Ghost Zoom", float) = 0
        [Toggle(_)] _GhostZoomToggle("Enable Ghost Zoom", int) = 0
        _GhostZoomSpeed("Zoom Speed (0 = Manual)", Range(-5, 5)) = 0
        _GhostZoomAmount("Offset Distance", Range(0, 1)) = 0.5
        _GhostZoomTransparency("Transparency", Range(0, 1)) = 0.5
        _GhostZoomMin("Minimum Depth", Range(0, 1)) = 1
        _GhostZoomMax("Maximum Depth", Range(0, 1)) = 0
        [HideInInspector] m_end_GhostZoomSettings("", float) = 0
        
        [HideInInspector] m_end_DepthLightSettings("", float) = 0


        [HideInInspector] m_end_AdvancedSettings("", float) = 0


        [HideInInspector] m_start_ExperimentalSettings("Experimental (WIP)", float) = 0

        [HideInInspector] m_start_MotionBlurSettings("Motion Blur", float) = 0
        [Toggle(_)] _MotionBlurToggle("Enable Motion Blur", int) = 0
        _MotionBlurZoom("Zoom", Range(-0.005, 0.005)) = 0
        _MotionBlurAlpha("Intensity", Range(0, 1)) = 0
        [HideInInspector] m_end_MotionBlurSettings("", float) = 0 

        /*[HideInInspector] m_start_SSAOSettings("Ambient Occlusion", float) = 0
        [Toggle(_)] _SSAOToggle("Enable SSAO", int) = 0
        [IntRange] _SSAOSamples("Samples", Range(1, 256)) = 8
        _SSAOAlpha("Intensity", Range(0, 1)) = 0
        [HideInInspector] m_end_MotionBlurSettings("", float) = 0*/

        [HideInInspector] m_end_ExperimentalSettings("", float) = 0

        [Helpbox] _WarnBox("WARNING: This Shader may potentially trigger seizures for people with photosensitive epilepsy. Viewer discretion is advised.", Float) = 0
    }
    CustomEditor "Thry.ShaderEditor"
    // CustomEditor "David Ryan.CustomEditor" // Test
    SubShader 
  {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+29767" }
        //Cull Off
        ZWrite Off
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass { "_GrabPass" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "ScreenFX.cginc"

            struct appdata
            {
                float4 vertex       : POSITION;
                float4 vertexColor  : Color;
                float4 uv           : TEXCOORD0;
                float4 center       : TEXCOORD1;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

             struct v2f
            {
                float4 uv           : TEXCOORD0;
                float3 world        : TEXCOORD1;
                float3 iuv          : TEXCOORD2;
                float fade          : TEXCOORD3;
                float4 center       : TEXCOORD4;
                float4 data         : TEXCOORD5;
                float4 vertex       : SV_POSITION;
                float4 vertexColor  : Color;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            float2 _Fade;
            inline float3 _WSCameraPosition()
            {
                #if UNITY_SINGLE_PASS_STEREO
                    return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1])0.5;
                #else
                    return _WorldSpaceCameraPos;
                #endif
            }

            static float3 CameraPos = _WSCameraPosition();

            int IsInMirror() { return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f; }
            int _ParticleSystemToggle;

            v2f vert(appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_BRANCH if (IsInMirror()) return o;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                float4 pos = 0.0;
                fixed3 center = 0, uv = v.vertex * 10;
                
                UNITY_BRANCH if (_ParticleSystemToggle)
                {
                    pos = mul(unity_WorldToObject, mul(unity_CameraToWorld, v.vertex - float4(center, 0)));
                    center = v.center.xyz;
                    uv = 10 * (v.vertex - center);
                    o.vertexColor = v.vertexColor.w;
                }
                else
                {
                    pos = mul(unity_WorldToObject, mul(unity_CameraToWorld, v.vertex));
                    o.vertexColor = 1.0;
                }

                float d = distance(CameraPos, mul(unity_ObjectToWorld, float4(center, 1)).xyz);
                o.fade = (1 - (clamp(d, _Fade.x, _Fade.y) - _Fade.x) / (_Fade.y - _Fade.x));
                half dist = o.fade;
                
                UNITY_BRANCH if (dist > _Fade.y)
                {
                    o.vertex = half4(center, 1);
                    return o;
                }

                o.uv = ComputeGrabScreenPos(UnityViewToClipPos(uv));
                o.center = ComputeGrabScreenPos(UnityViewToClipPos(half4(0.0, 0.0, 1.0, 1.0)));
                o.vertex = UnityViewToClipPos(uv);
                o.vertexColor = v.vertexColor;
                o.iuv = uv;
                o.world = normalize(mul((fixed3x3)UNITY_MATRIX_I_V, -uv));
                o.data.xyz = mul(UNITY_MATRIX_V, mul(unity_ObjectToWorld, pos).xyz - CameraPos);
                
                return o;
            }

            sampler2D _GrabPass;
            float4 _GrabPass_ST;

            sampler2D _CameraDepthTexture;

            // -----------------------------------
            //             UV Keywords

            // Zoom
            int _ZoomToggle, _ZoomEnum;
            float _ZoomAmount;

            // Move
            int _MoveToggle;
            float2 _MoveVector;

            // Screen Shake
            int _ScreenShakeToggle;
            float _ScreenShakeSpeedX, _ScreenShakeSpeedY, _ScreenShakeRange;

            // Girlscam
            int _GirlscamToggle;
            float _GirlscamIntensity, _GirlscamScale;

            // Glitch
            int _GlitchToggle, _GlitchModeEnum;
            float _GlitchIntensity, _GlitchSpeed;

            // Mirrored Screens
            int _MirroredScreensToggle;
            float _MirroredScreensScale, _MirroredScreensAlpha;

            // Rotation
            int _RotationToggle;
            float _RotationSpeed, _RotationAmount, _RotationOffset;

            // Distortion
            int _DistortionToggle;
            float2 _DistortionTiling, _DistortionSpeed;
            float _DistortionPower, _DistortionMin, _DistortionMax, _TotalDistortion;

            // Pixelation
            int _PixelationToggle;
            float _PixelationIntensity;
            float2 _PixelSize;

            // Grain
            int _GrainToggle, _GrainMode;
            float _GrainAlpha;
            float3 _GrainColor;

            // -----------------------------------


            // -----------------------------------
            //          Coloring Keywords

            // UV Border
            int _UVClampToggle;
            float4 _UVBorderColor;

            // GrabPass
            float3 _GrabPassColor;

            // Color Grading
            int _ColorGradingToggle, _ColorGradingEnum;
            float _ExposureIntensity;

            // Grayscale
            int _GrayscaleToggle;
            float _GrayscaleAlpha;

            // Blur
            int _BlurToggle, _BlurEnum, _BlurSamples;
            float _BlurAmount;
            float2 _BlurMask;

            // Edge Glow
            int _EdgeGlowToggle, _EdgeGlowRaysToggle, _RaySamples;
            float4 _EdgeGlowBackgroundColor, _EdgeGlowColor;
            float _EdgeGlowOffset, _EdgeGlowPower, _RayDistance;

            // Color to Mask
            int _ColorToMaskToggle;
            float _ColorToMaskForgiveness, _ColorToMaskAlpha, _ColorToMaskMin, _ColorToMaskMax;
            float4 _ColorOne, _ColorTwo;

            // Vignette
            int _VignetteToggle;
            float _VignetteSize, _VignetteAlpha;
            float3 _VignetteColor;

            // Scanlines
            int _ScanlineToggle;
            float _ScanlineCount, _ScanlineSpeed, _ScanlineAlpha;
            float3 _ScanlineColor;

            // Letterbox
            int _LetterboxToggle;
            float _LetterboxAlpha, _LetterboxLRDistance, _LetterboxTBDistance;
            float3 _LetterboxColor;

            // Motion Blur
            int _MotionBlurToggle;
            float _MotionBlurZoom, _MotionBlurAlpha;

            // Depth of Field
            int _DoFToggle;
            float _DoFSamples, _DoFFocalDistance, _DoFAlpha;

            // Ghost Zoom
            int _GhostZoomToggle;
            float _GhostZoomSpeed, _GhostZoomAmount, _GhostZoomTransparency, _GhostZoomMin, _GhostZoomMax;

            // SSAO
            int _SSAOToggle, _SSAOSamples;
            float _SSAOAlpha;

            // Overlay Textures
            float _TestSlider;
            int _TextureOverlay1Toggle, _TextureOverlay1Clamp, _TextureOverlay1Enum;
            sampler2D _Image1;
            float _Image1Alpha, _Image1Rotation;
            float2 _Image1Scale, _Image1Offset;

            int _TextureOverlay2Toggle, _TextureOverlay2Clamp, _TextureOverlay2Enum;
            sampler2D _Image2;
            float _Image2Alpha, _Image2Rotation;
            float2 _Image2Scale, _Image2Offset;

            int _TextureOverlay3Toggle, _TextureOverlay3Clamp, _TextureOverlay3Enum;
            sampler2D _Image3;
            float _Image3Alpha, _Image3Rotation;
            float2 _Image3Scale, _Image3Offset;

            int _TextureOverlay4Toggle, _TextureOverlay4Clamp, _TextureOverlay4Enum;
            sampler2D _Image4;
            float _Image4Alpha, _Image4Rotation;
            float2 _Image4Scale, _Image4Offset;

            int _TextureOverlay5Toggle, _TextureOverlay5Clamp, _TextureOverlay5Enum;
            sampler2D _Image5;
            float _Image5Alpha, _Image5Rotation;
            float2 _Image5Scale, _Image5Offset;

            // -----------------------------------

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float2 uv = i.uv.xy / i.uv.w;
                float2 center = i.center.xy / i.center.w;
                float2 iuv = i.iuv.xy / i.iuv.z;

                // ------------------------------
                // UV Effects

                // Pixelation
                UNITY_BRANCH if (_PixelationToggle)
                {
                    float plx = _PixelationIntensity / _PixelSize.x;
                    float ply = _PixelationIntensity / _PixelSize.y;
                    
                    uv.x = plx * floor(uv.x / plx);
                    uv.y = ply * floor(uv.y / ply);
                }

                // Distortion
                UNITY_BRANCH if (_DistortionToggle && _TotalDistortion)
                {
                    uv -= center;
                    float3 distortion = simplex3d(float3(_DistortionPower * iuv + (_Time.y * _DistortionSpeed * 0.1), 1));
                    uv += lerp(0, distortion.xy * (_DistortionTiling)*smoothstep(_DistortionMin, _DistortionMax, length(iuv)), _TotalDistortion);
                    uv += center;
                }

                // Rotation
                UNITY_BRANCH if (_RotationToggle)
                {
                    uv -= center;
                    uv.x *= asp;
                    uv = rotate(uv, radians(_RotationOffset + _RotationAmount * sin(_Time.y * _RotationSpeed)));
                    uv.x /= asp;
                    uv += center;
                }

                // Zoom
                UNITY_BRANCH if (_ZoomToggle)
                {
                    UNITY_BRANCH switch (_ZoomEnum)
                    {
                    case 0:
                        uv = lerp(uv, center, 2 - 2 / (_ZoomAmount + 1));
                        break;

                    case 1:
                        float scale = _ZoomAmount * UNITY_HALF_PI;
                        uv -= center;
                        UNITY_BRANCH if (_ZoomAmount > 0.0)
                            uv = normalize(uv) * tan(length(uv) * scale) / tan(scale);
                        else if (_ZoomAmount < 0.0)
                            uv = normalize(uv) * atan(length(uv) * tan(scale)) / scale;
                        uv += center;
                        break;

                    case 2:
                        // TODO: Fix single pass stereo thing for VR
                        uv -= center;
                        uv = sin(lerp(uv, smoothstep(0 - _ZoomAmount, 0.5 - _ZoomAmount, length(uv * float2(0, 1))), 2 - 2 / (_ZoomAmount + 1)));
                        uv += center;
                        break;

                    default:
                        break;
                    }
                }

                // Move
                UNITY_BRANCH if (_MoveToggle)
                {
                    uv += _MoveVector;
                }

				// Mirrored Screens
				UNITY_BRANCH if (_MirroredScreensToggle) 
                {
				    uv = lerp(uv,lerp(frac(uv), 1.0 - frac(uv), floor(uv) - 2.0 * floor(floor(uv) * 0.5)), _MirroredScreensAlpha);
                    UNITY_BRANCH if (_MirroredScreensScale < 0)
				        _MirroredScreensScale =  lerp(0 , -1 / (1 + _MirroredScreensScale), -_MirroredScreensScale);
				    uv = lerp(uv, center, 2.0 - 2.0 / (_MirroredScreensScale + 1.0));
				}
                
                // Screen Shake
                UNITY_BRANCH if (_ScreenShakeToggle)
                {
                    uv.x += sin(_ScreenShakeSpeedX * _Time.y) * _ScreenShakeRange;
                    uv.y += sin(_ScreenShakeSpeedY * _Time.y) * _ScreenShakeRange;
                }
                
                // Glitch UV Changes
                UNITY_BRANCH if (_GlitchToggle)
                {
                    float time = floor(_Time.y * _GlitchSpeed * 60.0);
                    float3 outCol = tex2D(_GrabPass, uv).rgb;
                    float maxOffset = _GlitchIntensity / 2.0;

                    UNITY_LOOP for (float i = 0.0; i < 10.0 * _GlitchIntensity; i += 1.0)
                    {
                        float sliceY = random2d(float2(time, 2345.0 + float(i)));
                        float sliceH = random2d(float2(time, 9035.0 + float(i))) * 0.25;
                        float hOffset = randomRange(float2(time, 9625.0 + float(i)), -maxOffset, maxOffset);
                        float2 uvOff = uv;
                        uvOff.x += hOffset;
                        if (insideRange(uv.y, sliceY, frac(sliceY + sliceH)))
                            uv = uvOff;
                    }
                }

                // ------------------------------

				fixed4 col = tex2D(_GrabPass, uv);
				col.rgb *= _GrabPassColor;

                // ------------------------------
                // Coloring Effects

				// Blurs
                UNITY_BRANCH if (_BlurToggle)
                {
					//Blur mask
					_BlurAmount *= smoothstep(_BlurMask.x, _BlurMask.y, length(iuv));

                    UNITY_BRANCH switch (_BlurEnum)
                    {
                        // Radial Blur
                        case 0:
                            float a = 1.0 / _BlurSamples;
                            UNITY_LOOP for (int i = 0; i < _BlurSamples; i++)
                                col.rgb += tex2D(_GrabPass, lerp(uv, 0.5, _BlurAmount / 100 * float(i) * a));
                            col /= _BlurSamples + 1.0;
                            break;

                        // Lens Blur
                        case 1:
                            float ls = 1.0 / _BlurSamples;

                            UNITY_LOOP for (int j = 0; j < _BlurSamples; j++)
                            {
                                float2 Luv = uv;
                                float s, c;
                                sincos(j * ls * UNITY_TWO_PI, s, c);
                                c *= asp;
                                col.rgb += tex2D(_GrabPass, Luv + 1.0 * float2(s, c) * (_BlurAmount / 100) * 0.1);
                            }

                            col.rgb /= (_BlurSamples + 1);
                            break;

                        // Rotation Blur
                        case 2:
                            float is = 1.0 / _BlurSamples;
                            UNITY_LOOP for (int j = -_BlurSamples + 1; j < _BlurSamples; j++)
                            {
                                float2 RotBlurUv = uv - center;
                                RotBlurUv.y /= asp;
                                RotBlurUv = rotate(RotBlurUv, radians(_BlurAmount / 100 * UNITY_HALF_PI * float(j) * is) * 5);
                                RotBlurUv.y *= asp;
                                RotBlurUv += center;

                                col += tex2D(_GrabPass, RotBlurUv);
                            }
                            col /= (_BlurSamples * 2.0 - 1.0) + 1;
                            break;

                        default: break;
                    }
                }

                // Glitch Pixel Changes
                UNITY_BRANCH if (_GlitchToggle)
                {
                    float time = floor(_Time.y * _GlitchSpeed * 60.0);
                    float maxColOffset = _GlitchIntensity / 6.0;
                    float rnd = random2d(float2(time, 9545.0));

                    float2 colOffset = float2(randomRange(float2(time, 9545.0), -maxColOffset, maxColOffset),
                        randomRange(float2(time, 7205.0), -maxColOffset, maxColOffset));

                    UNITY_BRANCH if (_GlitchModeEnum)
                    {
                        if (rnd < 0.33) col.r = tex2D(_GrabPass, uv + colOffset).r;
                        else if (rnd < 0.66) col.g = tex2D(_GrabPass, uv + colOffset).g;
                        else col.b = tex2D(_GrabPass, uv + colOffset).b;
                    }
                }

                // Depth of Field
                UNITY_BRANCH if (_DoFToggle)
                {
                    float2 foguv = uv;
                    float fogDepth = smoothstep(11, _DoFFocalDistance, LinearEyeDepth(tex2D(_CameraDepthTexture, foguv)));
                    float3 BlurColor = col.rgb;
                    float ls = 1.0 / _DoFSamples;

                    UNITY_LOOP for (int i = 0.0; i < _DoFSamples; i++)
                    {
                        float2 Luv = uv;
                        float s, c;
                        sincos(i * ls * UNITY_TWO_PI, s, c);
                        c *= asp;
                        BlurColor += tex2D(_GrabPass, Luv + 1.0 * float2(s, c) * (lerp(0, _DoFFocalDistance / 75, 1 * (saturate(exp(-_DoFAlpha * fogDepth * fogDepth))))) * 0.1);
                    }

                    BlurColor /= (_DoFSamples) + 1;
                    col.rgb = lerp(col.rgb, BlurColor, 1 * (saturate(exp(-_DoFAlpha * fogDepth * fogDepth))));
                }


                // Ghost Zoom (Written by Temmie)
                UNITY_BRANCH if (_GhostZoomToggle)
                { 
                    float2 ghostUV = uv;

                    UNITY_BRANCH if (_GhostZoomSpeed)
                    {
                        _GhostZoomAmount = min(_GhostZoomAmount, frac(_Time.y * _GhostZoomSpeed));
                        _GhostZoomTransparency = _GhostZoomTransparency - min(_GhostZoomTransparency, frac(_Time.y * _GhostZoomSpeed));
                    }

                    ghostUV = lerp(uv, center, 2.0 - 2.0 / (_GhostZoomAmount + 1.0));
                    float depthTexture = tex2D(_CameraDepthTexture, ghostUV);
                    float linearDepth = Linear01Depth(depthTexture);
                    col = lerp(col, tex2D(_GrabPass, ghostUV), smoothstep(_GhostZoomMin, _GhostZoomMax, linearDepth) * _GhostZoomTransparency);
                }

                // Girlscam
                UNITY_BRANCH if (_GirlscamToggle)
                {
                    float lineJitter = _GirlscamIntensity;
                    float treshhold = 1.0 - _GirlscamIntensity * 1.2;
                    float displacement = 0.002 + pow(lineJitter, 3.0) * 0.05;
                    float2 lineUV = float2(displacement, treshhold); // (displacement, threshold)    

                    float jitter = nrand(uv.y, sin(lineJitter * _Time.y / 5) / (_GirlscamScale / 2)) * 2 - 1;
                    jitter *= step(lineUV.y, abs(jitter)) * lineUV.x;

                    float2 src1uv = float2(fracFunc(uv.x + jitter), uv.y);
                    float4 src1 = tex2D(_GrabPass, src1uv);

                    float2 src2uv = float2(fracFunc(uv.x + jitter), uv.y);
                    float4 src2 = tex2D(_GrabPass, src2uv);

                    col = float4(src1.r, src2.g, src1.b, 1.0);
                }

                // Grain
                UNITY_BRANCH if (_GrainToggle && _GrainAlpha)
                {
                    col.rgb = lerp(col.rgb, _GrainColor, hash((i.iuv.xy / i.iuv.z) + sin(_Time.y * 0.1) * 0.1) * _GrainAlpha);
                }

                // Color Grading
                UNITY_BRANCH if (_ColorGradingToggle)
                {
                    // TODO: Add other color grading effects here!
                    UNITY_BRANCH switch(_ColorGradingEnum)
                    {
                        // None
                        case 0:
                            break;

                        // ACES
                        case 1:
                            break;
                        
                        default: break;
                    }

                    // Exposure
                    col.rgb *= _ExposureIntensity;
                }

                // Grayscale
                UNITY_BRANCH if (_GrayscaleToggle)
                {
                    // Use the coefficients for sRGB monitors
                    col = lerp(col, dot(col.rgb, float3(0.2126, 0.7152, 0.0722)), _GrayscaleAlpha);
                }

                // Edge Glow
                UNITY_BRANCH if (_EdgeGlowToggle)
                {
                    col.rgb *= _EdgeGlowBackgroundColor.rgb;

                    UNITY_BRANCH switch (_EdgeGlowRaysToggle)
                    {
                        case 1:
                            float a = 1.0 / _RaySamples;
                            UNITY_LOOP for (int i = 0; i < _RaySamples; i++)
                                col += EdgeGlow(_GrabPass, lerp(uv, 0.5, _RayDistance * float(i) * a), _EdgeGlowOffset * 0.001, _EdgeGlowPower) * _EdgeGlowColor;
                            break;

                        case 0:
                            col += EdgeGlow(_GrabPass, uv, _EdgeGlowOffset * 0.001, _EdgeGlowPower) * _EdgeGlowColor;
                            break;

                        default: break;
                    }
                }

                // Color to Mask
                UNITY_BRANCH if (_ColorToMaskToggle)
                {
                    float colorToMask = smoothstep(_ColorToMaskMin, _ColorToMaskMax, ColorToMask(col, _ColorToMaskForgiveness));
                    col.rgb = lerp(col.rgb, lerp(_ColorTwo.rgb, _ColorOne.rgb, colorToMask), _ColorToMaskAlpha);
                }

                // Vignette
                UNITY_BRANCH if (_VignetteToggle)
                {
                    col.rgb = lerp(col.rgb, lerp(_VignetteColor, col.rgb, smoothstep(1 - _VignetteSize, 0 - _VignetteSize, length(iuv * float2(0.6, 1)))), _VignetteAlpha);
                }

                // Scanlines
                UNITY_BRANCH if (_ScanlineToggle)
                {
                    float scanlineYDelta = sin(_Time.y * (_ScanlineSpeed / 100));
                    float scanline = sin((uv.y - scanlineYDelta) * _ScanlineCount);
                    col.rgb = lerp(col.rgb, _ScanlineColor, saturate(scanline) * _ScanlineAlpha);
                }

                // Letterbox
                UNITY_BRANCH if (_LetterboxToggle)
                {
                    float2 letterboxUV = i.uv.xy / i.uv.w;
                    _LetterboxTBDistance *= 0.5;
                    _LetterboxLRDistance *= 0.5;

                    float TopColor = smoothstep(_LetterboxTBDistance, _LetterboxTBDistance, -center.y + letterboxUV.y) * _LetterboxAlpha;
                    col.rgb = saturate(lerp(col.rgb, _LetterboxColor, TopColor * _LetterboxAlpha));

                    float BottomColor = smoothstep(_LetterboxTBDistance, _LetterboxTBDistance, center.y - letterboxUV.y) * _LetterboxAlpha;
                    col.rgb = saturate(lerp(col.rgb, _LetterboxColor, BottomColor * _LetterboxAlpha));

                    float LeftColor = smoothstep(_LetterboxLRDistance, _LetterboxLRDistance, center.x - letterboxUV.x) * _LetterboxAlpha;
                    col.rgb = saturate(lerp(col.rgb, _LetterboxColor, LeftColor * _LetterboxAlpha));

                    float RightColor = smoothstep(_LetterboxLRDistance, _LetterboxLRDistance, -center.x + letterboxUV.x) * _LetterboxAlpha;
                    col.rgb = saturate(lerp(col.rgb, _LetterboxColor, RightColor * _LetterboxAlpha));
                }

                // SSAO
                /*UNITY_BRANCH if (_SSAOToggle)
                {
                    float zBuffer = 1.0 - tex2D(_GrabPass, uv).x;
                    float ao = 0.0;

                    UNITY_LOOP for (int i = 0; i < _SSAOSamples; i++)
                    {
                        float2 offset = -1.0 + 2.0 * tex2D(_GrabPass, (uv.xy + 23.71 * float(i))).xz;    		
                        float zSample = 1.0 - tex2D(_GrabPass, (uv.xy + floor(offset * 16.0))).x;
                        ao += clamp((zBuffer - zSample) / 0.1, 0.0, 1.0);
                    }

                    ao = clamp(1.0 - ao / 8.0, 0.0, 1.0);
                    col.rgb = lerp(col.rgb, col.rgb * tex2D(_GrabPass, uv), _SSAOAlpha);
                }*/

                // ------------------------------


                // UV Border Color
                UNITY_BRANCH if (_UVClampToggle)
                {
                    float border = saturate(length(floorfix(uv)));
                    col.rgb = lerp(col.rgb, lerp(col.rgb, _UVBorderColor.rgb, border), _UVBorderColor.a);
                }

                // Motion Blur
                UNITY_BRANCH if (_MotionBlurToggle)
                {
                    float2 motionBlurUV = i.uv.xy / i.uv.w;
                    motionBlurUV = lerp(motionBlurUV, center, 2 - 2 / (_MotionBlurZoom + 1));

                    float4 motionBlur = tex2D(_GrabPass2, motionBlurUV);
                    col = lerp(col, motionBlur, _MotionBlurAlpha);
                }

                // Texture Overlays
                // TODO: See if there is a way to make an array of images rather than hard coding each image prop.
                UNITY_BRANCH if (_TextureOverlay1Toggle)
                {
                    float4 imageCol = CreateOverlayTexture(_Image1, iuv, _Image1Scale, _Image1Offset, _Image1Rotation, center, _TextureOverlay1Clamp);
                    col.rgb = lerp(col.rgb, imageCol.rgb, imageCol.a * _Image1Alpha);
                }

                UNITY_BRANCH if (_TextureOverlay2Toggle)
                {
                    float4 imageCol = CreateOverlayTexture(_Image2, iuv, _Image2Scale, _Image2Offset, _Image2Rotation, center, _TextureOverlay2Clamp);
                    col.rgb = lerp(col.rgb, imageCol.rgb, imageCol.a * _Image2Alpha);
                }

                UNITY_BRANCH if (_TextureOverlay3Toggle)
                {
                    float4 imageCol = CreateOverlayTexture(_Image3, iuv, _Image3Scale, _Image3Offset, _Image3Rotation, center, _TextureOverlay3Clamp);
                    col.rgb = lerp(col.rgb, imageCol.rgb, imageCol.a * _Image3Alpha);
                }

                UNITY_BRANCH if (_TextureOverlay4Toggle)
                {
                    float4 imageCol = CreateOverlayTexture(_Image4, iuv, _Image4Scale, _Image4Offset, _Image4Rotation, center, _TextureOverlay4Clamp);
                    col.rgb = lerp(col.rgb, imageCol.rgb, imageCol.a * _Image4Alpha);
                }

                UNITY_BRANCH if (_TextureOverlay5Toggle)
                {
                    float4 imageCol = CreateOverlayTexture(_Image5, iuv, _Image5Scale, _Image5Offset, _Image5Rotation, center, _TextureOverlay5Clamp);
                    col.rgb = lerp(col.rgb, imageCol.rgb, imageCol.a * _Image5Alpha);
                }

                return lerp(tex2D(_GrabPass, i.uv.xy / i.uv.w), col, i.fade);
            }
            ENDCG
        }

        GrabPass{ "_GrabPass2" }
        GrabPass{ "_Buffer" }
    }
}
