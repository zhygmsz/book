Shader "Cookbook/Chapter08/OptimizedShader001" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlendTex ("Blend Texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf SimpleLambert exclude_path:prepass noforwardadd 

		sampler2D _MainTex;
		sampler2D _BlendTex;
		sampler2D _NormalMap;

		struct Input 
		{
			half2 uv_MainTex;
		};
		
		inline fixed4 LightingSimpleLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			fixed diff = max (0, dot (s.Normal, lightDir));
			
			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha;
			return c;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			fixed4 blendTex = tex2D (_BlendTex, IN.uv_MainTex);
			
			c = lerp(c, blendTex, blendTex.r);
	
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
