Shader "CookbookShaders/Chapter03/SpecularMask" 
{
	Properties 
	{
		//Set properties here so we can feed our shader information
		//from the inspector in the editor
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_SpecularColor ("Specular Tint", Color) = (1,1,1,1)
		_SpecularMask ("Specular Texture", 2D) = "white" {}
		_SpecPower ("Specular Power", Range(0.1, 120)) = 3  
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomPhong
		
		//get the data from our properties block
		sampler2D _MainTex;
		sampler2D _SpecularMask;
		float4 _MainTint;
		float4 _SpecularColor;
		float _SpecPower;
		
		//Create a custom Output Struct
		struct SurfaceCustomOutput 
		{
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed3 SpecularColor;
			half Specular;
			fixed Gloss;
			fixed Alpha;
		};
				
		inline fixed4 LightingCustomPhong (SurfaceCustomOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			//Calculate diffuse and the reflection vector
			float diff = dot(s.Normal, lightDir);
			float3 reflectionVector = normalize(2.0 * s.Normal * diff - lightDir);
			
			//Calculate the Phong specular
			float spec = pow(max(0.0f,dot(reflectionVector, viewDir)), _SpecPower) * s.Specular;
			float3 finalSpec = s.SpecularColor * spec * _SpecularColor.rgb;
			
			//Create final color
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff) + (_LightColor0.rgb * finalSpec);
			c.a = s.Alpha;
			return c;
		}

		struct Input 
		{
			//Get uv information from the Input Struct
			float2 uv_MainTex;
			float2 uv_SpecularMask;
		};

		void surf (Input IN, inout SurfaceCustomOutput o) 
		{
			//Get the color information from the textures
			float4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			float4 specMask = tex2D(_SpecularMask, IN.uv_SpecularMask) * _SpecularColor;
			
			//Set the parameters in the Output Struct
			o.Albedo = c.rgb;
			o.Specular = specMask.r;
			o.SpecularColor = specMask.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
