using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class BlendMode_ImageEffect : MonoBehaviour 
{

	#region Variables
	public Shader curShader;
	public Texture2D blendTexture;
	public float blendOpacity = 1.0f;
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
			material.SetTexture("_BlendTex", blendTexture);
			material.SetFloat("_Opacity", blendOpacity);
			
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{
			Graphics.Blit(sourceTexture, destTexture);
		}
	}
	
	void Update()
	{
		blendOpacity = Mathf.Clamp(blendOpacity, 0.0f, 1.0f);
	}
	
	void OnDisable()
	{
		if(curMaterial)
		{
			DestroyImmediate(curMaterial);
		}
	}
}
