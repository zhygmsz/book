Shader "CookbookShaders/Chapter02/PhotoshopLevels" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		
		//Add the Input Levels Values
		_inBlack ("Input Black", Range(0, 255)) = 0
		_inGamma ("Input Gamma", Range(0, 2)) = 1.61
		_inWhite ("Input White", Range(0, 255)) = 255
		
		//Add the Output Levels
		_outWhite ("Output White", Range(0, 255)) = 255
		_outBlack ("Output Black", Range(0, 255)) = 0
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		
		//Add these variables
		//to the CGPROGRAM
		float _inBlack;
		float _inGamma;
		float _inWhite;
		float _outWhite;
		float _outBlack;

		struct Input 
		{
			float2 uv_MainTex;
		};
		
		float GetPixelLevel(float pixelColor)
		{
			float pixelResult;
			pixelResult = (pixelColor * 255.0);
			pixelResult = max(0, pixelResult - _inBlack);
			pixelResult = saturate(pow(pixelResult / (_inWhite - _inBlack), _inGamma));
			pixelResult = (pixelResult * (_outWhite - _outBlack) + _outBlack)/255.0;	
			return pixelResult;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			
			//do levels calculations here for each pixel channel.
			//So we need to process the R, G, and B channels with
			//The same math calculations
			
			//Create a variable to store 	
			//a pixel channel from our _MainTex texture
			float outRPixel  = GetPixelLevel(c.r);
			
			//remap 0 to 1 range to 0 to 255
			//outRPixel = (c.r * 255.0);
			
			//Subtract the black value given to us 
			//by the _inBlack property
			//outRPixel = max(0, outRPixel - _inBlack);
			
			//Increase white value of each pixel wit _inWhite
			//outRPixel = saturate(pow(outRPixel / (_inWhite - _inBlack), _inGamma));
			
			//Change final black point and white point and
			//re-map from 0 to 255 to 0 to 1
			//outRPixel = (outRPixel * (_outWhite - _outBlack) + _outBlack)/255.0;
			
			float outGPixel = GetPixelLevel(c.g);
			//outGPixel = (c.g * 255.0);
			//outGPixel = max(0, outGPixel - _inBlack);
			//outGPixel = saturate(pow(outGPixel / (_inWhite - _inBlack), _inGamma));
			//outGPixel = (outGPixel * (_outWhite - _outBlack) + _outBlack)/255.0;
			
			float outBPixel = GetPixelLevel(c.b);
			//outBPixel = (c.b * 255.0);
			//outBPixel = max(0, outBPixel - _inBlack);
			//outBPixel = saturate(pow(outBPixel / (_inWhite - _inBlack), _inGamma));
			//outBPixel = (outBPixel * (_outWhite - _outBlack) + _outBlack)/255.0;
			
			o.Albedo = float3(outRPixel,outGPixel,outBPixel);
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
