using UnityEngine;
using System.Collections;

public class SpriteAnimator : MonoBehaviour 
{
	
	float timeValue = 0.0f;

	
	// Update is called once per frame
	void FixedUpdate () 
	{
		timeValue = Mathf.Ceil(Time.time % 16);
		transform.renderer.material.SetFloat("_TimeValue", timeValue);
	}
}
