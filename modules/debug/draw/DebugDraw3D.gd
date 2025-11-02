class_name DebugDraw3D extends Node3D

const POINT_MESH : Mesh = preload("uid://cnkvd3t13kcod")
const ARROW_MESH : Mesh = preload("uid://bak40cp1rwhko")
const MESH_MATERIAL : StandardMaterial3D = preload("uid://bdosbg5iohx24")

static func get_fixed_scale(camera: Camera3D, global_origin: Vector3, pixel_size: float) -> float:
	var fov_rad = deg_to_rad(camera.fov)
	var distance = camera.global_position.distance_to(global_origin)
	var view_height = 2.0 * distance * tan(fov_rad * 0.5)
	var pixel_height = camera.get_viewport().get_visible_rect().size.y
	var world_per_pixel = view_height / pixel_height

	return pixel_size * world_per_pixel


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
	set(value): color = Color(color.r, color.g, color.b, value)

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
	add_child(timer)
