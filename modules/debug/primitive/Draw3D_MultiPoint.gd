
@tool class_name Draw3D_MultiPoint extends Draw3D_MultiMesh

var _size : float = 0.25
@export_range(0.0, 1.0, 0.01, "or_greater") var size : float = 0.25 :
	get: return _size
	set(value):
		_size = value
		_refresh()

func _init() -> void:
	super._init()

	mesh = POINT_MESH
	size = size

func _refresh() -> void:
	multimesh_inst.set_instance_shader_parameter(&"color", _color)
	multimesh_inst.multimesh.instance_count = _points.size() if not is_zero_approx(_size) else 0
	for i in multimesh_inst.multimesh.instance_count:
		multimesh_inst.multimesh.set_instance_transform(i, Transform3D(
			Basis.from_scale(Vector3.ONE * _size),
			_points[i]
		))