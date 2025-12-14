
@tool class_name DebugDraw3D_Ray extends DebugDraw3D

static func from_global_to_global(__origin__:= Vector3.ZERO, __target__:= Vector3.ZERO, __max_head_size__: float = 0.25) -> DebugDraw3D_Ray:
	return DebugDraw3D_Ray.new(true, __origin__, __target__, __max_head_size__)

static func to_direction(__normal__: Vector3, __length__: float = 1.0, __max_head_size__: float = 0.25) -> DebugDraw3D_Ray:
	return DebugDraw3D_Ray.new(false, Vector3.ZERO, __normal__ * __length__, __max_head_size__)

var _color := Color.WHITE_SMOKE
@export var color := Color.WHITE_SMOKE :
	get: return _color
	set(value):
		_color = value

		if body_mesh_inst == null: return

		body_mesh_inst.set_instance_shader_parameter(&"color", _color)
		head_mesh_inst.set_instance_shader_parameter(&"color", _color)

var _max_head_size : float = 0.1
@export var max_head_size : float = 0.1 :
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
@export_range(0.01, 1.0, 0.01, "or_greater") var length : float = 1.0 :
	get: return origin.distance_to(target)
	set(value): target = origin + normal * value
func _refresh() -> void:
	if not is_inside_tree(): return

	head_mesh_inst.visible = not origin.is_equal_approx(target)
	body_mesh_inst.visible = head_mesh_inst.visible
	if not head_mesh_inst.visible: return

	var head_length := clampf(max_head_size, 0.0, length)
	var body_length := length - head_length

	body_mesh_inst.mesh.clear_surfaces()
	if body_length > 0.0:
		body_mesh_inst.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, DebugDraw3D.MESH_MATERIAL)
		body_mesh_inst.mesh.surface_add_vertex(origin)
		body_mesh_inst.mesh.surface_add_vertex(origin + normal * body_length)
		body_mesh_inst.mesh.surface_end()

	head_offset.scale = Vector3.ONE * head_length
	head_offset.global_position = global_position + origin + normal * (body_length + (head_length * 0.5))
	head_offset.look_at(
		head_offset.global_position + normal,
		Vector3.FORWARD if abs(normal.y) == 1.0 else Vector3.UP
	)

var head_offset : Node3D
var head_mesh_inst : MeshInstance3D
var body_mesh_inst : MeshInstance3D

func _init(__top_level__: bool = false, __origin__ := Vector3.ZERO, __target__:= Vector3.FORWARD, __max_head_size__: float = 0.1) -> void:
	super._init(__top_level__)

	max_head_size = __max_head_size__
	origin = __origin__
	target = __target__

	head_offset = Node3D.new()
	add_child.call_deferred(head_offset, false, INTERNAL_MODE_BACK)

	head_mesh_inst = MeshInstance3D.new()
	head_mesh_inst.rotation_degrees.x = -90.0
	head_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	head_mesh_inst.mesh = DebugDraw3D.ARROW_MESH
	head_offset.add_child(head_mesh_inst)

	body_mesh_inst = MeshInstance3D.new()
	body_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body_mesh_inst.mesh = ImmediateMesh.new()
	add_child.call_deferred(body_mesh_inst, false, INTERNAL_MODE_BACK)

	color = color

	_refresh.call_deferred()
