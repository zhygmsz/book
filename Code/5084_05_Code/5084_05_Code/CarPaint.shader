Shader "CookbookShaders/Chapter05/CarPaint" 
{
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_SpecPower ("Specular Power", Range(0.01, 30)) = 3
		_ReflCube ("Reflection Cube", CUBE) = "" {}
		_BRDFTex ("BRDF Texture", 2D) = "white" {}
		_DiffusePower ("Diffuse Power", Range(0.01, 10)) = 0.5
		_FalloffPower ("Falloff Spread", Range(0.01, 10)) = 3
		_ReflAmount ("Reflection Amount", Range(0.01, 1.0)) = 0.5
		_ReflPower ("Reflection Power", Range(0.01, 3.0)) = 2.0
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CarPaint

		sampler2D _MainTex;
		sampler2D _BRDFTex;
		fixed4 _MainTint;
		fixed4 _SpecularColor;
		fixed _SpecPower;
		fixed _DiffusePower;
		fixed _FalloffPower;
		fixed _ReflAmount;
		fixed _ReflPower;
		samplerCUBE _ReflCube;
		
		
		
		inline fixed4 LightingCarPaint (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			half3 h = normalize (lightDir + viewDir);
			fixed diff = max (0, dot (s.Normal, lightDir));
			
			float ahdn = 1-dot(h, normalize(s.Normal));
			ahdn = pow(clamp(ahdn, 0.0, 1.0), _DiffusePower);
			half4 brdf = tex2D(_BRDFTex, float2(diff, 1-ahdn));
			
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular * _SpecPower) * s.Gloss;
			
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * brdf.rgb + _LightColor0.rgb * _SpecularColor.rgb * spec)* (atten * 2);
			c.a = s.Alpha + _LightColor0.a * _SpecularColor.a * spec * atten;
			return c;
		}

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldRefl;
			float3 viewDir;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			
			fixed falloff = saturate(1-dot(normalize(IN.viewDir), o.Normal));
			falloff = pow(falloff, _FalloffPower);
			
			o.Albedo = c.rgb * _MainTint;
			o.Emission = pow((texCUBE(_ReflCube, IN.worldRefl).rgb * falloff), _ReflPower) * _ReflAmount;
			o.Specular = c.r;
			o.Gloss = 1.0;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
