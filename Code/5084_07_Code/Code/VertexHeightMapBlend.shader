Shader "Cookbook/Chapter07/VertexHeightMapBlend" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_SecondaryTex ("Secondary Texture", 2D) = "white"{}
		_HeightMap ("HeightMap", 2D) = "white" {}
		_Value ("Value", Range(1, 20)) = 3
		_Switch ("Swtich", Float) = 0
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		sampler2D _MainTex;
		sampler2D _SecondaryTex;
		sampler2D _HeightMap;
		float _Value;
		float _Switch;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_SecondaryTex;
			float3 vertColor;
		};
		
		void vert (inout appdata_full v, out Input o)
		{
			o.vertColor = v.color.rgb;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//Sample our textures
			half4 base = tex2D (_MainTex, IN.uv_MainTex);
			half4 secondTex = tex2D (_SecondaryTex, IN.uv_SecondaryTex);
			float4 height = tex2D(_HeightMap, IN.uv_MainTex);
			
			//perform blending
			float redChannel = 1-IN.vertColor.r;
			float rHeight = height.r * redChannel;
			float invertHeight = 1-height.r;
			float finalHeight = (invertHeight * redChannel)*4;
			float finalBlend = saturate(rHeight + finalHeight + pow(IN.vertColor.b, _Value));
			
			//Lets create more detail in how the vertex colors
			//blend.  Either very hard edge or very soft.
			float hardness = ((1-IN.vertColor.g) * _Value)+1;
			finalBlend = pow(finalBlend, hardness);
			
			//Produce the final color
			float3 finalColor = lerp(base, secondTex, finalBlend);
			
			if(_Switch == 0)
			{
				o.Albedo = finalColor;
			}
			else
			{
				o.Albedo = IN.vertColor;
			}
			o.Alpha = base.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
