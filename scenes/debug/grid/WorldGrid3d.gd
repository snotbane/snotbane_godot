extends MeshInstance3D

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
	else:
		visible = visible and OS.has_feature(&"editor_runtime")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_grid_toggle"):
		visible = not visible
