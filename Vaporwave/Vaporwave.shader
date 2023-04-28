Shader "David Ryan/Vaporwave"
{
    Properties 
  { 
        [HideInInspector] shader_is_using_thry_editor("", Float)=0
        [HideInInspector] shader_master_label ("David Ryan's Vaporwave Shader", Float) = 0


        [HideInInspector] m_start_GridSettings("Grid Settings", float) = 0
        _GridColor("Grid Color", color) = (0.2, 0.05, 1)
        [Toggle(_)] _HueShift("Enable Hue Shift", int) = 0
        _RGBCycleSpeed("Hue Shift Speed", Range(0, 3)) = 0.5
        [IntRange] _Iterations("Draw Distance", Range(0, 70)) = 70
        _LineWidth("Line Width", Range(0, 2)) = 0.2
        [IntRange] _LineCountX("Line Count (X)", Range(0, 70)) = 35
        [IntRange] _LineCountY("Line Count (Y)", Range(0, 34)) = 17
        [IntRange] _Speed("Speed", Range(-12, 12)) = 3
        [HideInInspector] m_end_GridSettings("", float) = 0


        [HideInInspector] m_start_SunSettings("Sun Settings", float) = 0
        _SunSize("Size", Range(2.5, 0)) = 1
        [IntRange] _SunLines("Divison Lines", Range(75, 0)) = 35
        _TopColor("Top Color", color) = (1, 1.1, 0)
        _BaseColor("Base Color", color) = (4, 0, 0.2)
        _GlowColor("Glow Color", color) = (1.5, 0.3, 1.2)
        [HideInInspector] m_end_SunSettings("", float) = 0


        [HideInInspector] m_start_ScanlineSettings("Scanline Settings", float) = 0
        _FlickerIntensity("Intensity", Range(0, 1)) = 0.1
        _FlickerFreq("Flicker Frequency", Range(0, 2800)) = 1400
        _FlickerSpeed("Flicker Speed", Range(0, 60)) = 30
        [HideInInspector] m_end_ScanlineSettings("", float) = 0


        [HideInInspector] m_start_ScanlineSettings("Render Settings", float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", int) = 2
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", int) = 0
        [HideInInspector] m_end_ScanlineSettings("", float) = 0
    }
    CustomEditor "Thry.ShaderEditor" 
    SubShader 
  {
        Tags { "RenderType"="Opaque" "Queue"="32767" }
        Cull [_Cull]
        ZWrite [_ZWrite]
        ZTest [_ZTest]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float3 _GridColor;
            int _Iterations, _HueShift;
            float _LineWidth, _LineCountX, _LineCountY, _Speed, _RGBCycleSpeed;

            float3 _TopColor, _GlowColor, _BaseColor;
            float _SunSize, _SunLines;

            float _FlickerFreq, _FlickerSpeed, _FlickerIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            uniform sampler2D backbuffer;
            uniform float time;
            uniform float2 resolution;

            float smin(float a, float b, float k)
            {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            float noise(float2 seed)
            {
                return frac(sin(dot(seed, float2(12.9898, 4.1414))) * 43758.5453);
            }

            float getHeight(float2 uv)
            {
                float time = _Time.y;
                uv += 0.5;
                uv.y -= time * _Speed;

                float y1 = floor(uv.y);
                float y2 = floor(uv.y + 1);
                float x1 = floor(uv.x) ;
                float x2 = floor(uv.x + 1);
                float iX1 = lerp(noise(float2(x1, y1)), noise(float2(x2, y1)), frac(uv.x));
                float iX2 = lerp(noise(float2(x1, y2)), noise(float2(x2, y2)), frac(uv.x));
                return lerp(iX1, iX2, frac(uv.y));
            }

            float getDistance(float3 p)
            {
                return p.z - (1 - cos(p.x * 15)) * 0.03 * getHeight(float2(p.x * _LineCountX, p.y * _LineCountY));
            }

            float getGridColor(float2 uv)
            {
                float time = _Time.y;
                float zoom = 1, col;
                float3 cam = float3(0, 1, 0.1), fwd = normalize(-cam), u = normalize(cross(fwd, float3(1, 0, 0))),
                    r= cross(u, fwd), c = cam + fwd * zoom, i = c + r * uv.x + u * uv.y, ray = normalize(i - cam);

                float distSur, distOrigin = 0;

                float3 p = cam;
                UNITY_LOOP for(int i = 0; i < _Iterations; i++)
                {
                    distSur = getDistance(p);

                    if(distOrigin > 2) break;
                    if(distSur < 0.001) 
                    {
                        float lineW = _LineWidth * distOrigin;
                        float xLines = smoothstep(lineW, 0, abs(frac(p.x * _LineCountX) - 0.5));
                        float yLines = smoothstep(lineW * 2, 0, abs(frac(p.y * _LineCountY - time * _Speed) - 0.5));
                        col += max(xLines, yLines);
                        break;
                    }

                    p += ray * distSur;
                    distOrigin += distSur;
                }
                
                return max(0, col - (distOrigin * 0.8));
            }

            float3 hue2rgb(float hue)
            {
                hue = frac(hue); //only use fractional part of hue, making it loop
                float r = abs(hue * 6 - 3) - 1; //red
                float g = 2 - abs(hue * 6 - 2); //green
                float b = 2 - abs(hue * 6 - 4); //blue
                float3 rgb = float3(r, g, b); //combine components
                rgb = saturate(rgb); //clamp between 0 and 1
                return rgb;
            }

            float3 hsv2rgb(float3 hsv)
            {
                float3 rgb = hue2rgb(hsv.x); //apply hue
                rgb = lerp(1, rgb,  hsv.y); //apply saturation
                rgb *= hsv.z; //apply value
                return rgb;
            }

            float3 rgb2hsv(float3 rgb)
            {
                float maxComponent = max(rgb.r, max(rgb.g, rgb.b));
                float minComponent = min(rgb.r, min(rgb.g, rgb.b));
                float diff = maxComponent - minComponent;
                float hue = 0;

                UNITY_BRANCH if(maxComponent == rgb.r)
                    hue = 0+(rgb.g - rgb.b) / diff;
                else if(maxComponent == rgb.g)
                    hue = 2+(rgb.b - rgb.r) / diff;
                else if(maxComponent == rgb.b)
                    hue = 4 + (rgb.r - rgb.g) / diff;
                
                hue = frac(hue / 6);
                float saturation = diff / maxComponent;
                float value = maxComponent;

                return float3(hue, saturation, value);
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 fragColor = 0;
                float2 fragCoord = i.uv;
                float time = _Time.y;
                float3 resolution = 1;
                float val = 0;
                float sunHeight = sin(time * 0.1) * 0.1 + 0.1;
                float2 uv = i.uv.xy;
                uv.y -= sunHeight;

                float dist = _SunSize * length(uv - 0.5);
                float divisions = _SunLines;
                float pattern = (sin(uv.y * divisions * 10 - time * 2) * 1.2 + uv.y * 8.3) * uv.y - 1.5 + sin(uv.x * 20 + time * 5) * 0.01;
                float sunOutline = smoothstep(0, -0.0315, max(dist - 0.315, -pattern));
                float3 c = sunOutline * lerp(_BaseColor, _TopColor, uv.y);
                float glow = max(0, 1 - dist * 1.25);

                glow = min(pow(glow, 3), 0.325);
                c += glow * _GlowColor * 1.1;
                uv -= 0.5;
                uv.y += sunHeight + 0.18;

                UNITY_BRANCH if (uv.y < 0.1)
                {
                    float3 hsv = rgb2hsv(_GridColor);
                    hsv.x += i.uv.y + _Time.y * _RGBCycleSpeed;
                    _GridColor = lerp(_GridColor, hsv2rgb(hsv), _HueShift);
                    c += getGridColor(uv) * 4 * _GridColor;
                }
                   
                float p = 0.1;
                fragColor = (1.3 + sin(time * _FlickerSpeed + uv.y * _FlickerFreq) * _FlickerIntensity) * float4(c, 1);
                float scanline = smoothstep(1 - 0.2 / _FlickerFreq, 1, sin(time * _FlickerSpeed * 0.1 + uv.y * 4));
                fragColor *= scanline * 0.2 + 1;

                return fragColor;
            }
            ENDCG
        }
    }
}
