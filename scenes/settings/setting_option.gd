@tool extends Setting

var option : OptionButton :
	get: return $hbox/control/option_button if find_child("option_button") else null

var _option_list : PackedStringArray
@export var option_list : PackedStringArray :
	get:
		return _option_list
	set(val):
		_option_list = val
		if not option: return

		option.clear()
		for i in _option_list.size():
			option.add_item(_option_list[i])


@export var selected : int :
	get: return option.selected if option else -1
	set(val):
		if not option: return
		option.selected = val


var value_as_text : String :
	get: return _option_list[value] if value > -1 else ""


func _set_value_to_control(val: Variant) -> void:
	if val is not int: return
	val = clampi(val, -1, _option_list.size() - 1)
	selected = val


func _ready() -> void:
	default_value = option.selected
	option_list = option_list
	super._ready()
