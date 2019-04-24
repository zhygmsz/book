using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class NightVisionEffect : MonoBehaviour 
{
	#region Variables
	public Shader nightVisionShader;
	
	public float contrast = 2.0f;
	public float brightness = 1.0f;
	public Color nightVisionColor = Color.white;
	
	public Texture2D vignetteTexture;
	
	public Texture2D scanLineTexture;
	public float scanLineTileAmount = 4.0f;
	
	public Texture2D nightVisionNoise;
	public float noiseXSpeed = 100.0f;
	public float noiseYSpeed = 100.0f;
	
	public float distortion = 0.2f;
	public float scale = 0.8f;
	
	private float randomValue = 0.0f;
	private Material curMaterial;
	#endregion
	
	#region Properties
	Material material
	{
		get
		{
			if(curMaterial == null)
			{
				curMaterial = new Material(nightVisionShader);
				curMaterial.hideFlags = HideFlags.HideAndDontSave;
			}
			return curMaterial;
		}
	}
	#endregion
	
	void Start()
	{
		if(!SystemInfo.supportsImageEffects)
		{
			enabled = false;
			return;
		}
		
		if(!nightVisionShader && !nightVisionShader.isSupported)
		{
			enabled = false;
		}
	}
	
	void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
	{
		if(nightVisionShader != null)
		{	
			material.SetFloat("_Contrast", contrast);
			material.SetFloat("_Brightness", brightness);
			material.SetColor("_NightVisionColor", nightVisionColor);
			material.SetFloat("_RandomValue", randomValue);
			material.SetFloat("_distortion", distortion);
			material.SetFloat("_scale",scale);
			
			if(vignetteTexture)
			{
				material.SetTexture("_VignetteTex", vignetteTexture);
			}
			
			if(scanLineTexture)
			{
				material.SetTexture("_ScanLineTex", scanLineTexture);
				material.SetFloat("_ScanLineTileAmount", scanLineTileAmount);
			}
			
			if(nightVisionNoise)
			{
				material.SetTexture("_NoiseTex", nightVisionNoise);
				material.SetFloat("_NoiseXSpeed", noiseXSpeed);
				material.SetFloat("_NoiseYSpeed", noiseYSpeed);
			}
			
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{
			Graphics.Blit(sourceTexture, destTexture);
		}
	}
	
	void Update()
	{
		contrast = Mathf.Clamp(contrast, 0f,4f);
		brightness = Mathf.Clamp(brightness, 0f, 2f);
		randomValue = Random.Range(-1f,1f);
		distortion = Mathf.Clamp(distortion, -1f,1f);
		scale = Mathf.Clamp(scale, 0f, 3f);
	}
	
	void OnDisable()
	{
		if(curMaterial)
		{
			DestroyImmediate(curMaterial);
		}
	}
}
