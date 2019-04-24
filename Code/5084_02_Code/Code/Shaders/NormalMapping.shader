Shader "CookbookShaders/Chapter02/NormalMapping" 
{
	Properties 
	{
		//Add these Properties
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_NormalTex ("Normal Map", 2D) = "bump" {}
		_NormalIntensity ("Normal Map Intensity", Range(0,2)) = 1
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		//Link the property to the CG program
		sampler2D _NormalTex;
		float4 _MainTint;
		float _NormalIntensity;

		//Make sure you get the uvs for the texture in the Struct
		struct Input 
		{
			float2 uv_NormalTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//Get teh normal Data out of the normal map textures
			//using the UnpackNormal() function.
			float3 normalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			normalMap = float3(normalMap.x * _NormalIntensity, normalMap.y * _NormalIntensity, normalMap.z);
						
			//Apply the new normals to the lighting model
			o.Normal = normalMap.rgb;
			o.Albedo = _MainTint.rgb;
			o.Alpha = _MainTint.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
