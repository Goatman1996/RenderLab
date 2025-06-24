Shader "Custom/OutLine"
{
    Properties
    {
        _OutLineColor ("OutLineColor", Color) = (1,1,1,1)
        _OutLineWidth ("OutLineWidth", Float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexData
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct FragmentData
            {
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _OutLineColor;
                float _OutLineWidth;
            CBUFFER_END

            FragmentData vert(VertexData v)
            {
                FragmentData o;
                // v.positionOS.xyz += v.normalOS * _OutLineWidth;
                v.positionOS.xyz *= 1 + _OutLineWidth;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.positionCS.z -=0.1;
                return o;
            }

            float4 frag(FragmentData i) : SV_TARGET
            {
                return half4(_OutLineColor.rgb, 1.0);
            }
            ENDHLSL

        }
    }
}
