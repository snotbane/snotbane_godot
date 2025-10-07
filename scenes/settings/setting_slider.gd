@tool class_name SettingSlider extends Setting

var slider : HSlider :
	get: return $hbox/control/h_slider if find_child(&"h_slider") else null

@export var slider_value : float :
	get: return slider.value if slider else -1.0
	set(val):
		if not slider: return
		slider.value = val

@export var slider_min_value : float :
	get: return slider.min_value if slider else -1.0
	set(val):
		if not slider: return
		slider.min_value = val

@export var slider_max_value : float :
	get: return slider.max_value if slider else -1.0
	set(val):
		if not slider: return
		slider.max_value = val

@export var slider_step : float :
	get: return slider.step if slider else -1.0
	set(val):
		if not slider: return
		slider.step = val

@export var slider_tick_count : int :
	get: return slider.tick_count if slider else 0
	set(val):
		if not slider: return
		slider.tick_count = val


func _ready() -> void:
	default_value = slider_value
	super._ready()


func _set_value_to_control(val: Variant) -> void:
	if val is not float: return
	slider_value = val


func _on_h_slider_drag_ended(val_changed:bool) -> void:
	if not value_changed: return
	value = slider_value


