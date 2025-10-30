class_name DebugDraw3D extends Node3D

const POINT_MESH : Mesh = preload("uid://cnkvd3t13kcod")
const ARROW_MESH : Mesh = preload("uid://bak40cp1rwhko")
const MESH_MATERIAL : StandardMaterial3D = preload("uid://bdosbg5iohx24")

static var inst : DebugDraw3D

class _Generic extends Node3D:
	var _color : Color
	var color : Color :
		get: return _color
		set(value):
			if _color == value: return
			_color = value
			material.albedo_color = _color
			_on_color_set()
	func _on_color_set() -> void: pass
	var opacity : float :
		get: return color.a
		set(value): color = Color(color.r, color.r, color.b, value)

	var timer : Timer
	var _duration : float
	var duration : float :
		get: return _duration
		set(value):
			value = maxf(0.0, value)
			if _duration == value: return
			_duration = value

			if _duration > 0.0:
				if timer.is_inside_tree(): timer.start()
				else: timer.autostart = true
				timer.wait_time = _duration
			else:
				if timer.is_inside_tree(): timer.stop()
				else: timer.autostart = false

	var material : StandardMaterial3D

	func _init(__top_level__: bool) -> void:
		top_level = __top_level__
		material = DebugDraw3D.MESH_MATERIAL.duplicate()

		timer = Timer.new()
		timer.autostart = false
		timer.timeout.connect(queue_free)

	func _ready() -> void:
		add_child(timer)

class _Mesh extends DebugDraw3D._Generic:
	var mesh_inst : MeshInstance3D

	func _init(__top_level__: bool, __mesh__: Mesh) -> void:
		super._init(__top_level__)

		mesh_inst = MeshInstance3D.new()
		mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_inst.material_override = material
		mesh_inst.mesh = __mesh__


	func _ready() -> void:
		super._ready()

		add_child(mesh_inst)

class _MultiMesh extends DebugDraw3D._Generic:
	var multimesh_inst : MultiMeshInstance3D

	func _init(__top_level__: bool, __mesh__: Mesh) -> void:
		super._init(__top_level__)

		multimesh_inst = MultiMeshInstance3D.new()
		multimesh_inst.multimesh = MultiMesh.new()
		multimesh_inst.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh_inst.multimesh.mesh = __mesh__
		multimesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		multimesh_inst.material_override = material


	func _ready() -> void:
		super._ready()

		add_child(multimesh_inst)

class Point extends DebugDraw3D._Mesh:
	var _radius : float
	var radius : float :
		get: return _radius
		set(value):
			value = maxf(value, 0.0)
			if _radius == value: return
			_radius = value
			mesh_inst.scale = Vector3.ONE * value

	func _init(__top_level__: bool = true, __position__: Vector3 = Vector3.ZERO, __radius__: float = 0.25) -> void:
		super._init(__top_level__, DebugDraw3D.POINT_MESH)

		position = __position__
		radius = __radius__

class Text extends DebugDraw3D.Point:
	func _on_color_set() -> void:
		label.modulate = color

	var text : String :
		get: return label.text
		set(value):
			if text == value: return
			label.text = value

	var label : Label3D

	func _init(__top_level__: bool = true, __position__: Vector3 = Vector3.ZERO, __text__: String = "") -> void:
		super._init(__top_level__, __position__, 0.125)

		label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.double_sided = false
		label.fixed_size = true
		label.pixel_size = 0.0005
		label.modulate = color
		label.position = Vector3.UP * radius * 1.25

		text = __text__

	func _ready() -> void:
		super._ready()

		add_child(label)

class MultiPoint extends DebugDraw3D._MultiMesh:
	var _points_radius : float
	var points_radius : float :
		get: return _points_radius
		set(value):
			value = maxf(value, 0.0)
			if _points_radius == value: return
			_points_radius = value

			_refresh_multimesh()

	var _points : PackedVector3Array
	var points : PackedVector3Array :
		get: return _points
		set(value):
			_points = value

			_refresh_multimesh()
			_on_points_set()
	func _on_points_set() -> void: pass


	func _refresh_multimesh() -> void:
		multimesh_inst.multimesh.instance_count = _points.size() if _points_radius > 0.0 else 0
		for i in multimesh_inst.multimesh.instance_count:
			multimesh_inst.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * points_radius), _points[i]))


	func _init(__top_level__: bool = true, __points__: PackedVector3Array = [], __points_radius__: float = 0.125) -> void:
		super._init(__top_level__, POINT_MESH)

		points = __points__

class Path extends DebugDraw3D.MultiPoint:
	func _on_points_set() -> void:
		mesh_inst.mesh.clear_surfaces()
		if points.size() == 0: return
		mesh_inst.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		for i in points.size():
			mesh_inst.mesh.surface_add_vertex(points[i])
		mesh_inst.mesh.surface_end()

	var mesh_inst : MeshInstance3D

	func _init(__top_level__: bool = true, __points__: PackedVector3Array = [], __points_radius__: float = 0.0) -> void:
		mesh_inst = MeshInstance3D.new()
		mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_inst.mesh = ImmediateMesh.new()

		super._init(__top_level__, __points__, __points_radius__)

		mesh_inst.material_override = material

	func _ready() -> void:
		super._ready()

		add_child(mesh_inst)

