using UnityEngine;
using System.Collections;

public class ProceduralTexture : MonoBehaviour 
{
	#region Public Variables
	//These values will let us control the width/Height
	//and see the generated texture
	public int widthHeight = 512;
	public Texture2D generatedTexture;
	#endregion
	
	#region Private Variables
	//These variables will be internal to this
	//script
	private Material currentMaterial;
	private Vector2 centerPosition;
	#endregion
	

	// Use this for initialization
	void Start () 
	{
		//Simple check to make sure we have a material on this transform
		//This will determine if we can make a texture or not
		if(!currentMaterial)
		{
			currentMaterial = transform.renderer.sharedMaterial;
			if(!currentMaterial)
			{
				Debug.LogWarning("Cannot find a material on: " + transform.name);
			}
		}
		
		//generate the procedural texture
		if(currentMaterial)
		{
			//Generate the prabola texture
			centerPosition = new Vector2(0.5f, 0.5f);
			generatedTexture = GenerateParabola();
			
			//Assign it to this transforms material
			currentMaterial.SetTexture("_MainTex", generatedTexture);
		}
		
		Debug.Log(Vector2.Distance(new Vector2(256,256), new Vector2(32,32))/256.0f);
	
	}

	
	private Texture2D GenerateParabola()
	{
		//Create a new Texture2D
		Texture2D proceduralTexture = new Texture2D(widthHeight, widthHeight);
		
		//Get the center of the texture
		Vector2 centerPixelPosition = centerPosition * widthHeight;
		
		//loop through each pixel of the new texture and determine its 
		//distance from the center and assign a pixel value based on that.
		for(int x = 0; x < widthHeight; x++)
		{
			for(int y = 0; y < widthHeight; y++)
			{
				//Get the distance from the center of the texture to
				//our currently selected pixel
				Vector2 currentPosition = new Vector2(x,y);
				float pixelDistance = Vector2.Distance(currentPosition, centerPixelPosition)/(widthHeight*0.5f);
				pixelDistance = Mathf.Abs(1-Mathf.Clamp(pixelDistance, 0f,1f));
				pixelDistance = (Mathf.Sin(pixelDistance * 30.0f) * pixelDistance);
				
				//you can also do some more advanced vector calculations to achieve
				//other types of data about the model itself and its uvs and
				//pixels
				Vector2 pixelDirection = centerPixelPosition - currentPosition;
				pixelDirection.Normalize();
				float rightDirection = Vector2.Angle(pixelDirection, Vector3.right)/360;
				float leftDirection = Vector2.Angle(pixelDirection, Vector3.left)/360;
				float upDirection = Vector2.Angle(pixelDirection, Vector3.up)/360;
				
				//Invert the values and make sure we dont get any negative values 
				//or values above 1.
				
				
				//Create a new color value based off of our
				//Color pixelColor = new Color(Mathf.Max(0.0f, rightDirection),Mathf.Max(0.0f, leftDirection), Mathf.Max(0.0f,upDirection), 1f);
				Color pixelColor = new Color(pixelDistance, pixelDistance, pixelDistance, 1.0f);
				//Color pixelColor = new Color(rightDirection, leftDirection, upDirection, 1.0f);
				proceduralTexture.SetPixel(x,y,pixelColor);
			}
		}
		//Finally force the application of the new pixels to the texture
		proceduralTexture.Apply();
		
		//return the texture to the main program.
		return proceduralTexture;
	}
}
