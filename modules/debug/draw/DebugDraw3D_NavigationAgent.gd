
@tool class_name DebugDraw3D_NavigationAgent extends DebugDraw3D_MultiPoint

@onready var _agent : NavigationAgent3D = get_parent()
@onready var _host : Node3D = _agent.get_parent()

var _host_radius : float = 0.1
## The radius size of the host's location.
@export_range(0.0, 1.0, 0.01, "or_greater") var host_radius : float = 0.1 :
	get: return _host_radius
	set(value):
		_host_radius = value
		origin.scale = Vector3.ONE * _host_radius

func _on_color_set() -> void:
	origin.set_instance_shader_parameter(&"color", color)

var origin : MeshInstance3D

func _init(__points__: PackedVector3Array = [], __points_radius__: float = 0.125) -> void:
	super._init(__points__, __points_radius__)

	origin = MeshInstance3D.new()
	origin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	origin.mesh = DebugDraw3D.ARROW_MESH
	add_child(origin, false, INTERNAL_MODE_BACK)

	host_radius = host_radius


func _ready() -> void:
	super._ready()

	if not OS.is_debug_build(): return

	if not Engine.is_editor_hint():
		reparent.call_deferred(_host)

		if _agent is Brain3D:
			_agent.desired_move.connect(_on_brain_desired_move)


func _physics_process(delta: float) -> void:
	origin.position = _host.global_position

	if Engine.is_editor_hint(): return

	if _agent.is_target_reached():
		if _agent is Brain3D:
			if _agent._travel_state == Brain3D.STOPPED:
				color = Color.BLUE
			else:
				color = Color.AQUAMARINE
		else:
			color = Color.BLUE
	elif _agent.is_navigation_finished():
		color = Color.RED
	else:
		color = Color.YELLOW

	points = _agent.get_current_navigation_path()


func _refresh_points() -> void:
	if _agent == null:
		multimesh_inst.multimesh.instance_count = 0
		return

	var extra_points : int = 1
	if not Engine.is_editor_hint():
		if _agent is Brain3D and _agent.target.is_assigned: extra_points += 1

	var idx := _agent.get_current_navigation_path_index()
	multimesh_inst.multimesh.instance_count = (_points.size() if _points_radius > 0.0 else 0) + extra_points
	for i in points.size():
		var final_scale := points_radius * (2.0 if i == idx else 1.0)
		multimesh_inst.multimesh.set_instance_transform(
			i,
			Transform3D(Basis.from_scale(Vector3.ONE * final_scale), _points[i])
		)

	multimesh_inst.multimesh.set_instance_transform(
		multimesh_inst.multimesh.instance_count - extra_points,
		Transform3D(Basis.from_scale(Vector3.ONE * _agent.target_desired_distance), _agent.target_position)
	)
	extra_points -= 1

	if not Engine.is_editor_hint():
		if _agent is Brain3D and _agent.target.is_assigned:
			multimesh_inst.multimesh.set_instance_transform(
				multimesh_inst.multimesh.instance_count - extra_points,
				Transform3D(Basis.from_scale(Vector3.ONE * _agent.target_desired_distance), _agent.target.target_position)
			)
			extra_points -= 1


func _on_brain_desired_move(direction: Vector3) -> void:
	if direction.is_zero_approx(): return

	origin.global_basis = Basis.looking_at(direction) * Basis(Vector3.RIGHT, deg_to_rad(-90)).scaled(Vector3.ONE * host_radius)
