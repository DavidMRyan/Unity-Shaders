/*
 * Xor Eye Shader (SHADER)
 * Shader Written by David Ryan
 * Last Updated 02/27/2023
 */


Shader "David Ryan/XorEye"
{
    Properties 
  { 
        [HideInInspector] shader_is_using_thry_editor("", Float)=0
        [HideInInspector] shader_master_label("<b><color=#ffffff> ֍ David Ryan's <color=#2f61d6>Xor Eye</color> Shader ֍ </color></b>", Float) = 0


        [HideInInspector] m_start_GeneralSettings("Depth & Color Settings", float) = 0
        _Depth("Depth", range(0, 1)) = 0.5
        
        // Coloring
        [Toggle(_)] _HashColoring("Enable Hash23 Coloring", int) = 0
        _BackgroundColor("Background Color", color) = (0, 0, 0, 1)
        _ForegroundColor("ForegroundColor", color) = (1, 1, 1, 1)
        
        // Vigette
        _EyeVignetteMin("Eye Vignette (Min)", float) = 0.28
        _EyeVignetteMax("Eye Vignette (Min)", float) = 0.43
        [HideInInspector] m_end_GeneralSettings("", float) = 0


        [HideInInspector] m_start_RenderSettings("Render Settings", float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull ("Cull", int) = 2
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", int) = 0
        [HideInInspector] m_end_RenderSettings("", float) = 0
    }
    CustomEditor "Thry.ShaderEditor" 
    SubShader 
  {
        Tags { "RenderType"="Transparent" "Queue"="AlphaTest+1" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Cull]
        ZWrite [_ZWrite]
        ZTest [_ZTest]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "XorEye.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 worlddir : TEXCOORD4;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                o.worlddir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            // ==============================================
            // Keywords

            int _HashColoring;
            float _Depth, _EyeVignetteMin, _EyeVignetteMax;
            float3 _BackgroundColor, _ForegroundColor;

            // ==============================================

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2;
                float2 parallax = mul(float3x3(i.tangent, i.bitangent, i.normal), normalize(i.worlddir)).xy;

                uv -= 1;
                float t = cos(_Time.y * float2(0.5, 0.2)) * float2(0.3, 0.8);
                float tr = cos(_Time.y * float2(0.5, 0.2)) * float2(0.3, 0.8);

                float curvature = cos(uv.y) * cos(uv.x);
                float2 puv = i.uv - 0.5 - 0.5 * parallax * _Depth;
                float2 nuv = (puv * lerp(1.0 / curvature, curvature, cos(t * 5.0))) - 2;
                nuv = mul(nuv, float2x2(sin(t), -cos(t), cos(t), sin(t)));
                nuv *= mul(nuv, 5.0);
                nuv += t * 5.0;

                float2 boxes = frac(nuv * 1.0) * 2.0 - 1.0;
                float3 col = lerp(_BackgroundColor, _ForegroundColor, DrawTorus(0.45, 1.0, 0.2, boxes));

                UNITY_BRANCH if(_HashColoring)
                    col = lerp(_BackgroundColor, hash23(floor(nuv)), DrawTorus(0.45, 1.0, 0.2, boxes));

                // Pupil
                col = lerp(col, 0, smoothstep(0.15, 0.1, length(puv)));
                // Vignette
                col = lerp(col, 0, smoothstep(_EyeVignetteMin, _EyeVignetteMax, length(i.uv - 0.5)));

                return float4(col, smoothstep(0.45, 0.43, length(i.uv - 0.5)));
            }
            ENDCG
        }
    }
}
