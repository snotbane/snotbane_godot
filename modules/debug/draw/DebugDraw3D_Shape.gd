
class_name DebugDraw3D_Shape extends _DebugDraw3D_Mesh

var shape : Shape3D

func _init(__shape__: Shape3D = null) -> void:
	shape = __shape__

	super._init(shape != null, null)

func _ready() -> void:
	if shape == null:
		shape = get_parent().shape
		global_transform = get_parent().global_transform
	mesh_inst.mesh = shape.get_debug_mesh()
	opacity = 0.05
