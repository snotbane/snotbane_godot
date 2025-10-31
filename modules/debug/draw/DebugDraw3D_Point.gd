
class_name DebugDraw3D_Point extends _DebugDraw3D_Mesh

var _radius : float
var radius : float :
	get: return _radius
	set(value):
		value = maxf(value, 0.0)
		if _radius == value: return
		_radius = value
		mesh_inst.scale = Vector3.ONE * value

func _init(__top_level__: bool = true, __position__: Vector3 = Vector3.ZERO, __radius__: float = 0.25) -> void:
	super._init(__top_level__, DebugDraw3D.POINT_MESH)

	position = __position__
	radius = __radius__
