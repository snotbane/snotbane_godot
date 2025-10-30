class_name DebugDraw3D extends Node3D

static var POINT_MESH : SphereMesh
static var MESH_MATERIAL : StandardMaterial3D

static var inst : DebugDraw3D

static func _static_init() -> void:
	MESH_MATERIAL = StandardMaterial3D.new()
	MESH_MATERIAL.flags_unshaded = true
	MESH_MATERIAL.albedo_color = Color.WHITE


	POINT_MESH = SphereMesh.new()
	POINT_MESH.radial_segments = 16
	POINT_MESH.rings = 8


static func point(id: StringName, point: Vector3, radius = 0.125) -> Node3D:
	return inst._point(id, point, radius)

static func text(id: StringName, point: Vector3, text: String, radius = 0.0, pixel_size: float = 0.0005, fixed_size: bool = true) -> Node3D:
	return inst._text(id, point, text, radius, pixel_size, fixed_size)

static func path(id: StringName, points: PackedVector3Array = [], point_size = null) -> Node3D:
	return inst._path(id, points, point_size)

static func line(id: StringName, a: Vector3, b: Vector3, head_size: float = 0.0) -> Node3D:
	return inst._line(id, a, b, head_size)

static func shape(id: StringName, transform: Transform3D, shape: Shape3D) -> Node3D:
	return inst._shape(id, transform, shape)

static func collision(collision: KinematicCollision3D, color: Color = Color(1, 1, 1, 0.05), duration: float = 1.0) -> Node3D:
	return inst._collision(collision, color, duration)

static func clear(id: StringName) -> void:
	inst.find_child(id).queue_free()

static func set_color(id: StringName, color: Color) -> void:
	var node := inst.registry.get(id)
	if node == null: return

	var material : StandardMaterial3D = node.get_meta(&"_material")
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED if color.a >= 1.0 else BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color

var registry : Dictionary[StringName, Node3D]

func _ready() -> void:
	inst = self

func _mesh(mesh: Mesh, material: Material = MESH_MATERIAL.duplicate()) -> MeshInstance3D:
	var result := MeshInstance3D.new()
	result.mesh = mesh
	result.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	result.material_override = material

	return result

func _point(id: StringName, point: Vector3, radius) -> Node3D:
	var result : Node3D = registry.get(id)
	var create := result == null

	var mesh_inst: MeshInstance3D
	if create:
		result = Node3D.new()
		registry[id] = result

		mesh_inst = _mesh(POINT_MESH)
		result.add_child(mesh_inst)

		result.set_meta(&"_material", mesh_inst.material_override)
		add_child(result)
	else:
		mesh_inst = result.get_child(0)

	result.position = point
	mesh_inst.scale = Vector3.ONE * maxf(0.0, radius * 2)

	return result

func _text(id: StringName, point: Vector3, text: String, radius, pixel_size: float, fixed_size: bool) -> Node3D:
	var create := not registry.has(id)
	var result : Node3D = _point(id, point, radius)

	var label : Label3D
	if create:
		label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.double_sided = false

		result.add_child(label)
	else:
		label = result.get_child(1)

	label.text = text
	label.fixed_size = fixed_size
	label.pixel_size = pixel_size
	label.modulate = result.get_child(0).material_override.albedo_color
	label.position = Vector3.UP * (radius + (0.25 if radius > 0.0 else 0.0))

	return result


func _path(id: StringName, points: PackedVector3Array, point_size = null) -> Node3D:
	var result : Node3D = registry.get(id)
	var create := result == null
	if create:
		result = Node3D.new()
		registry[id] = result
		result.set_meta(&"_material", MESH_MATERIAL.duplicate())
		add_child(result)

	var path_mesh : ImmediateMesh = ImmediateMesh.new() if create else result.get_child(0).mesh
	path_mesh.clear_surfaces()
	path_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, result.get_meta(&"_material"))
	for i in points.size():	path_mesh.surface_add_vertex(points[i])
	path_mesh.surface_end()

	var points_multimesh : MultiMeshInstance3D
	if create:
		var mesh_inst := _mesh(path_mesh, result.get_meta(&"_material"))
		result.add_child(mesh_inst)

		points_multimesh = MultiMeshInstance3D.new()
		points_multimesh.multimesh = MultiMesh.new()
		points_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		points_multimesh.multimesh.mesh = POINT_MESH
		points_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		points_multimesh.material_override = result.get_meta(&"_material")
		result.add_child(points_multimesh)

		if point_size == null:
			point_size = 0.0

	else:
		points_multimesh = result.get_child(1)

	if point_size == null:
		point_size = result.get_meta(&"point_size", 0.0)
	else:
		result.set_meta(&"point_size", point_size)

	if point_size > 0.0:
		points_multimesh.multimesh.instance_count = points.size()
		for i in points.size():	points_multimesh.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * point_size), points[i]))
	else:
		points_multimesh.multimesh.instance_count = 0

	return result


func _line(id: StringName, a: Vector3, b: Vector3, head_size: float = 0.0) -> Node3D:
	var direction := (b - a).normalized()
	var length := a.distance_to(b)
	var head_length := clampf(head_size, 0.0, length)

	var create := not registry.has(id)
	var result := _path(id, [a, a + direction * (length - head_length)], 0.0)

	var head : Node3D
	var head_mesh : CylinderMesh
	if create:
		head_mesh = CylinderMesh.new()
		head_mesh.cap_top = false
		head_mesh.top_radius = 0.0
		head_mesh.radial_segments = 16
		head_mesh.rings = 3

		head = Node3D.new()
		var mesh_inst := _mesh(head_mesh, result.get_meta(&"_material"))
		mesh_inst.rotation_degrees.x = -90

		head.add_child(mesh_inst)
		result.add_child(head)
	else:
		head = result.get_child(2)
		head_mesh = head.get_child(0).mesh

	head_mesh.height = head_length
	head_mesh.bottom_radius = head_mesh.height * 0.25

	head.global_position = a + direction * (length - (head_length * 0.5))
	head.look_at(
		head.global_position + direction,
		Vector3.FORWARD if direction.is_equal_approx(Vector3.UP) else Vector3.UP
	)

	return result

func _shape(id: StringName, transform: Transform3D, shape: Shape3D) -> Node3D:
	var result := registry.get(id, null)
	var create := result == null

	var mesh_inst : MeshInstance3D
	if create:
		result = Node3D.new()
		registry[id] = result
		add_child(result)

		mesh_inst = _mesh(shape.get_debug_mesh())
		result.add_child(mesh_inst)

		result.set_meta(&"_material", mesh_inst.material_override)


		set_color(id, Color(1, 1, 1, 0.05))
	else:
		mesh_inst = result.get_child(0)

	mesh_inst.transform = transform

	return result

func _collision(collision: KinematicCollision3D, color: Color, duration: float) -> Node3D:
	var result = Node3D.new()
	add_child(result)

	for i in collision.get_collision_count():
		var shape : Shape3D = collision.get_collider_shape(i)

		var material : StandardMaterial3D = MESH_MATERIAL.duplicate()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.albedo_color = color

		var mesh_inst := _mesh(shape.get_debug_mesh())
		result.add_child(mesh_inst)

	if duration > 0.0:
		var timer := Timer.new()
		timer.wait_time = duration
		timer.autostart = true
		timer.timeout.connect(result.queue_free)
		result.add_child(timer)
	elif duration == 0.0:
		result.queue_free.call_deferred()
		return null

	return result
