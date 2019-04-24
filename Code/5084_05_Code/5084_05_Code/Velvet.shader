Shader "CookbookShaders/Chapter05/Velvet" 
{
	Properties
	{
		_MainTint ("Global Tint", Color) = (1,1,1,1)
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_DetailBump ("Detail Normal Map", 2D) = "bump" {}
		_DetailTex ("Fabric Weave", 2D) = "white" {}
		_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
		_FresnelPower ("Fresnel Power", Range(0, 12)) = 3
		_RimPower ("Rim FallOff", Range(0, 12)) = 3
		_SpecIntesity ("Specular Intensiity", Range(0, 1)) = 0.2
		_SpecWidth ("Specular Width", Range(0, 1)) = 0.2
		
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Velvet
		#pragma target 3.0

		sampler2D _BumpMap;
		sampler2D _DetailBump;
		sampler2D _DetailTex;
		float4 _MainTint;
		float4 _FresnelColor;
		float _FresnelPower;
		float _RimPower;
		float _SpecIntesity;
		float _SpecWidth;

		struct Input 
		{
			float2 uv_BumpMap;
			float2 uv_DetailBump;
			float2 uv_DetailTex;
		};
		
		inline fixed4 LightingVelvet (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			//Create lighting vectors here
			viewDir = normalize(viewDir);
			lightDir = normalize(lightDir);
			half3 halfVec = normalize (lightDir + viewDir);
			fixed NdotL = max (0, dot (s.Normal, lightDir));
			
			//Create Specular 
			float NdotH = max (0, dot (s.Normal, halfVec));
			float spec = pow (NdotH, s.Specular*128.0) * s.Gloss;
			
			//Create Fresnel
			float HdotV = pow(1-max(0, dot(halfVec, viewDir)), _FresnelPower);
			float NdotE = pow(1-max(0, dot(s.Normal, viewDir)), _RimPower);
			float finalSpecMask = NdotE * HdotV;
			
			//Output the final color
			fixed4 c;
			c.rgb = (s.Albedo * NdotL * _LightColor0.rgb)
					 + (spec * (finalSpecMask * _FresnelColor)) * (atten * 2);
			c.a = 1.0;
			return c;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_DetailTex, IN.uv_DetailTex);
			fixed3 normals = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)).rgb;
			fixed3 detailNormals = UnpackNormal(tex2D(_DetailBump, IN.uv_DetailBump)).rgb;
			fixed3 finalNormals = float3(normals.x + detailNormals.x, 
										normals.y + detailNormals.y, 
										normals.z + detailNormals.z);
			
			o.Normal = normalize(finalNormals);
			o.Specular = _SpecWidth;
			o.Gloss = _SpecIntesity;
			o.Albedo = c.rgb * _MainTint;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
