
@tool class_name Draw3D_Point extends Draw3D_Mesh

var _size : float = 0.25
@export_range(0.0, 1.0, 0.01, "or_greater") var size : float = 0.25 :
	get: return _size
	set(value):
		_size = value
		mesh_inst.scale = Vector3.ONE * _size
		mesh_inst.visible = not is_zero_approx(_size)

func _init(__size__: float = size) -> void:
	super._init(POINT_MESH if mesh == null else mesh)

	size = __size__
