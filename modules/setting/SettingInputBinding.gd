
@tool class_name SettingInputBinding extends Setting

enum {
	FILTER_MIN = 0,
	FILTER_MOUSE = 1,
	FILTER_KEYBOARD = 2,
	FILTER_JOYPAD = 4,
	FILTER_OTHER = 8,
	FILTER_MAX = 15
}

const ADD_ICON := preload("uid://kvngtelx5dm1")

var hflow_buttons : HFlowContainer
var add_button : Button

func _init() -> void:
	super._init()

	add_button = Button.new()
	add_button.visible = false
	add_button.icon = ADD_ICON
	add_button.flat = true
	add_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_button.pressed.connect(create_binding)
	hbox_panel.add_child(add_button)

	hflow_buttons = HFlowContainer.new()
	hflow_buttons.custom_minimum_size.x = 100.0
	hflow_buttons.alignment = FlowContainer.ALIGNMENT_END
	hbox_panel.add_child(hflow_buttons)

	# self.add_child(tracker)

var binding_buttons : Array[InputBindingButton] :
	get: return hflow_buttons.get_children() as Array[InputBindingButton]

@export var bindings : Array[InputEvent] :
	get:
		var result : Array[InputEvent] = []
		for child in hflow_buttons.get_children():
			if child is not InputBindingButton: continue
			result.push_back(child.event)
		return result
	set(value):
		for child in hflow_buttons.get_children():
			if child is not InputBindingButton: continue
			child.queue_free()
		for event in value:
			create_binding(event, false)


var _allow_modifiers : bool = false
@export var allow_modifiers : bool = false :
	get: return _allow_modifiers
	set(value): _allow_modifiers = value


var _event_filter : int = FILTER_MAX
## Use this to preview what each event will look like per filter. At runtime, this will be automatically set based on which input was last used. Other inputs will always be visible.
@export_flags("Keyboard & Mouse:3", "Joypad:4", "Other:8") var event_filter : int = FILTER_MAX :
	get: return _event_filter
	set(value):
		_event_filter = value
		for button in binding_buttons:
			button.visible = button.filter_category | _event_filter


@export var handle_minimum_width : float = 100.0 :
	get: return hflow_buttons.custom_minimum_size.x
	set(value): hflow_buttons.custom_minimum_size.x = value


var _binding_minimum_width : float = 40.0
@export var binding_minimum_width : float = 40.0 :
	get: return _binding_minimum_width
	set(value):
		_binding_minimum_width = value

@export_group("Multiple Bindings", "add_button_")

## If enabled, the user may add and remove any number of additional input bindings may be added to this input. The developer may always set as many or as few bindings as desired.
@export var add_button_allow : bool = false :
	get: return add_button.visible
	set(value): add_button.visible = value

@export var add_button_icon : Texture2D = ADD_ICON :
	get: return add_button.icon
	set(value): add_button.icon = value

@export var add_button_flat : bool = true :
	get: return add_button.flat
	set(value): add_button.flat = value


@export_group("")

func create_binding(event : InputEvent = null, begin_remap := true) -> InputBindingButton:
	var result := InputBindingButton.new(event, begin_remap)
	result.custom_minimum_size.x = _binding_minimum_width
	hflow_buttons.add_child(result)

	return result


func remove_binding() -> void:
	pass
