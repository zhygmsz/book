using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class SceneDepth_ImageEffect : MonoBehaviour 
{

	#region Variables
	public Shader curShader;
	private Material curMaterial;
	
	public float depthPower = 1.0f;
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
			material.SetFloat("_DepthPower", depthPower);
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{
			Graphics.Blit(sourceTexture, destTexture);
		}
	}
	
	void Update()
	{
		Camera.main.depthTextureMode = DepthTextureMode.Depth;
		depthPower = Mathf.Clamp(depthPower, 0, 5);
	}
	
	void OnDisable()
	{
		if(curMaterial)
		{
			DestroyImmediate(curMaterial);
		}
	}
}
