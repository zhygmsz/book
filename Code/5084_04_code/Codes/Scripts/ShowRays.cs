using UnityEngine;
using System.Collections;

public class ShowRays : MonoBehaviour 
{
	MeshFilter curFilter;
	public float gizmosSize = 1.0f;
	

	// Use this for initialization
	void Start () 
	{
	
	}
	
	// Update is called once per frame
	void Update () 
	{
	
	}
	
	void OnDrawGizmos()
	{
		Gizmos.matrix = transform.localToWorldMatrix;
		Vector3 camPosition = Camera.main.transform.position;
		
		if(!curFilter)
		{
			curFilter = transform.GetComponent<MeshFilter>();
			if(!curFilter)
			{
				Debug.LogWarning("No mesh filter found!!");
			}
		}
		else
		{
			Mesh curMesh = curFilter.sharedMesh;
			if(curMesh)
			{
				for(int i = 0; i < curMesh.vertices.Length; i++)
				{
					
					Vector3 viewDir = (curMesh.vertices[i] - camPosition).normalized;
					Vector3 curReflVector = Reflect(viewDir, curMesh.normals[i]);
					
					Gizmos.color = new Color(curReflVector.x,curReflVector.y,curReflVector.z, 1.0f);
					Gizmos.DrawRay(curMesh.vertices[i], curReflVector * gizmosSize);
				}
			}
		}
	}
	
	Vector3 Reflect(Vector3 viewDir, Vector3 normal)
	{
		Vector3 reflection = viewDir - 2.0f * normal * Vector3.Dot(normal, viewDir);
		return reflection;
	}
}
