class_name DebugDraw3D extends Node3D

static var inst : DebugDraw3D

static func path_3d(id: StringName, points: PackedVector3Array, point_size: float = 0.0) -> void:
	inst._path_3d(id, points, point_size)

static func line_3d(id: StringName, a: Vector3, b: Vector3, head_size: float = 0.0) -> void:
	inst._line_3d(id, a, b, head_size)

static func clear(id: StringName) -> void:
	inst.find_child(id).queue_free()

func _ready() -> void:
	inst = self

func _path_3d(id: StringName, points: PackedVector3Array, point_size: float = 0.0) -> Node3D:
	var result : Node3D = find_child(id)
	var create := result == null
	if create:
		result = Node3D.new()
		result.name = id

		var material := StandardMaterial3D.new()
		material.flags_unshaded = true
		material.albedo_color = Color.WHITE
		result.set_meta(&"_material", material)

		add_child(result)

	var path_mesh : ImmediateMesh = ImmediateMesh.new() if create else result.get_meta(&"_path_mesh")
	path_mesh.clear_surfaces()
	path_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, result.get_meta(&"_material"))
	for i in points.size():	path_mesh.surface_add_vertex(points[i])
	path_mesh.surface_end()

	var points_multimesh : MultiMeshInstance3D
	if create:
		var path := MeshInstance3D.new()
		path.mesh = path_mesh
		path.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		result.add_child(path)

		var points_mesh := SphereMesh.new()
		points_mesh.radial_segments = 16
		points_mesh.rings = 8
		points_mesh.radius = point_size
		points_mesh.height = point_size * 2
		points_mesh.material = result.get_meta(&"_material")

		points_multimesh = MultiMeshInstance3D.new()
		points_multimesh.multimesh = MultiMesh.new()
		points_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		points_multimesh.multimesh.mesh = points_mesh
		points_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		points_multimesh.layers = result.layers
		result.add_child(points_multimesh)
	else:
		points_multimesh = result.get_child(1)

	if point_size > 0.0:
		points_multimesh.multimesh.instance_count = points.size()
		for i in points.size():	points_multimesh.multimesh.set_instance_transform(i, Transform3D(Basis(), points[i]))
	else:
		points_multimesh.multimesh.instance_count = 0

	return result


func _line_3d(id: StringName, a: Vector3, b: Vector3, head_size: float = 0.0) -> Node3D:
	var create := find_child(id) == null

	var direction := (b - a).normalized()
	var length := a.distance_to(b)
	var head_length := clampf(head_size, 0.0, length)

	var result := _path_3d(id, [a, a + direction * (length - head_length)], 0.0)

	var head : MeshInstance3D
	if create:
		var head_mesh := CylinderMesh.new()
		head_mesh.cap_top = false
		head_mesh.top_radius = 0.0
		head_mesh.radial_segments = 16
		head_mesh.rings = 3
		head_mesh.height = head_length
		head_mesh.bottom_radius = head_mesh.height * 0.5
		head_mesh.material = result.get_meta(&"_material")

		head = MeshInstance3D.new()
		head.mesh = head_mesh

		result.add_child(head)
	else:
		head = result.get_child(2)

	head.look_at_from_position(
		direction * (length - (head_length * 0.5)),
		head.global_position + direction,
		Vector3.FORWARD if direction.is_equal_approx(Vector3.UP) else Vector3.UP
	)

	return result
