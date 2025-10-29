class_name NavigationAgentDebugger3D extends Node3D

@onready var _agent : NavigationAgent3D = get_parent()
@onready var _host : Node3D = _agent.get_parent()

var _points_size : float
@export_range(0.0, 1.0, 0.01, "or_greater") var points_size : float = 0.0 :
	get: return _points_size
	set(value):
		_points_size = value

		if not points_multimesh: return

		points_multimesh.multimesh.mesh.radius = _points_size
		points_multimesh.multimesh.mesh.height = _points_size * 2

var path_mesh : MeshInstance3D
var path_material : StandardMaterial3D

var target_material : StandardMaterial3D

var points_multimesh : MultiMeshInstance3D

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

	path_material = StandardMaterial3D.new()
	target_material = path_material.duplicate()
	target_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	path_mesh = MeshInstance3D.new()
	path_mesh.mesh = ImmediateMesh.new()
	path_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	path_material.flags_unshaded = true
	path_material.albedo_color = Color.WHITE
	path_mesh.set_material_override(path_material)
	add_child(path_mesh)

	points_multimesh = MultiMeshInstance3D.new()
	points_multimesh.multimesh = MultiMesh.new()
	points_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	points_multimesh.multimesh.mesh = SphereMesh.new()
	points_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	points_multimesh.layers = path_mesh.layers
	points_multimesh.material_override = target_material
	path_mesh.add_child(points_multimesh)
	points_size = points_size

	origin_label = create_new_label(self)
	origin_label.text = "O"

	_host.visibility_changed.connect(_on_host_visibility_changed)
	_agent.path_changed.connect(_on_agent_path_changed)

func _process(_delta: float) -> void:
	if _agent.is_target_reached():
		path_material.albedo_color = Color.BLUE
	elif _agent.is_navigation_finished():
		path_material.albedo_color = Color.RED
	else:
		path_material.albedo_color = Color.GREEN

	target_material.albedo_color = path_material.albedo_color * Color(1, 1, 1, 0.5)

	origin_label.modulate = path_material.albedo_color

	origin_label.global_position = _host.global_position

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

	points_multimesh.multimesh.instance_count = points.size() + 1

	var im: ImmediateMesh = path_mesh.mesh
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_POINTS, null)
	im.surface_add_vertex(points[0])
	im.surface_add_vertex(points[-1])
	im.surface_end()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for i in points.size():
		im.surface_add_vertex(points[i])
		points_multimesh.multimesh.set_instance_transform(i, Transform3D(Basis(), points[i]))
	im.surface_end()

	points_multimesh.multimesh.set_instance_transform(points.size(), Transform3D(Basis.from_scale(Vector3.ONE * _agent.target_desired_distance / points_size), _agent.target_position))
