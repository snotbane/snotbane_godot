
@tool class_name SettingColor extends Setting

var color_picker : ColorPickerButton

func _init() -> void:
	super._init()

	color_picker = ColorPickerButton.new()
	color_picker.custom_minimum_size.x = 100.0
	color_picker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	color_picker.edit_alpha = false
	color_picker.edit_intensity = false
	hbox_handle.add_child(color_picker)

	color_picker.add_child(tracker)

@export var color : Color :
	get: return color_picker.color
	set(value): color_picker.color = value

@export var edit_alpha : bool = false :
	get: return color_picker.edit_alpha
	set(value): color_picker.edit_alpha = value

@export var edit_intensity : bool = false :
	get: return color_picker.edit_intensity
	set(value): color_picker.edit_intensity = value

@export var handle_minimum_width : float = 100.0 :
	get: return color_picker.custom_minimum_size.x
	set(value): color_picker.custom_minimum_size.x = value


