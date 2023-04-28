/*
* Topology Isolines Shader v1.0 (CGINC)
* Shader Written by David Ryan
* Last Updated 02/09/2023
*/

// --------------------------------------------------
// Math Functions

float randf(int counter)
{
    return frac(sin(float(counter)) * 43.758545);
}

float2 randf2(int counter)
{
    float phi = randf(counter) * 2.0 * UNITY_PI;
    return float2(cos(phi), sin(phi));
}

float3 randf3(int counter)
{
    float phi = randf(counter) * 2.0 * UNITY_PI;
    float cos_theta = 2.0 * randf(counter * 2) - 1.0;
    float sin_theta = sqrt(1.0 - cos_theta * cos_theta);
    
    return float3(cos(phi) * sin_theta, sin(phi) * sin_theta, cos_theta);
}

float g(float t)
{
    return t * t * (3.0 - 2.0 * t);
}

float perlinNoise(float3 P)
{
    float3 p = P / _Zoom;
    int3 i = floor(p);
    float3 r = frac(p);
    const int iL = 10;
    const int iS = iL * iL;
    int i00 = i.x + iL * i.y + iS * i.z;

    float f000 = dot(r - float3(0.0, 0.0, 0.0), randf3(i00));
    float f001 = dot(r - float3(1.0, 0.0, 0.0), randf3(i00 + 1));
    float f010 = dot(r - float3(0.0, 1.0, 0.0), randf3(i00 + iL));
    float f011 = dot(r - float3(1.0, 1.0, 0.0), randf3(i00 + iL + 1));
    float f100 = dot(r - float3(0.0, 0.0, 1.0), randf3(i00 + iS));
    float f101 = dot(r - float3(1.0, 0.0, 1.0), randf3(i00 + iS + 1));
    float f110 = dot(r - float3(0.0, 1.0, 1.0), randf3(i00 + iS + iL));
    float f111 = dot(r - float3(1.0, 1.0, 1.0), randf3(i00 + iS + iL + 1));

    float f00 = f000 + (f001 - f000) * g(r.x);
    float f01 = f010 + (f011 - f010) * g(r.x);
    float f10 = f100 + (f101 - f100) * g(r.x);
    float f11 = f110 + (f111 - f110) * g(r.x);
    float f0 = f00 + (f01 - f00) * g(r.y);
    float f1 = f10 + (f11 - f10) * g(r.y);

    return f0 + (f1 - f0) * g(r.z) + 0.5;
}

float bell(float x, float s)
{
    return exp2(-x * x * s);
}
// --------------------------------------------------