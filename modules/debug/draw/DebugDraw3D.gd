class_name DebugDraw3D extends Node3D

const POINT_MESH : Mesh = preload("uid://cnkvd3t13kcod")
const ARROW_MESH : Mesh = preload("uid://bak40cp1rwhko")
const MESH_MATERIAL : StandardMaterial3D = preload("uid://bdosbg5iohx24")

static func get_fixed_scale(camera: Camera3D, global_position: Vector3, pixel_size: float) -> float:
	var fov_rad = deg_to_rad(camera.fov)
	var distance = camera.global_position.distance_to(global_position)
	var view_height = 2.0 * distance * tan(fov_rad * 0.5)
	var pixel_height = camera.get_viewport().get_visible_rect().size.y
	var world_per_pixel = view_height / pixel_height

	return pixel_size * world_per_pixel


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
			value = maxf(value, 0.0)
			if _max_head_size == value: return
			_max_head_size = value
			_refresh()
			_on_max_head_size_set()
	func _on_max_head_size_set() -> void: pass
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

		visible = not origin.is_equal_approx(target)
		if not visible: return

		var head_length := clampf(max_head_size, 0.0, length)
		var body_length := length - head_length

		body_mesh_inst.mesh.clear_surfaces()
		if body_length > 0.0:
			body_mesh_inst.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			body_mesh_inst.mesh.surface_add_vertex(origin)
			body_mesh_inst.mesh.surface_add_vertex(origin + normal * body_length)
			body_mesh_inst.mesh.surface_end()

		head_offset.scale = Vector3.ONE * head_length
		head_offset.global_position = origin + normal * (body_length + (head_length * 0.5))
		head_offset.look_at(
			head_offset.global_position + normal,
			Vector3.FORWARD if abs(normal.y) == 1.0 else Vector3.UP
		)

	var head_offset : Node3D
	var head_mesh_inst : MeshInstance3D
	var body_mesh_inst : MeshInstance3D

	static func from_global_to_global(__origin__:= Vector3.ZERO, __target__:= Vector3.ZERO, __max_head_size__: float = 0.25) -> Ray:
		return Ray.new(true, __origin__, __target__, __max_head_size__)

	static func to_direction(__normal__: Vector3, __length__: float = 1.0, __max_head_size__: float = 0.25) -> Ray:
		return Ray.new(false, Vector3.ZERO, __normal__ * __length__, __max_head_size__)

	func _init(__top_level__: bool, __origin__: Vector3, __target__: Vector3, __max_head_size__: float = 0.25) -> void:
		super._init(__top_level__)

		max_head_size = __max_head_size__
		origin = __origin__
		target = __target__

		head_offset = Node3D.new()

		head_mesh_inst = MeshInstance3D.new()
		head_mesh_inst.rotation_degrees.x = -90.0
		head_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		head_mesh_inst.material_override = material
		head_mesh_inst.mesh = DebugDraw3D.ARROW_MESH

		body_mesh_inst = MeshInstance3D.new()
		body_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		body_mesh_inst.material_override = material
		body_mesh_inst.mesh = ImmediateMesh.new()

	func _ready() -> void:
		super._ready()

		head_offset.add_child(head_mesh_inst)
		add_child(head_offset)
		add_child(body_mesh_inst)

		_refresh()
class RayCast extends DebugDraw3D._Generic:
	var cast : RayCast3D
	var point_radius : float

	var point_node : Node3D
	var point_mesh : MeshInstance3D
	var clear_line : MeshInstance3D
	var block_line : MeshInstance3D

	func _init(__raycast__: RayCast3D, __point_radius__: float = 10) -> void:
		cast = __raycast__

		point_node = Node3D.new()
		add_child(point_node)

		point_mesh = MeshInstance3D.new()
		point_mesh.rotation_degrees.x = -90.0
		point_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		point_mesh.mesh = DebugDraw3D.ARROW_MESH
		point_node.add_child(point_mesh)

		clear_line = MeshInstance3D.new()
		clear_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		clear_line.mesh = ImmediateMesh.new()
		clear_line.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
		clear_line.material_override.albedo_color = Color.GREEN
		add_child(clear_line)

		block_line = MeshInstance3D.new()
		block_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		block_line.mesh = ImmediateMesh.new()
		block_line.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
		block_line.material_override.albedo_color = Color.RED
		add_child(block_line)

		super._init(true)

		point_mesh.material_override = material

		point_radius = __point_radius__

	func _process(delta: float) -> void:
		var point_scale := DebugDraw3D.get_fixed_scale(get_viewport().get_camera_3d(), point_node.global_position, point_radius)
		point_mesh.position.z = -point_scale
		point_mesh.scale = Vector3.ONE * point_scale

		_refresh(cast.is_colliding(), cast.get_collision_point(), cast.get_collision_normal(), cast.global_position, cast.target_position)

	func _refresh(is_colliding: bool, collision_point: Vector3, collision_normal: Vector3, global_origin: Vector3, target_position: Vector3) -> void:
		material.albedo_color = block_line.material_override.albedo_color if is_colliding else clear_line.material_override.albedo_color
		point_node.position = collision_point if is_colliding else (global_origin + target_position)
		var look_direction := collision_normal if is_colliding else target_position.normalized()
		point_node.look_at(
			point_node.global_position + look_direction,
			Vector3.FORWARD if abs(look_direction.y) == 1.0 else Vector3.UP
		)

		var length := target_position.length()
		var normal := target_position.normalized()
		var clear_distance := collision_point.distance_to(global_origin) if is_colliding else length

		clear_line.mesh.clear_surfaces()
		if clear_distance > 0.0:
			clear_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			clear_line.mesh.surface_add_vertex(global_origin + Vector3.ZERO)
			clear_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
			clear_line.mesh.surface_end()

		block_line.mesh.clear_surfaces()
		if clear_distance < length:
			block_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			block_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
			block_line.mesh.surface_add_vertex(global_origin + target_position)
			block_line.mesh.surface_end()
