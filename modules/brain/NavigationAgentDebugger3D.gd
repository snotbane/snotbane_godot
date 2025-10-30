class_name NavigationAgentDebugger3D extends Node3D

@onready var _agent : NavigationAgent3D = get_parent()
@onready var _host : Node3D = _agent.get_parent()

var _points_size : float
@export_range(0.0, 1.0, 0.01, "or_greater") var points_size : float = 0.0 :
	get: return _points_size
	set(value):
		_points_size = value
		debug_path.points_radius = _points_size

var debug_path : DebugDraw3D.Path
var debug_point_origin : DebugDraw3D.Point
var debug_point_target : DebugDraw3D.Point
var debug_ray : DebugDraw3D.Ray

func create_new_label(parent: Node) -> Label3D:
	var result := Label3D.new()
	result.fixed_size = true
	result.double_sided = false
	result.pixel_size = 0.0005
	result.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(result)
	return result

func _init() -> void:
	if not OS.is_debug_build(): return

	debug_path = DebugDraw3D.Path.new()
	debug_point_origin = DebugDraw3D.Point.new()
	debug_point_target = DebugDraw3D.Point.new()
	debug_ray = DebugDraw3D.Ray.from_global_to_global()


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	add_child(debug_path, false, INTERNAL_MODE_BACK)
	add_child(debug_point_origin, false, INTERNAL_MODE_BACK)
	add_child(debug_point_target, false, INTERNAL_MODE_BACK)
	add_child(debug_ray, false, INTERNAL_MODE_BACK)

	_host.visibility_changed.connect(_on_host_visibility_changed)
	_agent.path_changed.connect(_on_agent_path_changed)


func _process(_delta: float) -> void:
	if not visible: return

	var color : Color
	if _agent.is_target_reached():
		color = Color.BLUE
	elif _agent.is_navigation_finished():
		color = Color.RED
	else:
		color = Color.YELLOW

	debug_path.color = color

	debug_point_origin.color = color
	debug_point_origin.position = _host.global_position

	debug_point_target.color = color
	debug_point_target.position = _agent.target_position
	debug_point_target.radius = _agent.target_desired_distance

func _on_host_visibility_changed() -> void:
	visible = _host.visible

func _on_agent_path_changed() -> void:
	debug_path.points = NavigationServer3D.map_get_path(
		_host.get_world_3d().get_navigation_map(),
		_host.global_position,
		_agent.target_position,
		true,
		_agent.navigation_layers
	)

	if debug_path.points.size() < 2: return

	debug_ray.origin = debug_path.points[0]
	debug_ray.target = debug_path.points[-1]
