Shader "CookbookShaders/Chapter02/AnimatedSprite" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		
		//Create the properties below
		_TexWidth ("Sheet Width", float) = 0.0
		_CellAmount ("Cell Amount", float) = 0.0
		_Speed ("Speed", Range(0.01, 32)) = 12
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		
		//Create the connection to the properties inside of the 
		//CG program
		float _TexWidth;
		float _CellAmount;
		float _Speed;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			
			//Lets store our UVs in a seperate variable
			float2 spriteUV = IN.uv_MainTex;

			//Lets calculate the width of a singe cell in our
			//sprite sheet and get a uv percentage that each cel takes up.
			float cellPixelWidth = _TexWidth/_CellAmount;
			float cellUVPercentage = cellPixelWidth/_TexWidth;
			
			//Lets get a stair step value out of time so we can increment
			//the uv offset
			float timeVal = fmod(_Time.y * _Speed, _CellAmount);
			timeVal = ceil(timeVal);
			
			//Animate the uv's forward by the width precentage of 
			//each cell
			float xValue = spriteUV.x;
			xValue += cellUVPercentage * timeVal * _CellAmount;
			xValue *= cellUVPercentage;
			
			spriteUV = float2(xValue, spriteUV.y);
		
			half4 c = tex2D (_MainTex, spriteUV);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
