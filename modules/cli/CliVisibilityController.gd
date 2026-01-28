
extends Node

@onready var parent : CanvasLayer = get_parent()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_QUOTELEFT:
		parent.visible = not parent.visible
		get_viewport().set_input_as_handled()
	elif parent.visible and event.is_action_pressed(&"ui_cancel"):
			parent.visible = false
			get_viewport().set_input_as_handled()

