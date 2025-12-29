
@tool class_name DebugDraw3D extends Node3D

const POINT_MESH := preload("uid://cnkvd3t13kcod")
const ARROW_MESH := preload("uid://bak40cp1rwhko")
const MESH_MATERIAL := preload("uid://bdosbg5iohx24")

static func get_fixed_scale(camera: Camera3D, global_origin: Vector3, pixel_size: float) -> float:
	var fov_rad = deg_to_rad(camera.fov)
	var distance = camera.global_position.distance_to(global_origin)
	var view_height = 2.0 * distance * tan(fov_rad * 0.5)
	var pixel_height = camera.get_viewport().get_visible_rect().size.y
	var world_per_pixel = view_height / pixel_height

	return pixel_size * world_per_pixel


var _debug_visibility : int = 7
@export_flags("Editor", "Player", "Debug", "Release") var debug_visibility : int = 7 :
	get: return _debug_visibility
	set(value):
		_debug_visibility = value
		_refresh_visibility()
func _refresh_visibility() -> void:
	if Engine.is_editor_hint():
		visible = _debug_visibility & 1
	elif OS.has_feature(&"editor_runtime"):
		visible = _debug_visibility & 2
	elif OS.has_feature(&"debug"):
		visible = _debug_visibility & 4
	else:
		visible = _debug_visibility & 8

func _init() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _ready() -> void:
	_refresh_visibility()
	# if not OS.has_feature(&"release") or visible: return

	# var substitute := Node3D.new()
	# substitute.transform = transform
	# for child in get_children():
	# 	child.reparent(substitute, false)

	# add_sibling(substitute)
	# queue_free()

func _on_visibility_changed() -> void:
	if Engine.is_editor_hint():
		debug_visibility = (debug_visibility | (1 << 0)) if visible else (debug_visibility & ~(1 << 0))
