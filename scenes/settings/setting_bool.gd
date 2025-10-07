@tool extends Setting

@export var toggle_value : bool :
	get: return	toggle.button_pressed
	set(val):
		if not toggle: return
		toggle.button_pressed = val

@export var toggle : CheckButton



func _ready() -> void:
	default_value = toggle_value
	super._ready()


func _set_value_to_control(val: Variant) -> void:
	if val is not bool: return
	toggle_value = val
