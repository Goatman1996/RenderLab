Shader "Custom/Blinn_Phong" {
    Properties
    {
        _Color ("Color",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8,50)) = 8.0  
    } 
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            // "UniversalMaterialType" = "Lit" 
            // "IgnoreProjector" = "True" 
            // "ShaderModel"="4.5"
        }
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
                // 这里有点反过来了
                // "LightMode" = "SRPDefaultUnlit"
            }

            HLSLPROGRAM
            // 1、添加变体
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct VertexData
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
                half _Gloss;
            CBUFFER_END

            v2f vert(VertexData v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                Light light = GetMainLight();
                half3 lightDir = light.direction;
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);

                // diffuse
                half3 diffuseColor = _Color.rgb * saturate(dot(i.normalWS,lightDir));
                
                // specular 高光
                half3 halfDir = normalize(lightDir + viewDir);
                half specular = pow(saturate(dot(i.normalWS,halfDir)),_Gloss);
                half3 specularColor = light.color * specular;

                // ambient
                half3 ambient = _Color.rgb * 0.1f;
                
                return half4(diffuseColor + specularColor + ambient,1);
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}