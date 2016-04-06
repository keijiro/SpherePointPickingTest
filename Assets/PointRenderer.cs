using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
public class PointRenderer : MonoBehaviour
{
    [SerializeField]
    int _pointCount = 100;

    [SerializeField]
    float _pointSize = 0.1f;

    [SerializeField]
    bool _strictlyUniform;

    [SerializeField]
    Shader _shader;

    Material _material;
    Mesh _mesh;

    void OnEnable()
    {
        var shader = Shader.Find("SpherePoints");

        _material = new Material(shader);
        _material.hideFlags = HideFlags.DontSave;

        var hash = new Klak.Math.XXHash(123);

        var va = new List<Vector3>();
        var ia = new List<int>();

        for (var i = 0; i < _pointCount; i++)
        {
            var rand1 = hash.Value01(i * 2);
            var rand2 = hash.Value01(i * 2 + 1);

            var vi = va.Count;

            va.Add(new Vector3(rand1, rand2, 0));
            va.Add(new Vector3(rand1, rand2, 1));
            va.Add(new Vector3(rand1, rand2, 2));
            va.Add(new Vector3(rand1, rand2, 3));

            ia.Add(vi);
            ia.Add(vi + 1);
            ia.Add(vi + 2);

            ia.Add(vi + 1);
            ia.Add(vi + 3);
            ia.Add(vi + 2);
        }

        _mesh = new Mesh();
        _mesh.name = "Points";
        _mesh.hideFlags = HideFlags.DontSave;
        _mesh.vertices = va.ToArray();
        _mesh.SetIndices(ia.ToArray(), MeshTopology.Triangles, 0);
        _mesh.bounds = new Bounds(Vector3.zero, Vector3.one);
        _mesh.UploadMeshData(true);
    }

    void OnDisable()
    {
        DestroyImmediate(_material);
        DestroyImmediate(_mesh);
    }

    void Update()
    {
        _material.SetFloat("_PointSize", _pointSize);

        if (_strictlyUniform)
            _material.EnableKeyword("_STRICT");
        else
            _material.DisableKeyword("_STRICT");

        Graphics.DrawMesh(
            _mesh, transform.localToWorldMatrix,
            _material, gameObject.layer
        );
    }
}
