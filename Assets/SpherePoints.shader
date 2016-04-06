Shader "SpherePoints"
{
    CGINCLUDE

    #pragma multi_compile _ _STRICT

    #include "UnityCG.cginc"

    float _PointSize;

    // Utility for sin/cos
    float2 CosSin(float theta)
    {
        float sn, cs;
        sincos(theta, sn, cs);
        return float2(cs, sn);
    }

    // Uniformaly distributed points on a unit sphere
    // http://mathworld.wolfram.com/SpherePointPicking.html
    // https://en.wikibooks.org/wiki/Mathematica/Uniform_Spherical_Distribution
    float3 PointPosition(float3 coord)
    {
    #if _STRICT
        float theta = coord.y * UNITY_PI * 2;
        float phi = asin(sqrt(coord.x)) * 2;
        float2 A = CosSin(theta);
        float2 B = CosSin(phi);
        return float3(B.y * A.x, B.y * A.y, B.x);
    #else
        float u = coord.x * 2 - 1;
        float theta = coord.y * UNITY_PI * 2;
        return float3(CosSin(theta) * sqrt(1 - u * u), u);
    #endif
    }

    float3 PointOffset(float3 coord)
    {
        float z = coord.z;
        float aspect = _ScreenParams.x / _ScreenParams.y;
        float dx = fmod(z, 2);
        float dy = floor(z / 2) * aspect;
        return float3(dx, dy, 0) * _PointSize;
    }

    float4 vert(appdata_base v) : SV_POSITION
    {
        float3 coord = v.vertex.xyz;
        float4 pos = float4(PointPosition(coord), 1);
        pos = mul(UNITY_MATRIX_MVP, pos);
        pos.xyz += PointOffset(coord);
        return pos;
    }

    fixed4 frag() : SV_Target
    {
        return 1;
    }

    ENDCG
    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
