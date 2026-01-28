
extends Node

@onready var parent : CanvasLayer = get_parent()
@onready var mini_panel : Control = %mini_panel
@onready var full_panel : Control = %full_panel

## If enabled, the terminal interface will be available in non-debug builds. Otherwise, it will be destroyed.
@export var allow_in_release : bool = false

## Determines which features are available in the terminal. Features can be cycled through using [member Snotbane.INPUT_CLI_TOGGLE].
@export_flags("Mini:1","Full:2") var features : int = 2

var _active_panel : int
var active_panel : int :
	get: return _active_panel
	set(value):
		if features == 0:
			_active_panel = 0
			full_panel.visible = false
			mini_panel.visible = false
			parent.visible = not parent.visible
		else:
			value = wrapi(value, 0, 3)
			while value != 0 and value & features == 0:
				value = wrapi(value + 1, 0, 3)

			_active_panel = value
			full_panel.visible = active_panel & 2 != 0
			mini_panel.visible = active_panel != 0
			parent.visible = mini_panel.visible


func _ready() -> void:
	if OS.is_debug_build() or allow_in_release: return

	parent.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(Snotbane.INPUT_TERMINAL_TOGGLE):
		active_panel += 1
		get_viewport().set_input_as_handled()
	elif parent.visible and event.is_action_pressed(&"ui_cancel"):
		active_panel = 0
		get_viewport().set_input_as_handled()
