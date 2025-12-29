
@tool class_name DebugDraw3D_Point extends _DebugDraw3D_Mesh

var _visual_shape : int = 0
@export_enum("Sphere", "Arrow") var visual_shape : int = 0 :
	get: return _visual_shape
	set(value):
		_visual_shape = value
		mesh_inst.rotation = Vector3.ZERO
		match _visual_shape:
			0:
				mesh_inst.mesh = POINT_MESH
			1:
				mesh_inst.mesh = ARROW_MESH
				mesh_inst.rotation_degrees.x = -90

var _radius : float
@export var radius : float = 0.25 :
	get: return _radius
	set(value):
		value = maxf(value, 0.0)
		_radius = value
		mesh_inst.scale = Vector3.ONE * value
		_on_radius_set()
func _on_radius_set() -> void: pass

func _init(__radius__: float = 0.25) -> void:
	super._init(DebugDraw3D.POINT_MESH)

	radius = __radius__
