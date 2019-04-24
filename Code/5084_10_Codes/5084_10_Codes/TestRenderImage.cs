using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class TestRenderImage : MonoBehaviour 
{
	#region Variables
	public Shader curShader;
	public float brightnessAmount = 1.0f;
	public float saturationAmount = 1.0f;
	public float contrastAmount = 1.0f;
	private Material curMaterial;
	#endregion
	
	#region Properties
	Material material
	{
		get
		{
			if(curMaterial == null)
			{
				curMaterial = new Material(curShader);
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
		
		if(!curShader && !curShader.isSupported)
		{
			enabled = false;
		}
	}
	
	void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
	{
		if(curShader != null)
		{	
			material.SetFloat("_BrightnessAmount", brightnessAmount);
			material.SetFloat("_satAmount", saturationAmount);
			material.SetFloat("_conAmount", contrastAmount);
			
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{
			Graphics.Blit(sourceTexture, destTexture);
		}
	}
	
	void Update()
	{
		brightnessAmount = Mathf.Clamp(brightnessAmount, 0.0f, 1.0f);
		saturationAmount = Mathf.Clamp(saturationAmount, 0.0f, 1.0f);
		contrastAmount = Mathf.Clamp(contrastAmount, 0.0f, 3.0f);
	}
	
	void OnDisable()
	{
		if(curMaterial)
		{
			DestroyImmediate(curMaterial);
		}
	}
}
