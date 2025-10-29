class_name NavigationAgentDebugger3D extends Node3D

@onready var _agent : NavigationAgent3D = get_parent()
@onready var _host : Node3D = _agent.get_parent()

var _points_size : float
@export_range(0.0, 1.0, 0.01, "or_greater") var points_size : float = 0.0 :
	get: return _points_size
	set(value):
		_points_size = value

var path_mesh : MeshInstance3D
var path_material : StandardMaterial3D :
	get: return debug_draw.get_meta(&"_material")

var target_material : StandardMaterial3D

var points_multimesh : MultiMeshInstance3D

var debug_draw : Node3D
var origin_label : Label3D

func create_new_label(parent: Node) -> Label3D:
	var result := Label3D.new()
	result.fixed_size = true
	result.double_sided = false
	result.pixel_size = 0.0005
	result.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(result)
	return result


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	_host.visibility_changed.connect(_on_host_visibility_changed)
	_agent.path_changed.connect(_on_agent_path_changed)

func _exit_tree() -> void:
	DebugDraw3D.clear(name + &"_path")

func _process(_delta: float) -> void:
	if not visible: return

	var color : Color
	if _agent.is_target_reached():
		color = Color.BLUE
	elif _agent.is_navigation_finished():
		color = Color.RED
	else:
		color = Color.YELLOW

	DebugDraw3D.set_color(name + &"_path", color)
	DebugDraw3D.set_color(name + &"_origin", color)
	DebugDraw3D.set_color(name + &"_target", color)

	DebugDraw3D.point(name + &"_origin", _host.global_position)
	DebugDraw3D.point(name + &"_target", _agent.target_position, _agent.target_desired_distance)

func _on_host_visibility_changed() -> void:
	visible = _host.visible

func _on_agent_path_changed() -> void:
	var points := NavigationServer3D.map_get_path(
			_host.get_world_3d().get_navigation_map(),
			_host.global_position,
			_agent.target_position,
			true,
			_agent.navigation_layers
	)

	DebugDraw3D.path(name + &"_path", points, points_size)
