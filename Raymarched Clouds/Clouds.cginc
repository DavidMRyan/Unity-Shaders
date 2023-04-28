/*
* Raymarched Cloud Shader v1.0 (CGINC)
* Shader Written by David Ryan
* Last Updated 01/16/2023
*/

/////////////////////////////////////////////
// Miscellaneous

static float3x3 m = transpose(float3x3(0.0, 1.6, 1.2, -1.6, 0.72, -0.96, -1.2, -0.96, 1.28));

/////////////////////////////////////////////


/////////////////////////////////////////////
// Math Functions

float hash(float n)
{
    return frac(cos(n) * 114514.195);
}

float noise(in float3 x)
{
    float3 p = floor(x);
    float3 f = smoothstep(0.0, 1.0, frac(x));
    float n = p.x + p.y * 10.0 + p.z * 100.0;
    return lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x), lerp(hash(n + 10.0), hash(n + 11.0 ), f.x), f.y), lerp(lerp(hash(n + 100.0), hash(n + 101.0), f.x), lerp(hash(n + 110.0), hash(n + 111.0), f.x), f.y), f.z);
}

float fbm(float3 p)
{
    float f = 0.5 * noise(p);
    p = mul(m, p);
    f += 0.25 * noise(p);
    p = mul(m, p);
    f += 0.1666 * noise(p);
    p = mul(m, p);
    f += 0.0834 * noise(p);

    return f;
}

/////////////////////////////////////////////


/////////////////////////////////////////////
// Camera

float3 camera(float speed, float time)
{
    return float3(0, 0, speed * time);
}

/////////////////////////////////////////////