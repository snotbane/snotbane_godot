
@tool class_name SettingBase extends Control

const RESET_ICON := preload("uid://cc4at53uoxehi")

var hbox_all : HBoxContainer
var panel_container : PanelContainer
var hbox_setting : HBoxContainer
var label : Label
var space : Control

var reset_button_container : Control
var reset_button : Button
var tracker : SettingTracker

func _init() -> void:
	hbox_all = HBoxContainer.new()
	hbox_all.set_anchors_preset(PRESET_FULL_RECT)
	self.add_child(hbox_all)

	panel_container = PanelContainer.new()
	panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_all.add_child(panel_container)

	hbox_setting = HBoxContainer.new()
	panel_container.add_child(hbox_setting)

	label = Label.new()
	label.name = &"label"
	label.text = "Setting"
	hbox_setting.add_child(label)

	space = Control.new()
	space.name = &"space"
	space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox_setting.add_child(space)

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

	reset_button.pressed.connect(tracker.reset)
	tracker.override_changed.connect(reset_button.set_visible)


func _get_minimum_size() -> Vector2:
	return panel_container.get_minimum_size()


func _ready() -> void:
	reset_button_container.custom_minimum_size = reset_button.get_combined_minimum_size()


@export var label_text : String = "Setting" :
	get: return label.text
	set(value): label.text = value


@export_category("Tracker")

@export_enum("No Autosave", "On Hidden", "On Focus Exited", "On Value Changed") var tracker_autosave : int = SettingTracker.ON_VALUE_CHANGED :
	get: return tracker.autosave
	set(value): tracker.autosave = value


@export var tracker_filename : String = "default" :
	get: return tracker.storage_name
	set(value): tracker.storage_name = value

@export var tracker_key : StringName :
	get: return tracker.key
	set(value): tracker.key = value


@export_group("Reset Button")

## Preallocates space for a reset button. The button will always be visible in editor.
@export var reset_enabled : bool = true :
	get: return reset_button_container.visible
	set(value): reset_button_container.visible = value

@export var reset_button_flat : bool = true :
	get: return reset_button.flat
	set(value): reset_button.flat = value

@export var reset_button_icon : Texture2D = RESET_ICON :
	get: return reset_button.icon
	set(value): reset_button.icon = value

@export_group("")

@export_tool_button("Open Tracker File") var _open_tracker := func() -> void:
	tracker.storage_file.shell_open()