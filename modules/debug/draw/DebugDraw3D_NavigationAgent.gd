class_name DebugDraw3D_NavigationAgent extends DebugDraw3D_MultiPoint

@onready var _agent : NavigationAgent3D = get_parent()
@onready var _host : Node3D = _agent.get_parent()

var _host_radius : float = 0.1
## The radius size of the host's location.
@export_range(0.0, 1.0, 0.01, "or_greater") var host_radius : float = 0.1 :
	get: return _host_radius
	set(value):
		_host_radius = value
		origin.scale = Vector3.ONE * _host_radius

var origin : MeshInstance3D
var target : MeshInstance3D

func _init(__top_level__: bool = true, __points__: PackedVector3Array = [], __points_radius__: float = 0.125) -> void:
	super._init(__top_level__, __points__, __points_radius__)

	origin = MeshInstance3D.new()
	origin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	origin.material_override = material
	origin.mesh = DebugDraw3D.POINT_MESH
	add_child(origin)

	target = MeshInstance3D.new()
	target.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	target.material_override = material
	target.mesh = DebugDraw3D.POINT_MESH
	add_child(target)

	host_radius = host_radius


func _ready() -> void:
	if not OS.is_debug_build(): return

	_host.visibility_changed.connect(_on_host_visibility_changed)
	_agent.path_changed.connect(_on_agent_path_changed)


func _process(delta: float) -> void:
	origin.position = _host.global_position
	target.scale = Vector3.ONE * _agent.target_desired_distance
	if _agent.is_target_reached():
		color = Color.BLUE
	elif _agent.is_navigation_finished():
		color = Color.RED
	else:
		color = Color.YELLOW


func _on_host_visibility_changed() -> void:
	visible = _host.visible

func _on_agent_path_changed() -> void:
	points = NavigationServer3D.map_get_path(
		_host.get_world_3d().get_navigation_map(),
		_host.global_position,
		_agent.target_position,
		true,
		_agent.navigation_layers
	)

	target.position = _agent.target_position