class Shape extends DebugDraw3D._Mesh:
	static func add_to_collision_shape(__collider__: CollisionShape3D) -> Shape:
		var result := Shape.new(false, Transform3D.IDENTITY, __collider__.shape)
		__collider__.add_child.call_deferred(result)
		return result

	func _init(__top_level__: bool = false, __transform__ := Transform3D.IDENTITY, __shape__: Shape3D = null) -> void:
		super._init(__top_level__, __shape__.get_debug_mesh() if __shape__ else null)

		color = Color(1, 1, 1, 0.05)
class ShapeCast extends DebugDraw3D._Generic:
	var cast : ShapeCast3D
	var point_radius : float

	var points_multimesh : MultiMeshInstance3D
	var clear_line : MeshInstance3D
	var block_line : MeshInstance3D
	var shape_mesh : MeshInstance3D
	var target_mesh : MeshInstance3D
	var result_mesh : MeshInstance3D

	func _init(__cast__: ShapeCast3D, __point_radius__: float = 10) -> void:
		cast = __cast__

		points_multimesh = MultiMeshInstance3D.new()
		points_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		points_multimesh.multimesh = MultiMesh.new()
		points_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		points_multimesh.multimesh.mesh = DebugDraw3D.ARROW_MESH
		add_child(points_multimesh)

		clear_line = MeshInstance3D.new()
		clear_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		clear_line.mesh = ImmediateMesh.new()
		clear_line.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
		clear_line.material_override.albedo_color = Color.GREEN
		add_child(clear_line)

		block_line = MeshInstance3D.new()
		block_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		block_line.mesh = ImmediateMesh.new()
		block_line.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
		block_line.material_override.albedo_color = Color.RED
		add_child(block_line)

		shape_mesh = MeshInstance3D.new()
		shape_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shape_mesh.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
		shape_mesh.material_override.albedo_color = Color(0, 1, 0, 0.05)
		shape_mesh.mesh = cast.shape.get_debug_mesh()
		add_child(shape_mesh)

		super._init(true)

		points_multimesh.material_override = material

		point_radius = __point_radius__

	func _process(delta: float) -> void:
		var camera := get_viewport().get_camera_3d()
		points_multimesh.multimesh.instance_count = cast.get_collision_count()
		for i in points_multimesh.multimesh.instance_count:
			var point_position := cast.get_collision_point(i)
			var point_normal := cast.get_collision_normal(i)
			var point_scale := DebugDraw3D.get_fixed_scale(camera, point_position, point_radius)
			points_multimesh.multimesh.set_instance_transform(i, Transform3D(
					Basis.looking_at(point_normal)	* Basis(Vector3.RIGHT, deg_to_rad(-90)).scaled(Vector3.ONE * point_scale),
					point_position + point_normal * point_scale
				)
			)

		var is_colliding := points_multimesh.multimesh.instance_count > 0
		points_multimesh.material_override.albedo_color = block_line.material_override.albedo_color if is_colliding else clear_line.material_override.albedo_color

		var midpoint := cast.global_position.lerp(cast.global_position + cast.target_position, cast.get_closest_collision_unsafe_fraction() if is_colliding else 1.0)

		shape_mesh.global_position = midpoint
		shape_mesh.material_override.albedo_color = Color(1, 0, 0, 0.25) if is_colliding else Color(0, 1, 0, 0.05)

		_refresh(is_colliding, midpoint, cast.global_position, cast.target_position)

	func _refresh(is_colliding: bool, collision_point: Vector3, global_origin: Vector3, target_position: Vector3) -> void:
		var length := target_position.length()
		var normal := target_position.normalized()
		var clear_distance := collision_point.distance_to(global_origin) if is_colliding else length

		clear_line.mesh.clear_surfaces()
		if clear_distance > 0.0:
			clear_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			clear_line.mesh.surface_add_vertex(global_origin + Vector3.ZERO)
			clear_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
			clear_line.mesh.surface_end()

		block_line.mesh.clear_surfaces()
		if clear_distance < length:
			block_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			block_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
			block_line.mesh.surface_add_vertex(global_origin + target_position)
			block_line.mesh.surface_end()
