## Add this node to one of many kinds of [Control]s in order to store its values in a [ConfigFile] automatically. Data is loaded on ready, or whenever the parent [Control] becomes visible. can be saved manually or automatically.
class_name SettingTracker extends Node


const STORAGE_DIR := "user://settings"


static var storage_registry: Dictionary


static func _static_init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(STORAGE_DIR))


signal override_changed(is_overridden: bool)


@export_enum("No Autosave", "On Hidden", "On Focus Exited", "On Value Changed") var autosave : int = ON_VALUE_CHANGED
enum {
	## This setting will not save automatically. Call [member commit()] on any setting in order to save changes to all settings with the same [member storage_path].
	NO_AUTOSAVE,
	## This setting will save when its parent is hidden.
	ON_HIDDEN,
	## This setting will save when its parent's [member focus_exited] signal emits.
	ON_FOCUS_EXITED,
	## This setting will save when its parent's value changes, depending on what kind of [Control] it is.
	ON_VALUE_CHANGED,
}

## The default path for this setting to exist in. The path will be made relative to `user://settings/`
@export var storage_name : String = "default"

var storage_path : String :
	get: return STORAGE_DIR.path_join(storage_name + ".json")

var storage_file : JsonResource :
	get:
		if not storage_registry.has(storage_path):
			storage_registry[storage_path] = JsonResource.new(storage_path)

		return storage_registry[storage_path]


## The key in the [member storage_file]'s [member section] to store the value to.
@export var key : String


var _value_is_changing : bool
var _value_prev : Variant
var value : Variant :
	get:
		if parent is Range:
			return parent.value

		elif parent is LineEdit:
			return parent.text

		else:
			return null

	set(new_value):
		if value == new_value: return

		if parent is Range:
			parent.value = new_value

		elif parent is LineEdit:
			parent.text = new_value
			_parent_value_changed()


var _default_value : Variant
var value_is_default : bool :
	get: return value == _default_value


@onready var parent : Control = get_parent()
var parent_is_valid : bool :
	get: return (
			parent is LineEdit
		or	parent is Range
	)


func _ready() -> void:
	assert(not key.is_empty(), "SettingTracker (%s) needs a setting key." % self)
	assert(parent_is_valid, "SettingTracker (%s) must be the child of one of the following types: [ LineEdit ]" % self)

	_default_value = value
	_value_prev = _default_value

	if parent is Range:
		parent.value_changed.connect(_parent_value_changed)

	elif parent is LineEdit:
		parent.text_changed.connect(_parent_value_changed.unbind(1))

	match autosave:
		ON_FOCUS_EXITED:
			parent.focus_exited.connect(commit)

	storage_file.load_from_file()
	retrieve()

	parent.visibility_changed.connect(_parent_visibility_changed)


func _parent_visibility_changed() -> void:
	if parent.visible:
		retrieve()
	elif autosave == ON_HIDDEN:
		commit()


func _parent_value_changed() -> void:
	if _value_prev == _default_value and value != _default_value:
		override_changed.emit(true)

	elif _value_prev != _default_value and value == _default_value:
		override_changed.emit(false)

	_value_prev = value

	match autosave:
		ON_VALUE_CHANGED:
			commit()


## Retrieves the value from the config, provided that it is loaded and up to date.
func retrieve() -> void:
	if not storage_file.data.has(key): return

	value = storage_file.data[key]


## Sets the value to the config and saves it.
func commit() -> void:
	storage_file.data[key] = value
	storage_file.save_to_file()


## Resets the value to the default value.
func reset() -> void:
	value = _default_value
	_parent_value_changed()
