using UnityEngine;

[ExecuteInEditMode]
public class PointRenderer : MonoBehaviour
{
    enum Mode { OnSphere, InsideSphere }

    [SerializeField] int _pointCount = 100;
    [SerializeField] Mode _mode;

    [SerializeField, HideInInspector] Shader _shader;
    Material _material;

    void OnDestroy()
    {
        if (_material != null)
            if (Application.isPlaying)
                Destroy(_material);
            else
                DestroyImmediate(_material);
    }

    void OnRenderObject()
    {
        if (_material == null)
        {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.DontSave;
        }

        _material.SetPass(0);

        if (_mode == Mode.InsideSphere)
            _material.EnableKeyword("_INSIDE_SPHERE");
        else
            _material.DisableKeyword("_INSIDE_SPHERE");

        Graphics.DrawProcedural(MeshTopology.Points, _pointCount);
    }
}
