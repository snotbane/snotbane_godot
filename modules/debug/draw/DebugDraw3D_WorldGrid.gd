
@tool class_name DebugDraw3D_WorldGrid extends _DebugDraw3D_Mesh

const WORLD_MESH := preload("uid://pqjfvxv40wmq")

var _dot_radius : float
@export var dot_radius : float = 0.01 :
	get: return _dot_radius
	set(value):
		if _dot_radius == value: return
		_dot_radius = value

		mesh_inst.set_instance_shader_parameter(&"dot_radius", _dot_radius)

var _dot_spacing : float
@export var dot_spacing : float = 1.0 :
	get: return _dot_spacing
	set(value):
		if _dot_spacing == value: return
		_dot_spacing = value

		mesh_inst.set_instance_shader_parameter(&"dot_spacing", _dot_spacing)

var _max_render_distance : float
@export var max_render_distance : float = 10.0 :
	get: return _max_render_distance
	set(value):
		if _max_render_distance == value: return
		_max_render_distance = value

		mesh_inst.set_instance_shader_parameter(&"max_render_distance", _max_render_distance)

func _init() -> void:
	super._init(true, WORLD_MESH)

	mesh_inst.material_override = null


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed(Snotbane.INPUT_DEBUG_GRID_TOGGLE):
		visible = not visible
