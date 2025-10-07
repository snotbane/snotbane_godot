@tool class_name Setting extends Control

const CONFIG_PATH := "user://prefs.cfg"
const DEFAULT_SECTION := &"committed"
static var CONFIG : ConfigFile

static func _static_init() -> void:
	CONFIG = ConfigFile.new()
	var err := CONFIG.load(CONFIG_PATH)
	if err != OK:
		CONFIG.save(CONFIG_PATH)


static var all_settings : Dictionary[StringName, Variant] :
	get:
		var result : Dictionary[StringName, Variant] = {}
		for key in CONFIG.get_section_keys(DEFAULT_SECTION):
			result[key] = CONFIG.get_value(DEFAULT_SECTION, key)
		return result

static var all_setting_keys : PackedStringArray :
	get: return CONFIG.get_section_keys(DEFAULT_SECTION)


static func has_setting(setting_name: StringName) -> bool:
	return CONFIG.has_section_key(DEFAULT_SECTION, setting_name)
static func get_setting(setting_name: StringName, default: Variant = null) -> Variant:
	if not has_setting(setting_name): return default
	return CONFIG.get_value(DEFAULT_SECTION, setting_name, default)
static func set_setting(setting_name: StringName, val: Variant) -> void:
	if Engine.is_editor_hint(): return
	CONFIG.set_value(DEFAULT_SECTION, setting_name, val)
	CONFIG.save(CONFIG_PATH)

	if not UserSettings.inst: return
	UserSettings.inst.update_setting_from_config(setting_name)


signal value_changed(val: Variant)


@export_tool_button("Open Settings File") var show_settings_func_ := func():
	OS.shell_open(ProjectSettings.globalize_path(CONFIG_PATH))


var _enabled : bool = true
@export var enabled : bool = true :
	get: return _enabled
	set(val):
		if _enabled == val: return
		_enabled = val

		self.modulate = Color.WHITE if _enabled else Color8(255, 255, 255, 64)
		_enabled_changed()
func _enabled_changed() -> void: pass


var label : Label :
	get: return $hbox/label
@export var label_text : String = "Setting" :
	get: return label.text if label else ""
	set(value):
		if not label: return
		label.text = value


var value : Variant :
	get: return get_setting(name)
	set(val):
		if Engine.is_editor_hint(): return
		Setting.set_setting(name, val)
		_set_value_to_control(val)
		if val == null: return
		value_changed.emit(val)
func _set_value_to_control(val: Variant) -> void: pass
func _set_control_to_value(val: Variant) -> void:
	Setting.set_setting(name, val)
	if val == null: return
	value_changed.emit(val)

var default_value : Variant

func _ready() -> void:
	if Engine.is_editor_hint(): return

	if Setting.has_setting(name):
		_set_value_to_control(Setting.get_setting(name))


func reset_value_to_default() -> void:
	value = default_value
