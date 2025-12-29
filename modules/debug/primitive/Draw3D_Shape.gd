
@tool class_name Draw3D_Shape extends Draw3D_Mesh

var _shape : Shape3D
@export var shape : Shape3D :
	get: return _shape
	set(value):
		_shape = value

func _ready() -> void:
	if get_parent() is CollisionShape3D:
		shape = get_parent().shape
		shape.changed.connect(_refresh)

	super._ready()


func _refresh() -> void:
	super._refresh()
	mesh_inst.mesh = _shape.get_debug_mesh()
