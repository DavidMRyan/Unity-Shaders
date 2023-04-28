/*
* Raymarched Cloud Shader v1.0 (SHADER)
* Shader Written by David Ryan
* Last Updated 01/16/2023
*/

Shader "David Ryan/Raymarched Clouds"
{
    Properties 
  { 
        [HideInInspector] shader_is_using_thry_editor("", Float)=0
        [HideInInspector] shader_master_label("<b><color=#ffffff> David Ryan's <color=#03a9fc>Raymarched Cloud</color> Shader <color=#f5e873>v1.0</color></color></b>", Float) = 0


        [HideInInspector] m_start_CloudSettings("Cloud Settings", float) = 0

        // _CloudHeightMin("Height (Min)", range(0.0, 7500.0)) = 4500.0
        // _CloudHeightMax("Height (Max)", range(0.0, 7500.0)) = 6000.0
        _CloudCoverage("Coverage", range(0.9, 0.0)) = 0.5
        _CloudRange("Distance", range(0.1, 1)) = 0.1
        _CloudSpeed("Speed", range(0, 12000)) = 750
        _CloudColor("Color", color) = (0.625, 0.625, 0.625, 0.0)
        _CloudColorIntensity("Exposure", range(1, 5)) = 1.35

        [Helpbox] _WarnBox("WARNING: Extreme settings may cause lag!", Float) = 0
        [HideInInspector] m_end_CloudSettings("", float) = 0


        [HideInInspector] m_start_RenderSettings("Render Settings", float) = 0

        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", int) = 1
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", int) = 0

        [HideInInspector] m_end_RenderSettings("", float) = 0
    }
    CustomEditor "Thry.ShaderEditor" 
    SubShader 
  {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent-500" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front
        ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Clouds.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 localPosition : TEXCOORD1;
                float4 viewDirection : TEXCOORD2;
            };

            // GLSL Compatability macros
            #define iResolution float3(_Resolution, _Resolution, _Resolution)
            float _Resolution;

            inline float3 _WSCameraPosition()
            {
                #if UNITY_SINGLE_PASS_STEREO
                    return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1])0.5;
                #else
                    return _WorldSpaceCameraPos;
                #endif
            }

            static float3 CameraPos = _WSCameraPosition();

            // Global access to uv data
            static v2f vertex_output;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localPosition = v.vertex;
                float4 objectSpaceCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                o.viewDirection = v.vertex - objectSpaceCameraPos;
                o.uv =  v.uv;
                return o;
            }

            ///////////////////////////////////////////////////////////
            // Global Variables

            float _CloudColorIntensity, _CloudRange, _CloudHeightMin, _CloudHeightMax, _CloudCoverage, _CloudSpeed;
            float3 _CloudColor;

            ///////////////////////////////////////////////////////////

            float4 frag (v2f i) : SV_Target
            {
                // Set Global Vertex Data to Current Output
                vertex_output = i;

                // UV Setup
                float4 fragColor = 0, col = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 uv = 2.0 * fragCoord / iResolution.xy - 1.0;
                uv.x *= iResolution.x / iResolution.y;

                // Time & Ray Setup
                float time = (_Time.y + 13.5 + 44.0);
                float3 raydir = normalize(i.viewDirection.xyz);
                float3 campos = camera(_CloudSpeed, time);
                float3 camtar = camera(_CloudSpeed, time + 0.4);
                float4 sum = float4(0, 0, 0, 0);

                // Tracing & Noise Loop
                UNITY_LOOP for (float depth = 0.0; depth < 100000.0 * _CloudRange; depth += 100.0)
                {
                    float3 ray = campos + raydir * depth;

                    // UNITY_BRANCH if (_CloudHeightMin < ray.y && ray.y < _CloudHeightMax)
                    // {
                        float alpha = smoothstep(_CloudCoverage, 1.0, fbm(ray * 0.00025));
                        float3 localcolor = lerp(float3(1.1, 1.05, 1.0), _CloudColor, alpha + 0.15);
                        alpha *= 1.0 - sum.a;
                        sum += float4(localcolor * alpha, alpha);
                    // }
                }

                col = lerp(col, float4(sum.rgb, 0.5), sum.a) * _CloudColorIntensity;
                fragColor = col;
                return fragColor;
            }
            ENDCG
        }
    }
}
