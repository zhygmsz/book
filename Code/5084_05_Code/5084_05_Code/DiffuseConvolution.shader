Shader "CookbookShaders/Chapter05/DiffuseConvolution" 
{
	Properties 
	{
		_MainTint ("Global Tint", Color) = (1,1,1,1)
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_AOMap ("Ambient Occlusion Map", 2D) = "white" {}
		_CubeMap ("Diffuse Convolution Cubemap", Cube) = ""{}
		_SpecIntensity ("Specular Intensity", Range(0, 1)) = 0.4
		_SpecWidth ("Specular Width", Range(0, 1)) = 0.2
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf DiffuseConvolution
		#pragma target 3.0

		samplerCUBE _CubeMap;
		sampler2D _BumpMap;
		sampler2D _AOMap;
		float4 _MainTint;
		float _SpecIntensity;
		float _SpecWidth;
		
		struct Input 
		{
			float2 uv_AOMap;
			float3 worldNormal;
			INTERNAL_DATA
		};
		
		inline fixed4 LightingDiffuseConvolution (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
        {
            //Get all vectors for lighting
            viewDir = normalize ( viewDir );
            lightDir = normalize ( lightDir );
            s.Normal = normalize ( s.Normal );
            float NdotL = dot ( s.Normal, lightDir );
            float3 halfVec = normalize ( lightDir + viewDir );
            
            //Calculate the Specular
        	float spec = pow (dot(s.Normal, halfVec), s.Specular*128.0) * s.Gloss;
        	
        	fixed4 c;
      		c.rgb = (s.Albedo * atten) + spec;
      		c.a = 1.0f;
        	return c;
        }
        	

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_AOMap, IN.uv_AOMap);
			float3 normals = UnpackNormal(tex2D(_BumpMap, IN.uv_AOMap)).rgb;
			o.Normal = normals;
			
			float3 diffuseVal = texCUBE(_CubeMap, WorldNormalVector(IN, o.Normal)).rgb;
			
			o.Albedo = (c.rgb * diffuseVal) * _MainTint;
			o.Specular = _SpecWidth;
			o.Gloss = _SpecIntensity * c.rgb;
			o.Alpha = c.a;
		}
		
		ENDCG
	} 
	FallBack "Diffuse"
}
