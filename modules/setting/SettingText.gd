
@tool class_name SettingText extends SettingBase

const FILE_BUTTON_ICON := preload("uid://da04krtpviega")

## Emitted when [member file_button] is pressed. Use with [member file_dialog_type.CUSTOM] to customize what the button does.
signal file_button_pressed

## Emitted when [member file_dialog_type] is Open Path or Open Content, and [member file_dialog] is selected and confirmed.
signal file_selected(path: String)

var hbox_input : HBoxContainer
var input : Control
var file_button : Button
var file_dialog : FileDialog

func _init() -> void:
	super._init()

	_validation_method = VALIDATION_METHODS[StringValidation.NO_VALIDATION]

	hbox_input = HBoxContainer.new()
	hbox_input.custom_minimum_size.x = 100.0
	hbox_input.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_handle.add_child(hbox_input)

	input = LineEdit.new()
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox_input.add_child(input)

	file_button = Button.new()
	file_button.icon = FILE_BUTTON_ICON
	file_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	file_button.visible = false
	hbox_input.add_child(file_button, false, INTERNAL_MODE_BACK)

	file_dialog = FileDialog.new()
	file_dialog.use_native_dialog = true
	file_dialog.display_mode = FileDialog.DISPLAY_LIST
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_USERDATA
	add_child(file_dialog)

	input.add_child(tracker)

	file_button.pressed.connect(file_button_pressed.emit)


@export var text : String :
	get: return input.text
	set(value): input.text = value


@export var placeholder_text : String :
	get: return input.placeholder_text
	set(value): input.placeholder_text = value


var _input_type : int
@export_enum("Single Line", "Multi Line", "Code") var input_type : int :
	get: return _input_type
	set(value):
		if _input_type == value: return
		_input_type = value

		var new_input : Control
		match _input_type:
			0: new_input = LineEdit.new()
			1: new_input = TextEdit.new()
			2: new_input = CodeEdit.new()
			_: return

		new_input.size_flags_horizontal = input.size_flags_horizontal
		new_input.size_flags_vertical = Control.SIZE_SHRINK_CENTER if value <= 0 else Control.SIZE_EXPAND_FILL
		new_input.text = input.text
		if new_input.text_changed.is_connected(tracker._parent_value_changed):
			new_input.text_changed.connect(tracker._parent_value_changed.unbind(1))

		hbox_input.add_child(new_input)
		tracker.reparent(new_input)
		input.queue_free()
		input = new_input


@export var handle_minimum_width : float = 100.0 :
	get: return hbox_input.custom_minimum_size.x
	set(value): hbox_input.custom_minimum_size.x = value


var _validation_method : Callable
var _validation_type : int
@export var validation_type : StringValidation :
	get: return _validation_type
	set(value):
		if _validation_type == value: return
		_validation_type = value

		_validation_method = VALIDATION_METHODS[_validation_type]
		validate()
enum StringValidation {
	## No validation will be applied.
	NO_VALIDATION,
	## Uses [member String.is_empty()] to validate this [String].
	NON_EMPTY,
	## Uses [member RegEx.is_valid()] to validate this [String].
	REGULAR_EXPRESSION,
	## Validates if the given path points to an existing directory.
	EXISTING_DIR_PATH,
	## Validates if the given path points to an existing file.
	EXISTING_FILE_PATH,
	## Uses [member String.is_valid_filename()] to validate this [String].
	VALID_FILE_NAME,
	## Uses [member String.is_valid_ip_address()] to validate this [String].
	VALID_IP_ADDRESS,
	## Override [member _validate_custom()] in order to use this method.
	CUSTOM,
}

var VALIDATION_METHODS : Array[Callable] = [
	func() -> String:
	return String()
	,

	func() -> String:
	return String() \
		if not text.is_empty() \
		else "Must not be empty."
	,

	func() -> String:
	return String() \
		if RegEx.create_from_string(text).is_valid() \
		else "Invalid regular expression."
	,

	func() -> String:
	return String() \
		if DirAccess.open(text) != null \
		else "Folder path does not exist."
	,

	func() -> String:
	return String() \
		if FileAccess.file_exists(text) \
		else "File path does not exist."
	,

	func() -> String:
	return String() \
		if text.is_valid_filename() \
		else "Must be a valid file name."
	,

	func() -> String:
	return String() \
		if text.is_valid_ip_address() \
		else "Must be a valid IP address."
	,

	_validate_custom
]

func _validate_custom() -> String: return "Unimplmented validation method."
func _validate() -> String: return _validation_method.call()


@export_group("File Dialog", "file_dialog_")

var _file_dialog_type : int
@export_enum("No Button", "Open Path", "Open Content", "Custom") var file_dialog_type : int :
	get: return _file_dialog_type
	set(value):
		if _file_dialog_type == value: return

		match _file_dialog_type:
			1:
				if file_button.pressed.is_connected(_button_open_path):
					file_button.pressed.disconnect(_button_open_path)
			2:
				if file_button.pressed.is_connected(_button_open_content):
					file_button.pressed.disconnect(_button_open_content)

		_file_dialog_type = value
		file_button.visible = _file_dialog_type != 0

		match _file_dialog_type:
			1: file_button.pressed.connect(_button_open_path)
			2: file_button.pressed.connect(_button_open_content)


@export var file_dialog_icon : Texture2D = FILE_BUTTON_ICON :
	get: return file_button.icon
	set(value): file_button.icon = value

@export var file_dialog_file_mode := FileDialog.FileMode.FILE_MODE_OPEN_FILE :
	get: return file_dialog.file_mode
	set(value): file_dialog.file_mode = value

@export var file_dialog_access := FileDialog.Access.ACCESS_USERDATA :
	get: return file_dialog.access
	set(value): file_dialog.access = value

@export var file_dialog_filters : PackedStringArray :
	get: return file_dialog.filters
	set(value): file_dialog.filters = value


func _button_open_path() -> void:
	var path = await _prompt_file_path()
	if path == null: return

	text = path


func _button_open_content() -> void:
	var path = await _prompt_file_path()
	if path == null: return

	var file := FileAccess.open(path, FileAccess.READ)
	match file.get_open_error():
		OK:	pass
		_:	return

	text = file.get_as_text()


func _prompt_file_path():
	file_dialog.popup_file_dialog()
	var action : int = await Async.any_indexed([file_dialog.confirmed, file_dialog.canceled])
	match action:
		0:
			file_selected.emit(file_dialog.current_path)
			return file_dialog.current_path
		_:
			return null
