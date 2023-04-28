/*
* Topology Isolines Shader v1.0 (SHADER)
* Shader Written by David Ryan
* Last Updated 02/09/2023
*/

Shader "David Ryan/Topology"
{
    Properties 
  { 
        [HideInInspector] shader_is_using_thry_editor("", Float)=0
        [HideInInspector] shader_master_label("<b><color=#ffffff> David Ryan's <color=#42d469>Topology Isolines</color> Shader <color=#41d2e8>v1.0</color></color></b>", Float) = 0

        [HideInInspector] m_start_GeneralSettings("General Settings", float) = 0

        [HideInInspector] _Zoom("Zoom", float) = 0.3
        _BackgroundColor("Background Color (RGBA)", color) = (0.07, 0.07, 0.129, 1)

        [HideInInspector] m_end_GeneralSettings("", float) = 0


        [HideInInspector] m_start_IsolinelSettings("Isoline Settings", float) = 0

        _IsolineColor("Color", color) = (1, 1, 1, 1)
        _IsolineBrightness("Brightness", range(1, 10)) = 7
        _IsolineWidth("Width", range(10, 1)) = 1
        _IsolineClarity("Blur", range(0.6, 10)) = 0.6
        _IsolineSpeed("Speed", range(1, 50)) = 1

        [HideInInspector] m_end_IsolinelSettings("", float) = 0


        [HideInInspector] m_start_RenderSettings("Render Settings", float) = 0

        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", int) = 2
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", int) = 0

        [HideInInspector] m_end_RenderSettings("", float) = 0
    }
    CustomEditor "Thry.ShaderEditor" 
    SubShader 
  {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Cull]
        ZWrite [_ZWrite]
        ZTest [_ZTest]
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // ----------------------------------------------------------
            // Keywords

            float _Zoom, _IsolineBrightness, _IsolineWidth, _IsolineClarity, _IsolineSpeed;
            float4 _BackgroundColor, _IsolineColor, _IsolineAntiAliasing;

            // ----------------------------------------------------------

            #include "UnityCG.cginc"
            #include "Topology.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = 0;
                _Zoom = 0.3;
                float t = _Time.y * _Zoom * _IsolineSpeed;

                float3 p = float3(i.uv.xy, 0.02 * t);
                float f = perlinNoise(p);
                float2 dF = float2(ddx(f), ddy(f));
                const float lineWidth = _IsolineClarity;
                float s = 0.7213475 / (dot(dF, dF) * lineWidth * lineWidth) * _IsolineWidth;
                float c = 0.0;

                c += 0.2 * bell(f - 0.1, s);
                c += 0.4 * bell(f - 0.2, s);
                c += 0.5 * bell(f - 0.3, s);
                c += 0.6 * bell(f - 0.4, s);
                c += 0.8 * bell(f - 0.5, s);
                c += 0.6 * bell(f - 0.6, s);
                c += 0.5 * bell(f - 0.7, s);
                c += 0.4 * bell(f - 0.8, s);
                c += 0.2 * bell(f - 0.9, s);

                float I = (perlinNoise(p) + 0.2) * 0.7;
                c *= I * I * (I * I);
                col = lerp(_BackgroundColor, _IsolineColor, c * _IsolineBrightness);
                col.rgb = saturate(pow(col.rgb, 2.2));

                return col;
            }
            ENDCG
        }
    }
}
