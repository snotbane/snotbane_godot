class_name UserSettings extends Node

const UI_SCALE_FACTORS : PackedFloat32Array = [ 0.5, 0.75, 1.0, 1.5, 2.0 ]


static var inst : UserSettings


signal setting_changed(key: StringName)


var property_names : PackedStringArray


var print_speed : float :
	get: return Typewriter.user_setting_print_speed
	set(value):	Typewriter.user_setting_print_speed = value

var fullscreen : bool :
	get: return get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN
	set(value): get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if value else Window.MODE_WINDOWED

var _ui_scale : int
var ui_scale : int :
	get: return _ui_scale
	set(value):
		_ui_scale = value
		get_window().content_scale_factor = UI_SCALE_FACTORS[_ui_scale]


func _ready() -> void:
	inst = self

	var property_list := get_property_list()
	for prop in property_list:
		property_names.push_back(prop[&"name"])

	for key in Setting.all_setting_keys:
		update_setting_from_config(key)


func update_setting_from_config(key: StringName) -> void:
	if key in property_names:
		set(key, Setting.get_setting(key))
	setting_changed.emit(key)
