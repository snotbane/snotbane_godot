
@tool class_name SettingRange extends SettingBase

var range : Range

func _init() -> void:
	super._init()

	range = HSlider.new()
	range.custom_minimum_size.x = 100.0
	range.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	range.step = 1.0
	hbox_setting.add_child(range)

	range.add_child(tracker)

@export_enum("Spin Box", "Horizontal Slider") var input_type : int = 0 :
	get:
		if range is HSlider:	return 0
		if range is SpinBox:	return 1
		return -1

	set(value):
		if input_type == value: return

		var new_range : Range
		match value:
			0: new_range = HSlider.new()
			1: new_range = SpinBox.new()
			_: return

		new_range.custom_minimum_size.x = range.custom_minimum_size.x
		new_range.size_flags_vertical = range.size_flags_vertical
		new_range.value = range.value
		new_range.step = range.step
		new_range.min_value = range.min_value
		new_range.max_value = range.max_value
		if range.value_changed.is_connected(tracker._parent_value_changed):
			new_range.value_changed.connect(tracker._parent_value_changed.unbind(1))

		hbox_setting.add_child(new_range)
		tracker.reparent(new_range)
		range.queue_free()
		range = new_range


@export var handle_minimum_width : float = 100.0 :
	get: return range.custom_minimum_size.x
	set(value): range.custom_minimum_size.x = value


@export var min_value : float :
	get: return range.min_value
	set(value): range.min_value = value

@export var max_value : float = 100.0 :
	get: return range.max_value
	set(value): range.max_value = value

@export var value : float :
	get: return range.value
	set(value): range.value = value

@export_range(0.0, 1.0, 0.0001, "or_greater") var step : float = 1.0 :
	get: return range.step
	set(value): range.step = value

