Shader "Hidden/NightVisionEffectShader" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_VignetteTex ("Vignette Texture", 2D) = "white"{}
		_ScanLineTex ("Scan Line Texture", 2D) = "white"{}
		_NoiseTex ("Noise Texture", 2D) = "white"{}
		_NoiseXSpeed ("Noise X Speed", Float) = 100.0
		_NoiseYSpeed ("Noise Y Speed", Float) = 100.0
		_ScanLineTileAmount ("Scan Line Tile Amount", Float) = 4.0
		_NightVisionColor ("Night Vision Color", Color) = (1,1,1,1)
		_Contrast ("Contrast", Range(0,4)) = 2
		_Brightness ("Brightness", Range(0,2)) = 1
		_RandomValue ("Random Value", Float) = 0
		_distortion ("Distortion", Float) = 0.2
		_scale ("Scale (Zoom)", Float) = 0.8
	}
	
	SubShader 
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform sampler2D _VignetteTex;
			uniform sampler2D _ScanLineTex;
			uniform sampler2D _NoiseTex;
			fixed4 _NightVisionColor;
			fixed _Contrast;
			fixed _ScanLineTileAmount;
			fixed _Brightness;
			fixed _RandomValue;
			fixed _NoiseXSpeed;
			fixed _NoiseYSpeed;
			fixed _distortion;
			fixed _scale;
			
			float2 barrelDistortion(float2 coord) 
			{
				// lens distortion algorithm
				// See http://www.ssontech.com/content/lensalg.htm

				float2 h = coord.xy - float2(0.5, 0.5);
				float r2 = h.x * h.x + h.y * h.y;
				float f = 1.0 + r2 * (_distortion * sqrt(r2));

				return f * _scale * h + 0.5;
			}
			
			fixed4 frag(v2f_img i) : COLOR
			{
				//Get the colors from the RenderTexture and the uv's
				//from the v2f_img struct
				half2 distortedUV = barrelDistortion(i.uv);
				fixed4 renderTex = tex2D(_MainTex, distortedUV);
				fixed4 vignetteTex = tex2D(_VignetteTex, i.uv);
				
				//Process scan lines and noise
				half2 scanLinesUV = half2(i.uv.x * _ScanLineTileAmount, i.uv.y * _ScanLineTileAmount);
				fixed4 scanLineTex = tex2D(_ScanLineTex, scanLinesUV);
				
				half2 noiseUV = half2(i.uv.x + (_RandomValue * _SinTime.z * _NoiseXSpeed),
										 i.uv.y + (_Time.x * _NoiseYSpeed));
				fixed4 noiseTex = tex2D(_NoiseTex, noiseUV);
				
				// get the luminosity values from the render texture using the YIQ values.
				fixed lum = dot (fixed3(0.299, 0.587, 0.114), renderTex.rgb);
				lum += _Brightness;
				fixed4 finalColor = (lum *2) + _NightVisionColor;

				//Final output
				finalColor = pow(finalColor, _Contrast);
				finalColor *= vignetteTex;
				finalColor *= scanLineTex * noiseTex;
				
				return finalColor;
			}
	
			ENDCG
		}
	} 
	FallBack off
}
