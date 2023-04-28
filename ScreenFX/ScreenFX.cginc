/*
* ScreenFX Shader v0.4 (CGINC)
* Shader Written by David Ryan
* Last Updated 11/29/2022
*/

sampler2D _GrabPass2;
float4 _GrabPass2_ST;

#define PI 3.14159265359
#define E 2.71828182846

inline float vroff() {
#if UNITY_SINGLE_PASS_STEREO
    return 0.5;
#else
    return 1;
#endif
}
#define vro vroff()

// Written by Temmie
#define floorfix(uv) uv = floor(half2(uv.x/vro-unity_StereoEyeIndex,uv.y))

// Written by Doppelganger
// Edited by Temmie
inline float SP() {
#if UNITY_SINGLE_PASS_STEREO
    return _ScreenParams.x * 2 / _ScreenParams.y;
#else
    return _ScreenParams.x / _ScreenParams.y;
#endif
}
#define asp SP()

// ----------------------------------------
// Utility Functions

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0 * j);
    j *= .125;
    r.x = frac(512.0 * j);
    j *= .125;
    r.y = frac(512.0 * j);
    return r - 0.5;
}

float2 rotate(float2 uv, float offset)
{
    float2x2 rot = float2x2(cos(offset), -sin(offset), sin(offset), cos(offset));
    return mul(rot, uv);
}

float3 deform(sampler2D grabPass, in float2 p)
{
    float2 uv;
    uv = sin(1) + p;
    return tex2D(grabPass, uv).xyz;
}

// Girlscam
float fracFunc(float x)
{
    return x - floor(x);
}

float nrand(float x, float y)
{
    return fracFunc(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.547);
}

float lerpFunc(float a, float b, float w)
{
    return a + w * (b - a);
}

// Glitch
float random2d(float2 n) 
{
    return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
}

float randomRange(in float2 seed, in float min, in float max) 
{
    return min + random2d(seed) * (max - min);
}

float insideRange(float v, float bottom, float top) 
{
    return step(bottom, v) - step(top, v);
}

// Texture Overlay
// Written by Doppelganger
inline float2x2 rot(float p)
{
    float s = 0.0, c = 0.0;
    sincos(p, s, c);
    return float2x2(c, -s, s, c);
}


// ----------------------------------------



// ----------------------------------------
// Noise Functions

/* skew constants for 3d simplex functions */
const float F3 = 0.3333333;
const float G3 = 0.1666667;

/* 3d simplex noise */
float simplex3d(float3 p) {
    /* 1. find current tetrahedron T and it's four vertices */
    /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
    /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

    /* calculate s and x */
    float3 s = floor(p + dot(p, float3(F3, F3, F3)));
    float3 x = p - s + dot(s, float3(G3, G3, G3));

    /* calculate i1 and i2 */
    float3 e = step(float3(0.0, 0, 0), x - x.yzx);
    float3 i1 = e * (1.0 - e.zxy);
    float3 i2 = 1.0 - e.zxy * (1.0 - e);

    /* x1, x2, x3 */
    float3 x1 = x - i1 + G3;
    float3 x2 = x - i2 + 2.0 * G3;
    float3 x3 = x - 1.0 + 3.0 * G3;

    /* 2. find four surflets and store them in d */
    float4 w, d;

    /* calculate surflet weights */
    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);

    /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
    w = max(0.6 - w, 0.0);
    /* calculate surflet components */
    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);

    /* multiply d by w^4 */
    w *= w;
    w *= w;
    d *= w;

    /* 3. return the sum of the four surflets */
    return dot(d, float4(52.0, 52.0, 52.0, 52.0));
}

// Hash21 Function written by iq
// https://www.shadertoy.com/user/iq
float hash(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 47758.5453);
}

// ----------------------------------------



// ----------------------------------------
// Edge Glow

inline float EdgeGlow(sampler2D t, float2 uv, float2 d, float p)
{
    float2 a = 0, b = 0;

    a += tex2D(t, uv + d * float2(0, 1)).xy;
    a += tex2D(t, uv + d * float2(-1, 0)).xy;
    a += tex2D(t, uv + d * float2(-1, 1)).xy;
    a += tex2D(t, uv + d * float2(-1, -1)).xy;
    a -= tex2D(t, uv + d * float2(1, 0)).xy;
    a -= tex2D(t, uv + d * float2(0, -1)).xy;
    a -= tex2D(t, uv + d * float2(1, -1)).xy;
    a -= tex2D(t, uv + d * float2(1, 1)).xy;

    b += tex2D(t, uv + d * float2(1, 1)).yz;
    b += tex2D(t, uv + d * float2(0, 1)).yz;
    b += tex2D(t, uv + d * float2(1, 0)).yz;
    b += tex2D(t, uv + d * float2(-1, 1)).yz;
    b -= tex2D(t, uv + d * float2(-1, -1)).yz;
    b -= tex2D(t, uv + d * float2(0, -1)).yz;
    b -= tex2D(t, uv + d * float2(-1, 0)).yz;
    b -= tex2D(t, uv + d * float2(1, -1)).yz;

    return (a * a + b * b) * p;
}

// ----------------------------------------



// ----------------------------------------
// Blur Functions

float GaussianBlur(int samples, float blurSize)
{
    float sum = samples;
    float stDevSquared = pow(0.2, 2);

    for (int i = 0; i < samples; i++)
    {
        float offset = (i / (samples - 1) - 0.5) * blurSize;
        float gauss = (1 / sqrt(2 * PI * stDevSquared)) * pow(E, -((offset * offset) / (2 * stDevSquared)));
        sum += gauss;
    }

    return sum;
}

float4 RadialBlur(sampler2D grabPass, float2 uv, float blurAmount, int samples)
{
    float2 position = uv - 0.5;
    float2 current_step = position;
    float2 direction = float2(position.x, position.y) / blurAmount;
    float3 total = 0;

    for (int i = 0; i < samples; i++)
    {
        float3 result = deform(grabPass, current_step);
        result = smoothstep(0, 1, result);
        total += result;
        current_step += direction;
    }

    total /= blurAmount;
    return float4(total, 1);
}

float4 CreateOverlayTexture(sampler2D image, float2 iuv, float2 scale, float2 offset, float dRotation, float2 center, int clamp)
{
    // TODO: Implement non-overrendering texture enum
    // float2 m_uv = lerp(uv, iuv, overrendering);
    float2 m_uv = iuv;
    m_uv -= offset;
    m_uv *= -scale;
    m_uv += 0.5;

    m_uv -= center;
    m_uv *= asp;
    m_uv = rotate(m_uv, radians(dRotation));
    m_uv /= asp;
    m_uv += center;

    float4 tex = tex2D(image, m_uv);
    tex.a *= lerp(1.0, step(1 - m_uv.y, 1.0) * step(m_uv.y, 1.0) * step(1 - m_uv.x, 1.0) * step(m_uv.x, 1.0), clamp);
    return tex;
}

// ----------------------------------------

// ----------------------------------------
// Misc Functions

float ColorToMask(float4 col, float forgiveness)
{
    float average = col.r + col.g + col.b;
    float4 maskColor = col;

    UNITY_BRANCH if (average <= forgiveness) maskColor = float4(0, 0, 0, 1);
    else maskColor = float4(1, 1, 1, 1);

    return maskColor;
}

// ----------------------------------------