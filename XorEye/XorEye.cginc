/*
 * Xor Eye Shader (CGINC)
 * Shader Written by David Ryan
 * Last Updated 02/27/2023
 */


// ======================================================================================
// Math Functions

float3 hash23(float2 p) 
{
	p = frac(p * float2(5.3983, 5.4427));
    p += dot(p.yx, p.xy +  float2(21.5351, 14.3137));
	return frac(float3(p.x * p.y * 95.4337, p.x * p.y * 97.597, p.x * p.y * 203.597));
}

uint LogicalXor(int a, int b)
{
    return a ^ b;
}

// ======================================================================================
// Misc Functions

float3 DrawTorus(float inner_diam, float outer_diam, float blur, float2 uv)
{
	float3 val = float3(smoothstep(outer_diam, outer_diam - blur, length(uv)), smoothstep(outer_diam, outer_diam - blur, length(uv)), smoothstep(outer_diam, outer_diam - blur, length(uv)));
    float3 torus = val * smoothstep(inner_diam - blur, inner_diam, length(uv));
    float2 xoruv = abs(float2(floor(uv * 256.0)));
    torus *= float3(((LogicalXor(xoruv.x, xoruv.y)) % 256 / 256.0), ((LogicalXor(xoruv.x, xoruv.y)) % 256 / 256.0), ((LogicalXor(xoruv.x, xoruv.y)) % 256 / 256.0));

	return torus;
}

// ======================================================================================