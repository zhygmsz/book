using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class SwapCubemaps : MonoBehaviour 
{
	public Cubemap cubeA;
	public Cubemap cubeB;
	
	public Transform posA;
	public Transform posB;
	
	private Material curMat;
	private Cubemap curCube;
	

	// Use this for initialization
	void Start () 
	{
	
	}
	
	// Update is called once per frame
	void Update () 
	{
		curMat = renderer.sharedMaterial;
		if(curMat)
		{
			curCube = CheckProbeDistance();
			curMat.SetTexture("_Cubemap", curCube);
			
		}
	}
	
	private Cubemap CheckProbeDistance()
	{
		float distA = Vector3.Distance(transform.position, posA.position);
		float distB = Vector3.Distance(transform.position, posB.position);
		
		if(distA < distB)
		{
			return cubeA;
		}
		else if(distB < distA)
		{
			return cubeB;
		}
		else
		{
			return cubeA;
		}
		
	}
		
	
	void OnDrawGizmos()
	{
		Gizmos.color = Color.green;
		
		if(posA)
		{
			Gizmos.DrawWireSphere(posA.position, 0.5f);
		}
		
		if(posB)
		{
			Gizmos.DrawWireSphere(posB.position, 0.5f);
		}
	}
}
