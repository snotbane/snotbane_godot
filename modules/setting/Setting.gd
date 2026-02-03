
@tool class_name Setting extends Control

const RESET_ICON := preload("uid://cc4at53uoxehi")

static var STYLEBOX_EMPTY : StyleBoxEmpty
static var STYLEBOX_INVALID : StyleBoxFlat
const STYLEBOX_MARGIN_LEFT : int = 6
const STYLEBOX_MARGIN_RIGHT : int = 6
const STYLEBOX_MARGIN_TOP : int = 2
const STYLEBOX_MARGIN_BOTTOM : int = 2

static func _static_init() -> void:
	STYLEBOX_EMPTY = StyleBoxEmpty.new()
	STYLEBOX_EMPTY.content_margin_left		= STYLEBOX_MARGIN_LEFT
	STYLEBOX_EMPTY.content_margin_right		= STYLEBOX_MARGIN_RIGHT
	STYLEBOX_EMPTY.content_margin_top		= STYLEBOX_MARGIN_TOP
	STYLEBOX_EMPTY.content_margin_bottom	= STYLEBOX_MARGIN_BOTTOM

	STYLEBOX_INVALID = StyleBoxFlat.new()
	STYLEBOX_INVALID.bg_color = Color.INDIAN_RED
	STYLEBOX_INVALID.content_margin_left	= STYLEBOX_MARGIN_LEFT
	STYLEBOX_INVALID.content_margin_right	= STYLEBOX_MARGIN_RIGHT
	STYLEBOX_INVALID.content_margin_top		= STYLEBOX_MARGIN_TOP
	STYLEBOX_INVALID.content_margin_bottom	= STYLEBOX_MARGIN_BOTTOM


signal value_changed(new_value: Variant)
signal valid_changed(new_valid: bool)


var hbox_all : HBoxContainer
var panel_container : PanelContainer
var hbox_handle : HBoxContainer
var label : Label
var space : Control

var tracker : SettingTracker
var reset_button_container : Control
var reset_button : Button

var default_tooltip_text : String


func _init() -> void:
	default_tooltip_text = tooltip_text

	hbox_all = HBoxContainer.new()
	hbox_all.set_anchors_preset(PRESET_FULL_RECT)
	self.add_child(hbox_all)

	panel_container = PanelContainer.new()
	panel_container.add_theme_stylebox_override(&"panel", STYLEBOX_EMPTY)
	panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_container.tooltip_text = tooltip_text
	panel_container.tooltip_auto_translate_mode = tooltip_auto_translate_mode
	hbox_all.add_child(panel_container)

	hbox_handle = HBoxContainer.new()
	panel_container.add_child(hbox_handle)

	label = Label.new()
	label.name = &"label"
	label.text = "Setting"
	hbox_handle.add_child(label)

	space = Control.new()
	space.name = &"space"
	space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox_handle.add_child(space)

	reset_button_container = Control.new()
	# reset_button_container.custom_minimum_size
	hbox_all.add_child(reset_button_container)

	reset_button = Button.new()
	reset_button.name = &"reset_button"
	reset_button.icon = RESET_ICON
	reset_button.flat = true
	reset_button.visible = OS.has_feature(&"editor_hint")
	reset_button.set_anchors_preset(PRESET_FULL_RECT)
	reset_button_container.add_child(reset_button)

	tracker = SettingTracker.new()
	tracker.name = &"setting_tracker"

	tracker.value_changed.connect(value_changed.emit)

	if not OS.has_feature(&"editor_hint"):
		tracker.override_changed.connect(reset_button.set_visible)
		reset_button.pressed.connect(tracker.reset)


func _get_minimum_size() -> Vector2:
	return panel_container.get_minimum_size()


func _ready() -> void:
	reset_button_container.custom_minimum_size = reset_button.get_combined_minimum_size()

	validate()


@export var label_text : String = "Setting" :
	get: return label.text
	set(value): label.text = value


@export_group("Tracker", "tracker_")

@export_enum("No Autosave", "On Hidden", "On Focus Exited", "On Value Changed") var tracker_autosave : int = SettingTracker.ON_VALUE_CHANGED :
	get: return tracker.autosave
	set(value): tracker.autosave = value


@export var tracker_filename : String = "default" :
	get: return tracker.storage_name
	set(value): tracker.storage_name = value

@export var tracker_key : StringName :
	get: return tracker.key
	set(value): tracker.key = value

@export_tool_button("Open Tracker File") var tracker_open_tool_button := func() -> void:
	tracker.storage_file.shell_open()


@export_group("Validation")

var panel_normal : StyleBox :
	get: return get_theme_stylebox(&"setting_panel_normal", &"Setting") if has_theme_stylebox(&"setting_panel_normal", &"Setting") else STYLEBOX_EMPTY

var panel_invalid : StyleBox :
	get: return get_theme_stylebox(&"setting_panel_invalid", &"Setting") if has_theme_stylebox(&"setting_panel_invalid", &"Setting") else STYLEBOX_INVALID


var _validation_tooltip_text : String
var validation_tooltip_text : String :
	get: return _validation_tooltip_text
	set(value):
		var _is_valid_prev := is_valid

		_validation_tooltip_text = value

		if is_valid:
			panel_container.tooltip_text = default_tooltip_text
			panel_container.add_theme_stylebox_override(&"panel", panel_normal)
		else:
			panel_container.tooltip_text = _validation_tooltip_text
			panel_container.add_theme_stylebox_override(&"panel", panel_invalid)

		if is_valid != _is_valid_prev:
			valid_changed.emit(is_valid)

var is_valid : bool :
	get: return _validation_tooltip_text.is_empty()


func validate() -> void:
	validation_tooltip_text = _validate()
func _validate() -> String: return String()


@export_group("Reset Button", "reset_button_")

## Preallocates space for a reset button. The button will always be visible in editor.
@export var reset_button_enabled : bool = true :
	get: return reset_button_container.visible
	set(value): reset_button_container.visible = value

@export var reset_button_flat : bool = true :
	get: return reset_button.flat
	set(value): reset_button.flat = value

@export var reset_button_icon : Texture2D = RESET_ICON :
	get: return reset_button.icon
	set(value): reset_button.icon = value


@export_group("")