class Ray extends DebugDraw3D._Generic:
	var _max_head_size : float
	var max_head_size : float :
		get: return _max_head_size
		set(value):
			if _max_head_size == value: return
			_max_head_size = value
			_refresh()
	var _origin : Vector3
	var origin : Vector3 :
		get: return _origin
		set(value):
			if _origin == value: return
			_origin = value
			_refresh()
	var _target : Vector3
	var target : Vector3 :
		get: return _target
		set(value):
			if _target == value: return
			_target = value
			_refresh()
	var normal : Vector3 :
		get: return (target - origin).normalized()
		set(value): target = origin + value * length
	var length : float :
		get: return origin.distance_to(target)
		set(value): target = origin + normal * value
	func _refresh() -> void:
		if not is_inside_tree(): return

		var head_length := clampf(max_head_size, 0.0, length)

		line_mesh_inst.mesh.clear_surfaces()
		line_mesh_inst.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		line_mesh_inst.mesh.surface_add_vertex(origin)
		line_mesh_inst.mesh.surface_add_vertex(origin + normal * (length - head_length))
		# line_mesh_inst.mesh.surface_add_vertex(origin.lerp(target, (1.0 - head_length) / length))
		line_mesh_inst.mesh.surface_end()

		head_offset.scale = Vector3.ONE * head_length
		head_offset.global_position = origin + normal * (length - (head_length * 0.5))
		# head_offset.global_position = origin.lerp(target, (1.0 - (head_length * 0.5) / length))
		head_offset.look_at(
			head_offset.global_position + normal,
			Vector3.FORWARD if normal.is_equal_approx(Vector3.UP) else Vector3.UP
		)

	var head_offset : Node3D
	var head_mesh_inst : MeshInstance3D
	var line_mesh_inst : MeshInstance3D

	static func from_global_to_global(__origin__:= Vector3.ZERO, __target__:= Vector3.ZERO, __head_size__: float = 0.25) -> Ray:
		return Ray.new(true, __origin__, __target__, __head_size__)

	static func to_direction(__normal__: Vector3, __length__: float = 1.0, __head_size__: float = 0.25) -> Ray:
		return Ray.new(false, Vector3.ZERO, __normal__ * __length__, __head_size__)

	func _init(__top_level__: bool, __origin__: Vector3, __target__: Vector3, __head_size__: float = 0.25) -> void:
		super._init(__top_level__)

		origin = __origin__
		target = __target__

		head_offset = Node3D.new()

		head_mesh_inst = MeshInstance3D.new()
		head_mesh_inst.rotation_degrees.x = -90.0
		head_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		head_mesh_inst.material_override = material
		head_mesh_inst.mesh = DebugDraw3D.ARROW_MESH

		line_mesh_inst = MeshInstance3D.new()
		line_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		line_mesh_inst.material_override = material
		line_mesh_inst.mesh = ImmediateMesh.new()

	func _ready() -> void:
		super._ready()

		head_offset.add_child(head_mesh_inst)
		add_child(head_offset)
		add_child(line_mesh_inst)

		_refresh()


# func _shape(id: StringName, transform: Transform3D, shape: Shape3D) -> Node3D:
# 	var result := registry.get(id, null)
# 	var create := result == null

# 	var mesh_inst : MeshInstance3D
# 	if create:
# 		result = Node3D.new()
# 		registry[id] = result
# 		add_child(result)

# 		mesh_inst = _mesh(shape.get_debug_mesh())
# 		result.add_child(mesh_inst)

# 		result.set_meta(&"_material", mesh_inst.material_override)


# 		set_color(id, Color(1, 1, 1, 0.05))
# 	else:
# 		mesh_inst = result.get_child(0)

# 	mesh_inst.transform = transform

# 	return result

# func _collision(collision: KinematicCollision3D, color: Color, duration: float) -> Node3D:
# 	var result = Node3D.new()
# 	add_child(result)

# 	for i in collision.get_collision_count():
# 		var shape : Shape3D = collision.get_collider_shape(i)

# 		var material : StandardMaterial3D = MESH_MATERIAL.duplicate()
# 		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
# 		material.albedo_color = color

# 		var mesh_inst := _mesh(shape.get_debug_mesh())
# 		result.add_child(mesh_inst)

# 	if duration > 0.0:
# 		var timer := Timer.new()
# 		timer.wait_time = duration
# 		timer.autostart = true
# 		timer.timeout.connect(result.queue_free)
# 		result.add_child(timer)
# 	elif duration == 0.0:
# 		result.queue_free.call_deferred()
# 		return null

# 	return result
