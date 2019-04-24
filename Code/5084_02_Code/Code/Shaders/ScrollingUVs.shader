Shader "CookbookShaders/Chapter02/ScrollingUVs" 
{
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ScrollXSpeed ("X Scroll Speed", Range(0, 10)) = 2
		_ScrollYSpeed ("Y Scroll Speed", Range(0, 10)) = 2
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		fixed4 _MainTint;
		fixed _ScrollXSpeed;
		fixed _ScrollYSpeed;
		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//Create a seperate variable to store our uvs 
			//before we pass them to the tex2D() function
			fixed2 scrolledUV = IN.uv_MainTex;
			
			//Create variables that store the individual x and y 
			//components for the uv's scaled by time
			fixed xScrollValue = _ScrollXSpeed * _Time;
			fixed yScrollValue = _ScrollYSpeed * _Time;
			
			//Apply the final uv offset
			scrolledUV += fixed2(xScrollValue, yScrollValue);
			
			//Apply textures and tint
			half4 c = tex2D (_MainTex, scrolledUV);
			o.Albedo = c.rgb * _MainTint;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
