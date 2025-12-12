
@tool class_name DebugDraw3D_Shape extends _DebugDraw3D_Mesh

var shape : Shape3D

var _color := Color(1.0, 1.0, 1.0, 0.05)
@export var color := Color(1.0, 1.0, 1.0, 0.05) :
	get: return _color
	set(value):
		_color = value
		mesh_inst.set_instance_shader_parameter(&"color", value)

func _init(__shape__: Shape3D = null) -> void:
	shape = __shape__

	super._init(shape != null, null)

	mesh_inst.material_override = MESH_MATERIAL

func _ready() -> void:
	super._ready()

	if shape == null:
		shape = get_parent().shape
		global_transform = get_parent().global_transform
	shape.changed.connect(refresh_mesh)
	refresh_mesh()
	color = color

func refresh_mesh() -> void:
	mesh_inst.mesh = shape.get_debug_mesh()
