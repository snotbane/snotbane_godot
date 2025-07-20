extends Node

var is_in_fullscreen : bool :
	get: return get_window().mode == Window.MODE_FULLSCREEN or get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN
	set(value):
			get_window().mode = get_fullscreen_enter_mode() \
			if value else 		get_fullscreen_exit_mode()

func _ready() -> void:
	if not OS.is_debug_build(): self.is_in_fullscreen = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		self.is_in_fullscreen = not self.is_in_fullscreen


func get_fullscreen_enter_mode() -> Window.Mode: return Window.MODE_FULLSCREEN

func get_fullscreen_exit_mode() -> Window.Mode: return Window.MODE_WINDOWED
