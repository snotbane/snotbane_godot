
@tool class_name SettingOption extends SettingBase

var option : OptionButton

func _init() -> void:
	super._init()

	option = OptionButton.new()
	option.custom_minimum_size.x = 100.0
	option.selected = 0
	option.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox_setting.add_child(option)

	option.add_child(tracker)


@export var handle_minimum_width : float = 100.0 :
	get: return option.custom_minimum_size.x
	set(value): option.custom_minimum_size.x = value


@export var options : PackedStringArray :
	get:
		var result := PackedStringArray()
		result.resize(option.item_count)
		for i in result.size():
			result[i] = option.get_item_text(i)
		return result

	set(value):
		while option.item_count > value.size():
			option.remove_item(value.size())
		while option.item_count < value.size():
			option.add_item("")
		for i in value.size():
			option.set_item_text(i, value[i])
			option.set_item_id(i, i)

@export var selected : int :
	get: return option.selected
	set(value): option.selected = value