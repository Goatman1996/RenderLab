Shader "Custom/Blinn_Phong" {
    Properties
    {
        _Color ("Color",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8,100)) = 8.0  
    } 
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct VertexData
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct FragmentData
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
                half _Gloss;
            CBUFFER_END

            FragmentData vert(VertexData v)
            {
                FragmentData o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                return o;
            }

            half4 frag(FragmentData i) : SV_Target
            {
                Light light = GetMainLight();
                half3 lightDir = light.direction;
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);

                // diffuse
                half3 diffuseColor = light.color * _Color.rgb * saturate(dot(i.normalWS,lightDir));
                
                // specular 高光
                half3 halfDir = normalize(lightDir + viewDir);
                half specular = pow(saturate(dot(i.normalWS,halfDir)),_Gloss);
                half3 specularColor = light.color * specular;

                // ambient
                half3 ambient = SampleSH(i.normalWS) * _Color.rgb;
                
                return half4(diffuseColor + specularColor + ambient,1);
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}