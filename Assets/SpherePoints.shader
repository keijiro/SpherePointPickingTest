Shader "/Hidden/SpherePoints"
{
    HLSLINCLUDE

    // Hash function from H. Schechter & R. Bridson, goo.gl/RXiKaH
    uint Hash(uint s)
    {
        s ^= 2747636419u;
        s *= 2654435769u;
        s ^= s >> 16;
        s *= 2654435769u;
        s ^= s >> 16;
        s *= 2654435769u;
        return s;
    }

    float Random(uint seed)
    {
        return float(Hash(seed)) / 4294967295.0; // 2^32-1
    }

    // Uniformaly distributed points on a unit sphere
    // http://mathworld.wolfram.com/SpherePointPicking.html
    float3 RandomOnSphere(uint seed)
    {
        float PI2 = 6.28318530718;
        float z = 1 - 2 * Random(seed);
        float xy = sqrt(1.0 - z * z);
        float sn, cs;
        sincos(PI2 * Random(seed + 32894305u), sn, cs);
        return float3(sn * xy, cs * xy, z);
    }

    // Uniformaly distributed points inside a unit sphere
    float3 RandomInsideSphere(uint seed)
    {
        return RandomOnSphere(seed) * sqrt(Random(seed + 83721014u));
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _ _INSIDE_SPHERE

            #include "UnityCG.cginc"

            float4 Vertex(uint vid : SV_VertexID) : SV_Position
            {
            #if _INSIDE_SPHERE
                float3 pos = RandomInsideSphere(vid);
            #else
                float3 pos = RandomOnSphere(vid);
            #endif
                return UnityObjectToClipPos(float4(pos, 1));
            }

            half4 Fragment() : SV_Target
            {
                return 1;
            }

            ENDHLSL
        }
    }
}
