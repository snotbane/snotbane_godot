
class_name SettingTracker extends Node

## The default path for this setting to exist in. The path will be made relative to `user://settings/`
@export var storage_name : String = "default"
var storage_path : String :
	get: return "user://settings".path_join(storage_path + ".cfg")
var storage_file : ConfigFile

@export var category : String

@onready var parent : Control = get_parent()
var parent_is_valid : bool :
	get: return (
		parent is LineEdit
	)

func _ready() -> void:
	if not parent_is_valid:
		printerr("SettingTracker (%s) must be the child of one of the following types: [ LineEdit ]" % name)

	storage_file = ConfigFile.new()

	var err := storage_file.load(storage_path)
	match err:
		ERR_FILE_NOT_FOUND: storage_file.save(storage_path)

	value = storage_file.get_value(category, name, NAN)


var value : Variant :
	get:
		if parent is LineEdit:
			return parent.text
		return null
	set(new_value):
		if new_value

		if parent is LineEdit:
			parent.text = new_value