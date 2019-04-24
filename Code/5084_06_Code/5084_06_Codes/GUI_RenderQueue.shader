Shader "CookbookShaders/Chapter06/GUI_RenderQueue" 
{
	//We create our properties here so we can see them in the Unity Inspector
	Properties 
	{
		_GUITint ("GUI Tint", Color) = (1,1,1,1)
		_GUITex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_FadeValue ("Fade Value", Range(0,1)) = 1
	}
	
	SubShader 
	{
		//We declare our SubShader tags here so we tell Unity what type of shader
		//this is going to be.
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		ZWrite Off
		Cull Back
		LOD 200
		
		//Then start the CG shader and lighting model
		CGPROGRAM
		#pragma surface surf UnlitGUI alpha novertexlights 
		
		//Create a link between our properties
		//and our CGPROGRAM
		sampler2D _GUITex;
		float4 _GUITint;
		float _FadeValue;
		
		//OUr Custom lighting model.  This is an Unlit Model
		inline fixed4 LightingUnlitGUI (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
		{
			fixed4 c;
			c.rgb = s.Albedo;
			c.a =  s.Alpha;
			return c;
		}

		//Process our uv's
		struct Input 
		{
			float2 uv_GUITex;
		};

		//Process the per pixel information
		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 texColor = tex2D (_GUITex, IN.uv_GUITex);
			
			o.Albedo = texColor.rgb * _GUITint.rgb;
			o.Alpha = texColor.a * _FadeValue;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
